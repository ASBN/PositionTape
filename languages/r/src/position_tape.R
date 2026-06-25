DEFAULT_SEARCH_LENGTH <- 100003L

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
