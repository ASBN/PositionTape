module position_tape
  implicit none

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
end module position_tape
