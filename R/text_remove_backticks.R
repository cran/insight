#' @title Remove backticks from a string
#' @name text_remove_backticks
#'
#' @description This function removes backticks from a string.
#'
#' @param x A character vector, a data frame or a matrix. If a matrix,
#'   backticks are removed from the column and row names, not from values
#'   of a character vector.
#' @param column If `x` is a data frame, specify the column of character
#'   vectors, where backticks should be removed. If `NULL`, all character
#'   vectors are processed.
#' @param verbose Toggle warnings.
#' @param ... Currently not used.
#'
#' @return `x`, where all backticks are removed.
#'
#' @note If `x` is a character vector or data frame, backticks are removed from
#'   the elements of that character vector (or character vectors from the data
#'   frame.) If `x` is a matrix, the behaviour slightly differs: in this case,
#'   backticks are removed from the column and row names. The reason for this
#'   behaviour is that this function mainly serves formatting coefficient names.
#'   For `vcov()` (a matrix), row and column names equal the coefficient names
#'   and therefore are manipulated then.
#'
#' @examples
#' # example model
#' data(iris)
#' iris$`a m` <- iris$Species
#' iris$`Sepal Width` <- iris$Sepal.Width
#' model <- lm(`Sepal Width` ~ Petal.Length + `a m`, data = iris)
#'
#' # remove backticks from string
#' names(coef(model))
#' text_remove_backticks(names(coef(model)))
#'
#' # remove backticks from character variable in a data frame
#' # column defaults to "Parameter".
#' d <- data.frame(
#'   Parameter = names(coef(model)),
#'   Estimate = unname(coef(model))
#' )
#' d
#' text_remove_backticks(d)
#' @export
text_remove_backticks <- function(x, ...) {
  UseMethod("text_remove_backticks")
}


#' @export
text_remove_backticks.default <- function(x, verbose = FALSE, ...) {
  if (isTRUE(verbose)) {
    format_warning(
      paste0("Removing backticks currently not supported for objects of class '", class(x)[1], "'.")
    )
  }
  x
}


#' @rdname text_remove_backticks
#' @export
text_remove_backticks.data.frame <- function(x, column = "Parameter", verbose = FALSE, ...) {
  if (is.null(column)) {
    column <- colnames(x)[vapply(x, is.character, logical(1))]
  }
  not_found <- vector("character")
  for (i in column) {
    if (i %in% colnames(x) && is.character(x[[i]])) {
      x[[i]] <- gsub("`", "", x[[i]], fixed = TRUE)
    } else {
      not_found <- c(not_found, i)
    }
  }
  if (verbose && length(not_found)) {
    format_warning(
      "Following columns were not found or were no character vectors:",
      toString(not_found)
    )
  }
  x
}


#' @export
text_remove_backticks.list <- function(x, verbose = FALSE, ...) {
  lapply(x, text_remove_backticks, verbose = verbose)
}


#' @export
text_remove_backticks.character <- function(x, ...) {
  if (!is.null(x)) {
    x <- gsub("`", "", x, fixed = TRUE)
  }
  x
}


#' @export
text_remove_backticks.factor <- function(x, ...) {
  text_remove_backticks(as.character(x))
}


#' @export
text_remove_backticks.matrix <- function(x, ...) {
  colnames(x) <- text_remove_backticks(colnames(x))
  rownames(x) <- text_remove_backticks(rownames(x))
  x
}
