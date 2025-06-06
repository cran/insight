#' Remove empty elements from lists
#'
#' @param x A list or vector.
#' @param remove_na Logical to decide if `NA`s should be removed.
#'
#' @examples
#' compact_list(list(NULL, 1, c(NA, NA)))
#' compact_list(c(1, NA, NA))
#' compact_list(c(1, NA, NA), remove_na = TRUE)
#' @export
compact_list <- function(x, remove_na = FALSE) {
  if (remove_na) {
    x[
      !sapply(x, function(i) {
        !is_model(i) &&
          !inherits(i, c("Formula", "gFormula")) &&
          !is.function(i) &&
          (all(is.na(i)) || any(.safe(as.character(i) == "NULL", FALSE), na.rm = TRUE))
      })
    ]
  } else {
    x[
      !sapply(x, function(i) {
        !is_model(i) &&
          !inherits(i, c("Formula", "gFormula")) &&
          !is.function(i) &&
          (length(i) == 0L ||
            is.null(i) ||
            any(.safe(as.character(i) == "NULL", FALSE), na.rm = TRUE))
      })
    ]
  }
}

#' Remove empty strings from character
#'
#' @param x A single character or a vector of characters.
#'
#' @return
#'
#' A character or a character vector with empty strings removed.
#'
#' @examples
#' compact_character(c("x", "y", NA))
#' compact_character(c("x", "NULL", "", "y"))
#'
#' @export
compact_character <- function(x) {
  x[
    !sapply(x, function(i) {
      !nzchar(i, keepNA = TRUE) ||
        all(is.na(i)) ||
        any(as.character(i) == "NULL", na.rm = TRUE)
    })
  ]
}
