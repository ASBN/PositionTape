DEFAULT_SEARCH_LENGTH <- 100003L
.index_cache <- new.env(parent = emptyenv())

.RunPerlScript <- function(script, args) {
  script_file <- tempfile("position-tape-", fileext = ".pl")
  on.exit(unlink(script_file), add = TRUE)
  writeLines(script, script_file, useBytes = TRUE)
  system2("perl", c(script_file, args), stdout = TRUE, stderr = TRUE)
}

Generate <- function(length) {
  if (length < 0L) {
    stop("length must be non-negative", call. = FALSE)
  }

  parts <- character()
  cursor <- 1L
  remaining <- as.integer(length)

  while (remaining > 0L) {
    if (cursor %% 10L == 0L) {
      marker <- as.character(cursor %/% 10L)
      chunk <- substr(marker, 1L, min(nchar(marker), remaining))
      parts <- c(parts, chunk)
      remaining <- remaining - nchar(chunk)
      cursor <- cursor + nchar(marker)
    } else {
      parts <- c(parts, as.character(cursor %% 10L))
      remaining <- remaining - 1L
      cursor <- cursor + 1L
    }
  }

  paste0(parts, collapse = "")
}

GetMarkerCompleteLength <- function(length) {
  if (length < 0L) {
    stop("length must be non-negative", call. = FALSE)
  }

  cursor <- 1L
  while (cursor <= length) {
    if (cursor %% 10L == 0L) {
      marker_length <- nchar(as.character(cursor %/% 10L))
      marker_end <- cursor + marker_length - 1L
      if (length < marker_end) {
        return(marker_end)
      }
      cursor <- cursor + marker_length
    } else {
      cursor <- cursor + 1L
    }
  }

  length
}

GenerateMarkerComplete <- function(length) {
  Generate(GetMarkerCompleteLength(length))
}

FindFirstMismatch <- function(expected, received) {
  expected_chars <- strsplit(expected, "", fixed = TRUE)[[1]]
  received_chars <- strsplit(received, "", fixed = TRUE)[[1]]
  if (identical(expected, "")) expected_chars <- character()
  if (identical(received, "")) received_chars <- character()

  shared_length <- min(length(expected_chars), length(received_chars))
  if (shared_length > 0L) {
    for (index in seq_len(shared_length)) {
      if (!identical(expected_chars[[index]], received_chars[[index]])) {
        return(list(position = index, expected = expected_chars[[index]], received = received_chars[[index]]))
      }
    }
  }

  if (length(expected_chars) == length(received_chars)) {
    return(NULL)
  }

  position <- shared_length + 1L
  list(
    position = position,
    expected = if (position <= length(expected_chars)) expected_chars[[position]] else NULL,
    received = if (position <= length(received_chars)) received_chars[[position]] else NULL
  )
}

Validate <- function(receivedText, expectedLength) {
  expected <- Generate(expectedLength)
  mismatch <- FindFirstMismatch(expected, receivedText)
  truncation_point <- NULL

  if (!is.null(mismatch) && nchar(receivedText) < expectedLength && startsWith(expected, receivedText)) {
    truncation_point <- nchar(receivedText) + 1L
  }

  list(
    isValid = is.null(mismatch),
    expectedLength = expectedLength,
    receivedLength = nchar(receivedText),
    truncationPoint = truncation_point,
    firstMismatch = mismatch
  )
}

FindTruncationPoint <- function(receivedText) {
  mismatch <- FindFirstMismatch(Generate(nchar(receivedText)), receivedText)
  if (is.null(mismatch)) nchar(receivedText) + 1L else mismatch$position
}

Locate <- function(fragment) {
  if (identical(fragment, "")) {
    return(1L)
  }

  match <- regexpr(fragment, Generate(DEFAULT_SEARCH_LENGTH), fixed = TRUE)[[1]]
  if (match < 0L) -1L else as.integer(match)
}

