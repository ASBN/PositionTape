source("languages/r/src/position_tape.R")

stopifnot(identical(Generate(0), ""))
stopifnot(identical(Generate(11), "12345678911"))
stopifnot(nchar(Generate(100)) == 100L)
stopifnot(nchar(GenerateMarkerComplete(100)) == 101L)
stopifnot(nchar(GenerateMarkerComplete(10000)) == 10003L)

valid <- Validate(Generate(250), 250L)
stopifnot(isTRUE(valid$isValid))

truncated <- Validate(Generate(40), 50L)
stopifnot(!isTRUE(truncated$isValid))
stopifnot(identical(truncated$truncationPoint, 41L))

mutated <- Generate(60)
substr(mutated, 20L, 20L) <- "X"
mismatch <- FindFirstMismatch(Generate(60), mutated)
stopifnot(identical(mismatch$position, 20L))

stopifnot(identical(FindTruncationPoint(Generate(75)), 76L))
stopifnot(identical(Locate("9910"), 99L))

cat("OK r\n")
