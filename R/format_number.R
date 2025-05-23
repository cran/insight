#' Convert number to words
#'
#' @note
#' The code has been adapted from here https://github.com/ateucher/useful_code/blob/master/R/numbers2words.r
#'
#' @param x Number.
#' @param textual Return words. If `FALSE`, will run [format_value()].
#' @param ... Arguments to be passed to [format_value()] if `textual` is `FALSE`.
#'
#'
#' @return A formatted string.
#' @examples
#' format_number(2)
#' format_number(45)
#' format_number(324.68765)
#' @export
format_number <- function(x, textual = TRUE, ...) {
  if (textual) {
    .format_number(x)
  } else {
    format_value(x, ...)
  }
}


#' @keywords internal
.format_number <- function(x) {
  # https://github.com/ateucher/useful_code/blob/master/R/numbers2words.r
  x <- round(x)

  # Disable scientific notation
  opts <- options(scipen = 100)
  on.exit(options(opts))

  if (length(x) > 1L) {
    return(.trim_ws_and(sapply(x, .format_character_number)))
  }
  .format_character_number(x)
}


## Function by John Fox found here:
## http://tolstoy.newcastle.edu.au/R/help/05/04/2715.html
## Tweaks by AJH to add commas and "and"
.format_character_number <- function(x, ones, tees) {
  ones <- c("", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
  names(ones) <- 0:9

  teens <- c(
    "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
    "sixteen", " seventeen", "eighteen", "nineteen"
  )
  names(teens) <- 0:9

  tens <- c(
    "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty",
    "ninety"
  )
  names(tens) <- 2:9

  suffixes <- c("thousand", "million", "billion", "trillion")

  digits <- rev(strsplit(as.character(x), "", fixed = TRUE)[[1]])
  nDigits <- length(digits)

  if (nDigits == 1) {
    as.vector(ones[digits])
  } else if (nDigits == 2) {
    if (x <= 19) {
      as.vector(teens[digits[1]])
    } else {
      .trim_ws_and(paste(tens[digits[2]], Recall(as.numeric(digits[1]))))
    }
  } else if (nDigits == 3) {
    .trim_ws_and(paste(ones[digits[3]], "hundred and", Recall(.make_number(digits[2:1]))))
  } else {
    nSuffix <- ((nDigits + 2) %/% 3) - 1
    if (nSuffix > length(suffixes)) {
      format_error(paste(x, "is too large!"))
    }
    .trim_ws_and(paste(
      Recall(.make_number(digits[nDigits:(3 * nSuffix + 1)])),
      suffixes[nSuffix], ",",
      Recall(.make_number(digits[(3 * nSuffix):1]))
    ))
  }
}


.make_number <- function(...) {
  as.numeric(paste(..., collapse = ""))
}


.trim_ws_and <- function(text) {
  # Tidy leading/trailing whitespace, space before comma
  text <- gsub("^ ", "", gsub(" *$", "", gsub(" ,", ",", text, fixed = TRUE)))
  # Clear any trailing " and"
  text <- gsub(" and$", "", text)
  # Clear any trailing comma
  gsub("\ *,$", "", text)
}
