#' p-values formatting
#'
#' Format p-values.
#'
#' @param p value or vector of p-values.
#' @param stars Add significance stars (e.g., p < .001***). For Bayes factors,
#' the thresholds for "significant" results are values larger than 3, 10, and 30.
#' @param stars_only Return only significance stars.
#' @param whitespace Logical, if `TRUE` (default), preserves whitespaces. Else,
#'   all whitespace characters are removed from the returned string.
#' @param name Name prefixing the text. Can be `NULL`.
#' @param decimal_separator Character, if not `NULL`, will be used as
#'   decimal separator.
#' @param digits Number of significant digits. May also be `"scientific"`
#'   to return exact p-values in scientific notation, or `"apa"` to use
#'   an APA 7th edition-style for p-values (equivalent to `digits = 3`).
#'   If `"scientific"`, control the number of digits by adding the value as
#'   a suffix, e.g.m `digits = "scientific4"` to have scientific notation
#'   with 4 decimal places.
#' @param ... Arguments from other methods.
#' @inheritParams format_value
#'
#' @return A formatted string.
#' @examples
#' format_p(c(.02, .065, 0, .23))
#' format_p(c(.02, .065, 0, .23), name = NULL)
#' format_p(c(.02, .065, 0, .23), stars_only = TRUE)
#'
#' model <- lm(mpg ~ wt + cyl, data = mtcars)
#' p <- coef(summary(model))[, 4]
#' format_p(p, digits = "apa")
#' format_p(p, digits = "scientific")
#' format_p(p, digits = "scientific2")
#' @export
format_p <- function(p,
                     stars = FALSE,
                     stars_only = FALSE,
                     whitespace = TRUE,
                     name = "p",
                     missing = "",
                     decimal_separator = NULL,
                     digits = 3,
                     ...) {
  # only convert p if it's a valid numeric, or at least coercible to
  # valid numeric values...
  if (!is.numeric(p)) {
    if (!.is_numeric_character(p)) {
      return(p)
    }
    p <- .factor_to_numeric(p)
  }

  if (identical(stars, "only")) {
    stars <- TRUE
    stars_only <- TRUE
  }

  if (digits == "apa") {
    digits <- 3
  }

  if (is.character(digits) && grepl("scientific", digits, fixed = TRUE)) {
    digits <- tryCatch(as.numeric(gsub("scientific", "", digits, fixed = TRUE)),
      error = function(e) NA
    )
    if (is.na(digits)) {
      digits <- 5
    }
    p_text <- ifelse(is.na(p), NA,
      ifelse(p < 0.001, sprintf("= %.*e***", digits, p), # nolint
        ifelse(p < 0.01, sprintf("= %.*e**", digits, p), # nolint
          ifelse(p < 0.05, sprintf("= %.*e*", digits, p), # nolint
            ifelse(p > 0.999, sprintf("= %.*e", digits, p), # nolint
              sprintf("= %.*e", digits, p)
            )
          )
        )
      )
    )
  } else if (digits <= 3) {
    p_text <- ifelse(is.na(p), NA,
      ifelse(p < 0.001, "< .001***", # nolint
        ifelse(p < 0.01, paste0("= ", format_value(p, digits), "**"), # nolint
          ifelse(p < 0.05, paste0("= ", format_value(p, digits), "*"), # nolint
            ifelse(p > 0.999, "> .999", # nolint
              paste0("= ", format_value(p, digits))
            )
          )
        )
      )
    )
  } else {
    p_text <- ifelse(is.na(p), NA,
      ifelse(p < 0.001, paste0("= ", format_value(p, digits), "***"), # nolint
        ifelse(p < 0.01, paste0("= ", format_value(p, digits), "**"), # nolint
          ifelse(p < 0.05, paste0("= ", format_value(p, digits), "*"), # nolint
            paste0("= ", format_value(p, digits))
          )
        )
      )
    )
  }

  .add_prefix_and_remove_stars(p_text, stars, stars_only, name, missing, whitespace, decimal_separator)
}


#' @keywords internal
.add_prefix_and_remove_stars <- function(p_text,
                                         stars,
                                         stars_only,
                                         name,
                                         missing = "",
                                         whitespace = TRUE,
                                         decimal_separator = NULL,
                                         inferiority_star = "\u00B0") {
  missing_index <- is.na(p_text)

  if (is.null(name)) {
    p_text <- gsub("= ", "", p_text, fixed = TRUE)
  } else {
    p_text <- paste(name, p_text)
  }

  if (stars_only) {
    if (is.null(inferiority_star)) {
      p_text <- gsub(paste0("[^(\\*)]"), "", p_text)
    } else {
      p_text <- gsub(paste0("[^(\\*|", inferiority_star, ")]"), "", p_text)
    }
  } else if (!stars) {
    p_text <- gsub("*", "", p_text, fixed = TRUE)
    if (!is.null(inferiority_star)) {
      p_text <- gsub(inferiority_star, "", p_text, fixed = TRUE)
    }
  }

  # replace missing with related string
  p_text[missing_index] <- missing

  # remove whitespace around < and >
  if (isFALSE(whitespace)) {
    p_text <- gsub(" ", "", p_text, fixed = TRUE)
  }

  # replace decimal separator
  if (!is.null(decimal_separator)) {
    p_text <- gsub(".", decimal_separator, p_text, fixed = TRUE)
  }

  p_text
}
