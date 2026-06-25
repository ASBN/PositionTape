# Scratch Level 1 Block Algorithm

Variables:

- `requestedLength`
- `cursor`
- `marker`
- `remaining`
- `take`
- `tape`

Custom block:

```text
define Generate PositionTape (requestedLength)
set [tape v] to []
set [cursor v] to [1]
repeat until <(length of (tape)) = (requestedLength)>
  if <((cursor) mod (10)) = [0]> then
    set [marker v] to ((cursor) / (10))
    set [remaining v] to ((requestedLength) - (length of (tape)))
    if <(length of (marker)) > (remaining)> then
      set [take v] to (remaining)
    else
      set [take v] to (length of (marker))
    end
    set [tape v] to (join (tape) (letters (1) to (take) of (marker)))
    change [cursor v] by (length of (marker))
  else
    set [tape v] to (join (tape) ((cursor) mod (10)))
    change [cursor v] by (1)
  end
end
```

Expected spot checks:

- `requestedLength = 0` produces an empty `tape`.
- `requestedLength = 9` produces `123456789`.
- `requestedLength = 11` produces `12345678911`.
- `requestedLength = 100` produces a `tape` length of `100`.
