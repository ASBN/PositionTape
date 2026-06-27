module position_tape
  implicit none
  integer, parameter :: default_search_length = 100003

  type mismatch
    logical :: has_value = .false.
    integer :: position = 0
    character(len=1) :: expected = char(0)
    logical :: has_expected = .false.
    character(len=1) :: received = char(0)
    logical :: has_received = .false.
  end type mismatch

  type validation_result
    logical :: is_valid = .false.
    integer :: expected_length = 0
    integer :: received_length = 0
    integer :: truncation_point = 0
    type(mismatch) :: first_mismatch
  end type validation_result

  type hash_window_index
    integer :: window_size = 0
    integer :: count = 0
    character(len=64), allocatable :: hashes(:)
    integer, allocatable :: positions(:)
  end type hash_window_index

contains
  function generate(length_value) result(text)
    integer, intent(in) :: length_value
    character(len=:), allocatable :: text
    character(len=32) :: marker
    integer :: cursor, written, marker_length, chunk_length

    if (length_value < 0) error stop "length must be non-negative"
    allocate(character(len=length_value) :: text)
    cursor = 1
    written = 0

    do while (written < length_value)
      if (mod(cursor, 10) == 0) then
        write(marker, '(I0)') cursor / 10
        marker_length = len_trim(marker)
        chunk_length = min(marker_length, length_value - written)
        text(written + 1:written + chunk_length) = marker(1:chunk_length)
        written = written + chunk_length
        cursor = cursor + marker_length
      else
        text(written + 1:written + 1) = achar(iachar('0') + mod(cursor, 10))
        written = written + 1
        cursor = cursor + 1
      end if
    end do
  end function generate

  function get_marker_complete_length(length_value) result(complete_length)
    integer, intent(in) :: length_value
    integer :: complete_length, cursor, marker_length, marker_end
    character(len=32) :: marker

    if (length_value < 0) error stop "length must be non-negative"
    cursor = 1
    do while (cursor <= length_value)
      if (mod(cursor, 10) == 0) then
        write(marker, '(I0)') cursor / 10
        marker_length = len_trim(marker)
        marker_end = cursor + marker_length - 1
        if (length_value < marker_end) then
          complete_length = marker_end
          return
        end if
        cursor = cursor + marker_length
      else
        cursor = cursor + 1
      end if
    end do
    complete_length = length_value
  end function get_marker_complete_length

  function generate_marker_complete(length_value) result(text)
    integer, intent(in) :: length_value
    character(len=:), allocatable :: text
    text = generate(get_marker_complete_length(length_value))
  end function generate_marker_complete

  function find_first_mismatch(expected, received) result(found)
    character(len=*), intent(in) :: expected, received
    type(mismatch) :: found
    integer :: i, shared

    shared = min(len(expected), len(received))
    do i = 1, shared
      if (expected(i:i) /= received(i:i)) then
        found%has_value = .true.
        found%position = i
        found%has_expected = .true.
        found%expected = expected(i:i)
        found%has_received = .true.
        found%received = received(i:i)
        return
      end if
    end do

    if (len(expected) /= len(received)) then
      found%has_value = .true.
      found%position = shared + 1
      if (found%position <= len(expected)) then
        found%has_expected = .true.
        found%expected = expected(found%position:found%position)
      end if
      if (found%position <= len(received)) then
        found%has_received = .true.
        found%received = received(found%position:found%position)
      end if
    end if
  end function find_first_mismatch

  function find_truncation_point(received_text) result(position)
    character(len=*), intent(in) :: received_text
    integer :: position
    type(mismatch) :: found

    found = find_first_mismatch(generate(len(received_text)), received_text)
    if (found%has_value) then
      position = found%position
    else
      position = len(received_text) + 1
    end if
  end function find_truncation_point

  function validate(received_text, expected_length) result(validation)
    character(len=*), intent(in) :: received_text
    integer, intent(in) :: expected_length
    type(validation_result) :: validation
    character(len=:), allocatable :: expected

    expected = generate(expected_length)
    validation%first_mismatch = find_first_mismatch(expected, received_text)
    validation%is_valid = .not. validation%first_mismatch%has_value
    validation%expected_length = expected_length
    validation%received_length = len(received_text)
    if (validation%first_mismatch%has_value .and. len(received_text) < expected_length) then
      if (expected(1:len(received_text)) == received_text) then
        validation%truncation_point = len(received_text) + 1
      end if
    end if
  end function validate

  function locate(fragment) result(position)
    character(len=*), intent(in) :: fragment
    integer :: position
    character(len=:), allocatable :: tape

    if (len(fragment) == 0) then
      position = 1
      return
    end if

    tape = generate(default_search_length)
    position = index(tape, fragment)
    if (position == 0) position = -1
  end function locate

  function hash_fragment(fragment) result(hash)
    character(len=*), intent(in) :: fragment
    character(len=64) :: hash
    integer :: input_unit, script_unit, output_unit, exitstat
    character(len=*), parameter :: input_file = "position_tape_fortran_hash_input.tmp"
    character(len=*), parameter :: script_file = "position_tape_fortran_hash.pl"
    character(len=*), parameter :: output_file = "position_tape_fortran_hash_output.tmp"
    character(len=512) :: command

    open(newunit=input_unit, file=input_file, access="stream", form="unformatted", status="replace", action="write")
    write(input_unit) fragment
    close(input_unit)

    open(newunit=script_unit, file=script_file, status="replace", action="write")
    write(script_unit, '(A)') "use Digest::SHA qw(sha256_hex);"
    write(script_unit, '(A)') "my ($input, $output) = @ARGV;"
    write(script_unit, '(A)') "open my $in, '<:raw', $input or die $!;"
    write(script_unit, '(A)') "local $/;"
    write(script_unit, '(A)') "my $fragment = <$in>;"
    write(script_unit, '(A)') "open my $out, '>:raw', $output or die $!;"
    write(script_unit, '(A)') "print $out sha256_hex($fragment);"
    close(script_unit)

    command = "perl " // script_file // " " // input_file // " " // output_file
    call execute_command_line(trim(command), exitstat=exitstat)
    if (exitstat /= 0) error stop "Perl Digest::SHA hash command failed"

    open(newunit=output_unit, file=output_file, status="old", action="read")
    read(output_unit, '(A)') hash
    close(output_unit, status="delete")
    open(newunit=input_unit, file=input_file, status="old")
    close(input_unit, status="delete")
    open(newunit=script_unit, file=script_file, status="old")
    close(script_unit, status="delete")
    hash = lowercase(hash)
  end function hash_fragment

  function build_window_index(window_size) result(window_index)
    integer, intent(in) :: window_size
    type(hash_window_index) :: window_index
    character(len=:), allocatable :: tape
    integer :: input_unit, script_unit, output_unit, exitstat, line_count, i
    character(len=*), parameter :: input_file = "position_tape_fortran_index_input.tmp"
    character(len=*), parameter :: script_file = "position_tape_fortran_index.pl"
    character(len=*), parameter :: output_file = "position_tape_fortran_index_output.tmp"
    character(len=512) :: command
    character(len=96) :: line

    if (window_size <= 0) error stop "window_size must be positive"
    if (window_size > default_search_length) error stop "window_size cannot exceed default search length"

    tape = generate(default_search_length)
    window_index%window_size = window_size
    window_index%count = len(tape) - window_size + 1
    allocate(window_index%hashes(window_index%count))
    allocate(window_index%positions(window_index%count))

    open(newunit=input_unit, file=input_file, access="stream", form="unformatted", status="replace", action="write")
    write(input_unit) tape
    close(input_unit)

    open(newunit=script_unit, file=script_file, status="replace", action="write")
    write(script_unit, '(A)') "use Digest::SHA qw(sha256_hex);"
    write(script_unit, '(A)') "my ($window_size, $input, $output) = @ARGV;"
    write(script_unit, '(A)') "open my $in, '<:raw', $input or die $!;"
    write(script_unit, '(A)') "local $/;"
    write(script_unit, '(A)') "my $tape = <$in>;"
    write(script_unit, '(A)') "open my $out, '>:raw', $output or die $!;"
    write(script_unit, '(A)') "my $last = length($tape) - $window_size;"
    write(script_unit, '(A)') "for (my $offset = 0; $offset <= $last; $offset++) {"
    write(script_unit, '(A)') "  print $out sha256_hex(substr($tape, $offset, $window_size)), qq(\t), $offset + 1, qq(\n);"
    write(script_unit, '(A)') "}"
    close(script_unit)

    write(command, '(A,I0,A)') "perl " // script_file // " ", window_size, " " // input_file // " " // output_file
    call execute_command_line(trim(command), exitstat=exitstat)
    if (exitstat /= 0) error stop "Perl Digest::SHA index command failed"

    open(newunit=output_unit, file=output_file, status="old", action="read")
    line_count = 0
    do
      read(output_unit, '(A)', end=10) line
      line_count = line_count + 1
      i = index(line, achar(9))
      window_index%hashes(line_count) = lowercase(line(1:i - 1))
      read(line(i + 1:), *) window_index%positions(line_count)
    end do
