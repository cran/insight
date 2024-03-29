#' @title Checks if all objects are models of same class
#' @name all_models_equal
#'
#' @description Small helper that checks if all objects are *supported*
#'  (regression) model objects and of same class.
#'
#' @param ... A list of objects.
#' @inheritParams get_variance
#'
#' @return A logical, `TRUE` if `x` are all supported model objects
#'   of same class.
#'
#' @examplesIf require("lme4", quietly = TRUE)
#' data(mtcars)
#' data(sleepstudy, package = "lme4")
#'
#' m1 <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#' m2 <- lm(mpg ~ wt + cyl, data = mtcars)
#' m3 <- lme4::lmer(Reaction ~ Days + (1 | Subject), data = sleepstudy)
#' m4 <- glm(formula = vs ~ wt, family = binomial(), data = mtcars)
#'
#' all_models_same_class(m1, m2)
#' all_models_same_class(m1, m2, m3)
#' all_models_same_class(m1, m4, m2, m3, verbose = TRUE)
#' all_models_same_class(m1, m4, mtcars, m2, m3, verbose = TRUE)
#' @export
all_models_equal <- function(..., verbose = FALSE) {
  model_objects <- list(...)
  object_names <- match.call(expand.dots = FALSE)[["..."]]

  all_supported <- vapply(model_objects, is_model_supported, FUN.VALUE = logical(1))
  all_classes <- sapply(model_objects, class)

  if (is.matrix(all_classes)) {
    all_classes <- as.vector(all_classes[1, ])
  } else if (is.list(all_classes)) {
    all_classes <- sapply(all_classes, function(i) i[1])
  }

  all_equal <- all(
    vapply(all_classes[-1], identical, all_classes[1], FUN.VALUE = logical(1))
  )

  if (!all(all_supported) && verbose) {
    differ <- which(!all_supported)

    m1 <- "Following objects are no (supported) models:"
    m2 <- toString(sprintf("%s", object_names[differ]))

    format_alert(paste(m1, m2, collapse = " "))
  }

  if (!all(all_equal) && verbose) {
    differ <- which(!duplicated(all_classes))

    m1 <- sprintf(
      "Following objects are not identical with %s (of class \"%s\"):",
      object_names[1],
      all_classes[[1]]
    )

    m2 <- toString(
      sprintf(
        "%s (\"%s\")",
        object_names[differ[-1]],
        sapply(all_classes[differ[-1]], function(x) as.vector(x[[1]]))
      )
    )

    format_alert(paste(m1, m2, collapse = " "))
  }

  all(all_supported) && all(all_equal)
}


#' @rdname all_models_equal
#' @export
all_models_same_class <- all_models_equal
