#' Confidence/Credible Interval (CI) Formatting
#'
#' @param CI_low Lower CI bound. Usually a numeric value, but can also be a
#'    CI output returned `bayestestR`, in which case the remaining arguments
#'    are unnecessary.
#' @param CI_high Upper CI bound.
#' @param ci CI level in percentage.
#' @param brackets Either a logical, and if `TRUE` (default), values are
#'   encompassed in square brackets. If `FALSE` or `NULL`, no brackets
#'   are used. Else, a character vector of length two, indicating the opening
#'   and closing brackets.
#' @param width Minimum width of the returned string. If not `NULL` and
#'   `width` is larger than the string's length, leading whitespaces are
#'   added to the string. If `width="auto"`, width will be set to the
#'   length of the longest string.
#' @param width_low,width_high Like `width`, but only applies to the lower
#'   or higher confidence interval value. This can be used when the values for
#'   the lower and upper CI are of very different length.
#' @param ci_string String to be used in the output to indicate the type of
#' interval. Default is `"CI"`, but can be changed to `"HDI"` or anything else,
#' if necessary.
#' @inheritParams format_value
#'
#' @return A formatted string.
#' @examples
#' format_ci(1.20, 3.57, ci = 0.90)
#' format_ci(1.20, 3.57, ci = NULL)
#' format_ci(1.20, 3.57, ci = NULL, brackets = FALSE)
#' format_ci(1.20, 3.57, ci = NULL, brackets = c("(", ")"))
#' format_ci(c(1.205645, 23.4), c(3.57, -1.35), ci = 0.90)
#' format_ci(c(1.20, NA, NA), c(3.57, -1.35, NA), ci = 0.90)
#'
#' # automatic alignment of width, useful for printing multiple CIs in columns
#' x <- format_ci(c(1.205, 23.4, 100.43), c(3.57, -13.35, 9.4))
#' cat(x, sep = "\n")
#'
#' x <- format_ci(c(1.205, 23.4, 100.43), c(3.57, -13.35, 9.4), width = "auto")
#' cat(x, sep = "\n")
#' @export
format_ci <- function(CI_low, ...) {
  UseMethod("format_ci")
}


#' @export
format_ci.logical <- function(CI_low, ...) {
  ""
}


#' @rdname format_ci
#' @export
format_ci.numeric <- function(CI_low,
                              CI_high,
                              ci = 0.95,
                              digits = 2,
                              brackets = TRUE,
                              width = NULL,
                              width_low = width,
                              width_high = width,
                              missing = "",
                              zap_small = FALSE,
                              ci_string = "CI",
                              ...) {
  # check proper defaults
  if (isTRUE(brackets)) {
    ci_brackets <- c("[", "]")
  } else if (is.null(brackets) || isFALSE(brackets)) {
    ci_brackets <- c("", "")
  } else {
    ci_brackets <- brackets
  }

  if (!is.null(width) && all(width == "auto")) {
    # set default numeric value for digits
    sig_digits <- digits

    # check if we have special handling, like "scientific" or "signif"
    # and then convert to numeric
    if (is.character(digits)) {
      if (startsWith(digits, "scientific")) {
        if (digits == "scientific") digits <- "scientific3"
        sig_digits <- as.numeric(gsub("scientific", "", digits, fixed = TRUE)) + 3
      } else {
        if (digits == "signif") digits <- "signif2"
        sig_digits <- as.numeric(gsub("signif", "", digits, fixed = TRUE))
      }
    }

    # round CI-values for standard rounding, or scientific
    if (is.numeric(CI_low) && is.numeric(CI_high)) {
      if (is.numeric(digits) || (is.character(digits) && grepl("scientific", digits, fixed = TRUE))) {
        CI_low <- round(CI_low, sig_digits)
        CI_high <- round(CI_high, sig_digits)
      } else {
        CI_low <- signif(CI_low, digits = sig_digits)
        CI_high <- signif(CI_high, digits = sig_digits)
      }
    }

    if (all(is.na(CI_low) | is.infinite(CI_low))) {
      width_low <- 1
    } else {
      width_low <- max(unlist(lapply(stats::na.omit(CI_low), function(.i) {
        if (.i > 1e+5) {
          6 + digits
        } else {
          nchar(as.character(.i))
        }
      }), use.names = FALSE))
    }

    if (all(is.na(CI_high) | is.infinite(CI_high))) {
      width_high <- 1
    } else {
      width_high <- max(unlist(lapply(stats::na.omit(CI_high), function(.i) {
        if (.i > 1e+5) {
          6 + digits
        } else {
          nchar(as.character(.i))
        }
      }), use.names = FALSE))
    }
  }

  if (is.na(missing)) missing <- NA_character_

  if (is.null(ci)) {
    ifelse(
      is.na(CI_low) & is.na(CI_high),
      missing,
      .format_ci(
        CI_low,
        CI_high,
        digits = digits,
        ci_brackets = ci_brackets,
        width_low = width_low,
        width_high = width_high,
        missing = missing,
        zap_small = zap_small
      )
    )
  } else {
    ifelse(is.na(CI_low) & is.na(CI_high),
      missing,
      paste0(
        ci * 100,
        "% ",
        ci_string,
        " ",
        .format_ci(
          CI_low,
          CI_high,
          digits = digits,
          ci_brackets = ci_brackets,
          width_low = width_low,
          width_high = width_high,
          missing = missing,
          zap_small = zap_small
        )
      )
    )
  }
}

#' @export
format_ci.factor <- format_ci.numeric

#' @export
format_ci.character <- format_ci.numeric


# bayestestR objects ------------------------------------------------------

#' @export
format_ci.bayestestR_ci <- function(CI_low, ci_string = NULL, ...) {
  # find default for ci_string
  if (is.null(ci_string)) {
    ci_string <- ifelse(inherits(CI_low, "bayestestR_hdi"), "HDI", "ETI")
  }
  x <- as.data.frame(CI_low)
  format_ci(
    CI_low = x$CI_low,
    CI_high = x$CI_high,
    ci = x$CI,
    ci_string = ci_string,
    ...
  )
}


# data frames ------------------------------------------------------

#' @export
format_ci.data.frame <- function(CI_low, ci_string = "CI", ...) {
  # nicer name
  x <- CI_low
  format_ci(
    CI_low = x$CI_low,
    CI_high = x$CI_high,
    ci = x$CI,
    ci_string = ci_string,
    ...
  )
}


# Convenience function ----------------------------------------------------


#' @keywords internal
.format_ci <- function(CI_low,
                       CI_high,
                       digits = 2,
                       ci_brackets = c("[", "]"),
                       width_low = NULL,
                       width_high = NULL,
                       missing = "NA",
                       zap_small = FALSE) {
  paste0(
    ci_brackets[1],
    format_value(
      CI_low,
      digits = digits,
      missing = missing,
      width = width_low,
      zap_small = zap_small
    ),
    ", ",
    format_value(
      CI_high,
      digits = digits,
      missing = missing,
      width = width_high,
      zap_small = zap_small
    ),
    ci_brackets[2]
  )
}