HashFragment <- function(fragment) {
  if (nzchar(Sys.which("perl"))) {
    input_file <- tempfile("position-tape-fragment-")
    on.exit(unlink(input_file), add = TRUE)
    writeBin(charToRaw(fragment), input_file)

    script <- paste(
      "use Digest::SHA qw(sha256_hex);",
      "my $path = shift @ARGV;",
      "open my $fh, '<:raw', $path or die $!;",
      "local $/;",
      "my $fragment = <$fh>;",
      "print sha256_hex($fragment);",
      sep = "\n"
    )
    output <- .RunPerlScript(script, input_file)
    status <- attr(output, "status")
    if ((is.null(status) || identical(status, 0L)) && length(output) > 0L) {
      return(tolower(trimws(output[[1]])))
    }
  }

  input_file <- tempfile("position-tape-fragment-")
  on.exit(unlink(input_file), add = TRUE)
  writeBin(charToRaw(fragment), input_file)

  if (nzchar(Sys.which("sha256sum"))) {
    output <- system2("sha256sum", input_file, stdout = TRUE, stderr = TRUE)
    status <- attr(output, "status")
    if (is.null(status) || identical(status, 0L)) {
      return(tolower(strsplit(output[[1]], "[[:space:]]+")[[1]][[1]]))
    }
  }

  if (nzchar(Sys.which("shasum"))) {
    output <- system2("shasum", c("-a", "256", input_file), stdout = TRUE, stderr = TRUE)
    status <- attr(output, "status")
    if (is.null(status) || identical(status, 0L)) {
      return(tolower(strsplit(output[[1]], "[[:space:]]+")[[1]][[1]]))
    }
  }

  if (nzchar(Sys.which("openssl"))) {
    output <- system2("openssl", c("dgst", "-sha256", "-r", input_file), stdout = TRUE, stderr = TRUE)
    status <- attr(output, "status")
    if (is.null(status) || identical(status, 0L)) {
      return(tolower(strsplit(output[[1]], "[[:space:]]+")[[1]][[1]]))
    }
  }

  if (nzchar(Sys.which("certutil"))) {
    output <- system2("certutil", c("-hashfile", input_file, "SHA256"), stdout = TRUE, stderr = TRUE)
    status <- attr(output, "status")
    if (is.null(status) || identical(status, 0L)) {
      hashes <- grep("^[[:xdigit:]]{64}$", trimws(output), value = TRUE)
      if (length(hashes) > 0L) {
        return(tolower(hashes[[1]]))
      }
    }
  }

  stop("no SHA-256 command found; install Perl Digest::SHA, sha256sum, shasum, openssl, or certutil", call. = FALSE)
}

BuildWindowIndex <- function(windowSize) {
  if (windowSize <= 0L) {
    stop("windowSize must be positive", call. = FALSE)
  }
  if (windowSize > DEFAULT_SEARCH_LENGTH) {
    stop("windowSize cannot exceed the default search length", call. = FALSE)
  }

  tape <- Generate(DEFAULT_SEARCH_LENGTH)
  index <- new.env(parent = emptyenv())

  if (nzchar(Sys.which("perl"))) {
    tape_file <- tempfile("position-tape-search-")
    on.exit(unlink(tape_file), add = TRUE)
    writeBin(charToRaw(tape), tape_file)

    script <- paste(
      "use Digest::SHA qw(sha256_hex);",
      "my ($window_size, $path) = @ARGV;",
      "open my $fh, '<:raw', $path or die $!;",
      "local $/;",
      "my $tape = <$fh>;",
      "my $last = length($tape) - $window_size;",
      "for (my $offset = 0; $offset <= $last; $offset++) {",
      "  print sha256_hex(substr($tape, $offset, $window_size)), qq(\\t), $offset + 1, qq(\\n);",
      "}",
      sep = "\n"
    )
    output <- .RunPerlScript(script, c(as.character(windowSize), tape_file))
    status <- attr(output, "status")
    if (!is.null(status) && !identical(status, 0L)) {
      stop(paste(output, collapse = "\n"), call. = FALSE)
    }

    for (line in output) {
      fields <- strsplit(line, "\t", fixed = TRUE)[[1]]
      hash <- fields[[1]]
      position <- as.integer(fields[[2]])
      existing <- index[[hash]]
      index[[hash]] <- c(existing, position)
    }

    return(as.list(index))
  }

  last_start <- nchar(tape) - windowSize + 1L
  for (position in seq_len(last_start)) {
    hash <- HashFragment(substr(tape, position, position + windowSize - 1L))
    existing <- index[[hash]]
    index[[hash]] <- c(existing, position)
  }
  as.list(index)
}

LocateByHash <- function(fragmentHash, windowSize) {
  cache_key <- as.character(windowSize)
  if (!exists(cache_key, envir = .index_cache, inherits = FALSE)) {
    assign(cache_key, BuildWindowIndex(windowSize), envir = .index_cache)
  }

  index <- get(cache_key, envir = .index_cache, inherits = FALSE)
  hash <- tolower(trimws(fragmentHash))
  positions <- index[[hash]]
  if (is.null(positions)) integer() else as.integer(positions)
}