10  close(output_unit, status="delete")

    if (line_count /= window_index%count) error stop "hash index output count mismatch"
    open(newunit=input_unit, file=input_file, status="old")
    close(input_unit, status="delete")
    open(newunit=script_unit, file=script_file, status="old")
    close(script_unit, status="delete")
  end function build_window_index

  function locate_by_hash(fragment_hash, window_size) result(positions)
    character(len=*), intent(in) :: fragment_hash
    integer, intent(in) :: window_size
    integer, allocatable :: positions(:)
    type(hash_window_index) :: window_index
    character(len=64) :: normalized_hash
    integer :: i, matches

    window_index = build_window_index(window_size)
    normalized_hash = lowercase(adjustl(fragment_hash))
    matches = 0
    do i = 1, window_index%count
      if (window_index%hashes(i) == normalized_hash) matches = matches + 1
    end do

    allocate(positions(matches))
    matches = 0
    do i = 1, window_index%count
      if (window_index%hashes(i) == normalized_hash) then
        matches = matches + 1
        positions(matches) = window_index%positions(i)
      end if
    end do
  end function locate_by_hash

  function lowercase(value) result(lowered)
    character(len=*), intent(in) :: value
    character(len=len(value)) :: lowered
    integer :: i, code

    lowered = value
    do i = 1, len(value)
      code = iachar(value(i:i))
      if (code >= iachar('A') .and. code <= iachar('Z')) then
        lowered(i:i) = achar(code + 32)
      end if
    end do
  end function lowercase
end module position_tape
