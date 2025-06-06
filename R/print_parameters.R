#' @title Prepare summary statistics of model parameters for printing
#' @name print_parameters
#'
#' @description
#'
#' This function takes a data frame, typically a data frame with information on
#' summaries of model parameters like [bayestestR::describe_posterior()],
#' [bayestestR::hdi()] or [parameters::model_parameters()], as input and splits
#' this information into several parts, depending on the model. See details
#' below.
#'
#' @param x A fitted model, or a data frame returned by [clean_parameters()].
#' @param ... One or more objects (data frames), which contain information about
#'   the model parameters and related statistics (like confidence intervals, HDI,
#'   ROPE, ...).
#' @param by `by` should be a character vector with one or more of the following
#' elements: `"Effects"`, `"Component"`, `"Response"` and `"Group"`. These are
#' the column names returned by [clean_parameters()], which is used to extract
#' the information from which the group or component model parameters belong.
#' If `NULL`, the merged data frame is returned. Else, the data frame is split
#' into a list, split by the values from those columns defined in `by`.
#' @param format Name of output-format, as string. If `NULL` (or `"text"`),
#'   assumed use for output is basic printing. If `"markdown"`, markdown-format
#'   is assumed. This only affects the style of title- and table-caption
#'   attributes, which are used in [export_table()].
#' @param parameter_column String, name of the column that contains the
#'   parameter names. Usually, for data frames returned by functions the
#'   easystats-packages, this will be `"Parameter"`.
#' @param keep_parameter_column Logical, if `TRUE`, the data frames in the
#'   returned list have both a `"Cleaned_Parameter"` and `"Parameter"`
#'   column. If `FALSE`, the (unformatted) `"Parameter"` is removed,
#'   and the column with cleaned parameter names (`"Cleaned_Parameter"`) is
#'   renamed into `"Parameter"`.
#' @param remove_empty_column Logical, if `TRUE`, columns with completely
#'   empty character values will be removed.
#' @param titles,subtitles By default, the names of the model components (like
#'   fixed or random effects, count or zero-inflated model part) are added as
#'   attributes `"table_title"` and `"table_subtitle"` to each list
#'   element returned by `print_parameters()`. These attributes are then
#'   extracted and used as table (sub) titles in [export_table()].
#'   Use `titles` and `subtitles` to override the default attribute
#'   values for `"table_title"` and `"table_subtitle"`. `titles`
#'   and `subtitles` may be any length from 1 to same length as returned
#'   list elements. If `titles` and `subtitles` are shorter than
#'   existing elements, only the first default attributes are overwritten.
#'
#' @return
#'
#' A data frame or a list of data frames (if `by` is not `NULL`). If a
#' list is returned, the element names reflect the model components where the
#' extracted information in the data frames belong to, e.g.
#' `random.zero_inflated.Intercept: persons`. This is the data frame that
#' contains the parameters for the random effects from group-level "persons"
#' from the zero-inflated model component.
#'
#' @details This function prepares data frames that contain information
#' about model parameters for clear printing.
#'
#' First, `x` is required, which should either be a model object or a
#' prepared data frame as returned by [clean_parameters()]. If
#' `x` is a model, `clean_parameters()` is called on that model
#' object to get information with which model components the parameters
#' are associated.
#'
#' Then, `...` take one or more data frames that also contain information
#' about parameters from the same model, but also have additional information
#' provided by other methods. For instance, a data frame in `...` might
#' be the result of, for instance, [bayestestR::describe_posterior()],
#' or [parameters::model_parameters()], where we have a) a
#' `Parameter` column and b) columns with other parameter values (like
#' CI, HDI, test statistic, etc.).
#'
#' Now we have a data frame with model parameters and information about the
#' association to the different model components, a data frame with model
#' parameters, and some summary statistics. `print_parameters()` then merges
#' these data frames, so the parameters or statistics of interest are also
#' associated with the different model components. The data frame is split into
#' a list, so for a clear printing. Users can loop over this list and print each
#' component for a better overview. Further, parameter names are "cleaned", if
#' necessary, also for a cleaner print. See also 'Examples'.
#'
#' @examplesIf require("curl", quietly = TRUE) && curl::has_internet() && all(insight::check_if_installed(c("bayestestR", "httr2", "brms"), quietly = TRUE))
#' \donttest{
#' library(bayestestR)
#' model <- download_model("brms_zi_2")
#' x <- hdi(model, effects = "all", component = "all")
#'
#' # hdi() returns a data frame; here we use only the
#' # information on parameter names and HDI values
#' tmp <- as.data.frame(x)[, 1:4]
#' tmp
#'
#' # Based on the "by" argument, we get a list of data frames that
#' # is split into several parts that reflect the model components.
#' print_parameters(model, tmp)
#'
#' # This is the standard print()-method for "bayestestR::hdi"-objects.
#' # For printing methods, it is easy to print complex summary statistics
#' # in a clean way to the console by splitting the information into
#' # different model components.
#' x
#' }
#' @export
print_parameters <- function(x,
                             ...,
                             by = c("Effects", "Component", "Group", "Response"),
                             format = "text",
                             parameter_column = "Parameter",
                             keep_parameter_column = TRUE,
                             remove_empty_column = FALSE,
                             titles = NULL,
                             subtitles = NULL) {
  obj <- list(...)

  # save attributes of original object
  att <- do.call(c, compact_list(lapply(obj, function(i) {
    a <- attributes(i)
    a$names <- a$class <- a$row.names <- NULL
    a
  })))
  att <- att[!duplicated(names(att))]

  # get cleaned parameters
  if (inherits(x, "clean_parameters")) {
    cp <- x
  } else {
    cp <- clean_parameters(x)
  }

  # merge all objects together
  obj <- Reduce(
    function(x, y) {
      # check for valid column name
      if (parameter_column != "Parameter" &&
        parameter_column %in% colnames(y) &&
        !"Parameter" %in% colnames(y)) {
        colnames(y)[colnames(y) == parameter_column] <- "Parameter"
      }
      merge_by <- unique(c(
        "Parameter",
        intersect(colnames(y), intersect(c("Effects", "Component", "Group", "Response"), colnames(x)))
      ))
      merge(x, y, all.x = FALSE, by = merge_by, sort = FALSE)
    },
    c(list(cp), obj)
  )

  # return merged data frame if no splitting requested
  if (is_empty_object(by)) {
    return(obj)
  }

  # determine where to split data frames
  by <- by[by %in% colnames(obj)]

  # convert to factor, to preserve correct order
  obj[by] <- lapply(obj[by], function(i) {
    factor(i, levels = unique(i))
  })

  # split into groups, remove empty elements
  out <- split(obj, obj[by])
  out <- compact_list(lapply(out, function(i) {
    if (nrow(i) > 0L) i
  }))

  # remove trailing dots
  names(out) <- list_names <- gsub("(.*)\\.$", "\\1", names(out))

  has_zeroinf <- any(grepl("(zero_inflated|zi)", names(out)))

  # create title attributes, and remove unnecessary columns from output
  out <- lapply(names(out), function(i) {
    # init title variables
    title1 <- title2 <- ""

    # get data frame
    element <- out[[i]]

    # split name at ".", so we have all components the data frame refers to (i.e.
    # fixed/random, conditional/zero-inflated, group-lvl or random slope etc.)
    # as character vector
    parts <- unlist(strsplit(i, ".", fixed = TRUE))

    # iterate all parts of the component names, to create title attribute
    for (j in seq_along(parts)) {
      # Rename "fixed", "random" etc. into proper titles. Here we have the
      # "Main title" of a subcomponent (like "Random effects")
      if (parts[j] %in% c("fixed", "random") || (has_zeroinf && parts[j] %in% c("conditional", "zi", "zero_inflated"))) {
        tmp <- switch(parts[j],
          fixed = "Fixed effects",
          random = "Random effects",
          dispersion = "Dispersion",
          conditional = "(conditional)",
          zi = ,
          zero_inflated = "(zero-inflated)"
        )
        title1 <- paste0(title1, " ", tmp)
      } else if (!parts[j] %in% c("conditional", "zi", "zero_inflated")) {
        # here we have the "subtitles" of a subcomponent
        # (like "Intercept: Group-Level 1")
        tmp <- switch(parts[j],
          simplex = "(monotonic effects)",
          paste0("(", parts[j], ")")
        )
        title2 <- paste0(title2, " ", tmp)
      }
    }

    .effects <- unique(element$Effects)
    .component <- unique(element$Component)
    .group <- unique(element$Group)

    # we don't need "Effects" and "Component" column any more, and probably
    # also no longer the "Group" column
    columns_to_remove <- c("Effects", "Component", "Cleaned_Parameter")
    if (has_single_value(.group, remove_na = TRUE)) {
      columns_to_remove <- c(columns_to_remove, "Group")
    } else {
      .group <- NULL
    }
    keep <- setdiff(colnames(element), columns_to_remove)
    element <- element[, c("Cleaned_Parameter", keep)]

    # if we had a pretty_names attributes in the original object,
    # match parameters of pretty names here, and add this attributes
    # to each element here...
    if ("pretty_names" %in% names(att)) {
      attr(element, "pretty_names") <- stats::setNames(att$pretty_names[element$Parameter], element$Cleaned_Parameter)
    }

    # keep or remove old parameter column?
    if (!isTRUE(keep_parameter_column)) {
      element$Parameter <- NULL
      colnames(element)[colnames(element) == "Cleaned_Parameter"] <- "Parameter"
    }

    # remove empty columns
    if (isTRUE(remove_empty_column)) {
      for (j in colnames(element)) {
        if (all(is.na(element[[j]])) || (is.character(element[[j]]) && all(element[[j]] == ""))) { # nolint
          element[[j]] <- NULL
        }
      }
    }

    # for sub-table titles
    if (is.null(format) || format == "text") {
      title_prefix <- "# "
    } else {
      title_prefix <- ""
    }

    title1 <- format_capitalize(title1)
    title2 <- format_capitalize(title2)

    # add attributes
    attr(element, "main_title") <- trim_ws(title1)
    attr(element, "sub_title") <- trim_ws(title2)
    if (is.null(format) || format == "text") {
      attr(element, "table_caption") <- c(paste0(title_prefix, trim_ws(title1)), "blue")
      attr(element, "table_subtitle") <- c(trim_ws(title2), "blue")
    } else {
      attr(element, "table_caption") <- trim_ws(title1)
      attr(element, "table_subtitle") <- trim_ws(title2)
    }
    attr(element, "Effects") <- .effects
    attr(element, "Component") <- .component
    attr(element, "Group") <- .group

    element
  })

  # override titles?
  if (!is.null(titles) && length(titles) <= length(out)) {
    for (i in seq_along(titles)) {
      attr(out[[i]], "table_caption") <- c(titles[i], "blue")
    }
  }

  if (!is.null(subtitles) && length(subtitles) <= length(out)) {
    for (i in seq_along(subtitles)) {
      attr(out[[i]], "table_subtitle") <- c(subtitles[i], "blue")
    }
  }

  att$pretty_names <- NULL
  attr(out, "additional_attributes") <- att
  names(out) <- list_names
  out
}
