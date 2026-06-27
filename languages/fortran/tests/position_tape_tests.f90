program position_tape_tests
  use position_tape
  implicit none

  type(validation_result) :: result
  type(mismatch) :: found
  type(hash_window_index) :: index_result
  integer, allocatable :: positions(:)
  character(len=:), allocatable :: tape, fragment
  character(len=64) :: hash

  call check(generate(0) == "", "zero length")
  call check(generate(11) == "12345678911", "basic generation")
  call check(len(generate(100)) == 100, "exact length")
  call check(len(generate_marker_complete(100)) == 101, "marker complete 100")
  call check(len(generate_marker_complete(10000)) == 10003, "marker complete 10000")

  result = validate(generate(250), 250)
  call check(result%is_valid, "valid tape")

  result = validate(generate(40), 50)
  call check(.not. result%is_valid, "truncated invalid")
  call check(result%truncation_point == 41, "truncation point")

  found = find_first_mismatch(generate(20), generate(19) // "X")
  call check(found%has_value .and. found%position == 20, "mismatch")

  tape = generate(80)
  fragment = tape(30:41)
  call check(locate(fragment) == 30, "locate")
  hash = hash_fragment(fragment)
  index_result = build_window_index(len(fragment))
  call check(any(index_result%hashes == hash .and. index_result%positions == 30), "hash index")
  positions = locate_by_hash(hash, len(fragment))
  call check(any(positions == 30), "locate by hash")

  print *, "OK fortran"

contains
  subroutine check(condition, message)
    logical, intent(in) :: condition
    character(len=*), intent(in) :: message
    if (.not. condition) error stop message
  end subroutine check
end program position_tape_tests
