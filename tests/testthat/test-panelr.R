skip_if_not_installed("panelr")

data("WageData", package = "panelr")
wages <- panelr::panel_data(WageData, id = id, wave = t)
m1 <- panelr::wbm(lwage ~ lag(union) + wks | blk + fem | blk * lag(union), data = wages)
m2 <- panelr::wbm(lwage ~ lag(union) + wks | blk + t | (t | id), data = wages)

test_that("model_info", {
  expect_true(model_info(m1)$is_linear)
  expect_true(model_info(m2)$is_linear)
})

test_that("id_mixed", {
  expect_true(is_mixed_model(m1))
  expect_true(is_mixed_model(m2))
})

test_that("find_predictors", {
  expect_identical(
    find_predictors(m1),
    list(
      conditional = c("union", "wks"),
      instruments = c("blk", "fem"),
      interactions = c("blk", "union")
    )
  )
  expect_identical(
    find_predictors(m1, flatten = TRUE),
    c("union", "wks", "blk", "fem")
  )
  expect_null(find_predictors(m1, effects = "random"))

  expect_identical(
    find_predictors(m2),
    list(
      conditional = c("union", "wks"),
      instruments = c("blk", "t")
    )
  )
  expect_identical(find_predictors(m2, effects = "random"), list(random = "id"))
})

test_that("find_random", {
  expect_null(find_random(m1))
  expect_identical(find_random(m2), list(random = "id"))
})

test_that("get_random", {
  expect_warning(expect_null(get_random(m1)))
  expect_identical(get_random(m2)[[1]], model.frame(m2)$id)
})

test_that("find_response", {
  expect_identical(find_response(m1), "lwage")
})

test_that("get_response", {
  expect_identical(get_response(m1), model.frame(m1)$lwage)
})

test_that("get_predictors", {
  expect_identical(
    colnames(get_predictors(m1)),
    c("lag(union)", "wks", "blk", "fem")
  )
  expect_identical(
    colnames(get_predictors(m2)),
    c("lag(union)", "wks", "blk", "t")
  )
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), 0.2, tolerance = 1e-5)
})

test_that("clean_parameters", {
  cp <- clean_parameters(m1)
  expect_identical(
    cp$Cleaned_Parameter,
    c(
      "union", "wks", "(Intercept)", "imean(lag(union))", "imean(wks)",
      "blk", "fem", "union:blk"
    )
  )
  expect_identical(
    cp$Component,
    c(
      "conditional", "conditional", "instruments", "instruments",
      "instruments", "instruments", "instruments", "interactions"
    )
  )
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 3570L)
  expect_identical(
    colnames(get_data(m1)),
    c(
      "lwage",
      "id",
      "t",
      "lag(union)",
      "wks",
      "blk",
      "fem",
      "imean(lag(union))",
      "imean(wks)",
      "imean(lag(union):blk)",
      "lag(union):blk"
    )
  )
  expect_identical(
    colnames(get_data(m2)),
    c(
      "lwage",
      "id",
      "t",
      "lag(union)",
      "wks",
      "blk",
      "imean(lag(union))",
      "imean(wks)"
    )
  )
})

test_that("find_formula", {
  expect_length(find_formula(m1), 3)
  expect_equal(
    find_formula(m1),
    list(
      conditional = as.formula("lwage ~ lag(union) + wks"),
      instruments = as.formula("~blk + fem"),
      interactions = as.formula("~blk * lag(union)")
    ),
    ignore_attr = TRUE
  )

  expect_equal(
    find_formula(m2),
    list(
      conditional = as.formula("lwage ~ lag(union) + wks"),
      instruments = as.formula("~blk + t"),
      random = as.formula("~t | id")
    ),
    ignore_attr = TRUE
  )
})

test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = "lwage",
      conditional = c("union", "wks"),
      instruments = c("blk", "fem"),
      interactions = c("blk", "union")
    )
  )
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("lwage", "union", "wks", "blk", "fem")
  )

  expect_identical(
    find_variables(m2),
    list(
      response = "lwage",
      conditional = c("union", "wks"),
      instruments = c("blk", "t"),
      random = "id"
    )
  )
  expect_identical(
    find_variables(m2, flatten = TRUE),
    c("lwage", "union", "wks", "blk", "t", "id")
  )
})

test_that("n_obs", {
  expect_identical(n_obs(m1), 3570L)
  expect_identical(n_obs(m2), 3570L)
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
})

test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(
      conditional = c("lag(union)", "wks"),
      instruments = c("(Intercept)", "imean(lag(union))", "imean(wks)", "blk", "fem"),
      random = "lag(union):blk"
    )
  )

  expect_identical(nrow(get_parameters(m1)), 8L)

  expect_identical(
    find_parameters(m2),
    list(
      conditional = c("lag(union)", "wks"),
      instruments = c("(Intercept)", "imean(lag(union))", "imean(wks)", "blk", "t")
    )
  )
})


test_that("get_parameters", {
  expect_equal(
    get_parameters(m1),
    data.frame(
      Parameter = c(
        "lag(union)",
        "wks",
        "(Intercept)",
        "imean(lag(union))",
        "imean(wks)",
        "blk",
        "fem",
        "lag(union):blk"
      ),
      Estimate = c(
        0.0582474262882615, -0.00163678667081885, 6.59813245629044,
        -0.0279959204722801, 0.00438047648390025, -0.229414915661438,
        -0.441756913071962, -0.127319623945541
      ),
      Component = c(
        "within", "within", "between", "between",
        "between", "between", "between", "interactions"
      ),
      stringsAsFactors = FALSE
    ),
    tolerance = 1e-4
  )
})


test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      response = "lwage",
      conditional = c("lag(union)", "wks"),
      instruments = c("blk", "fem"),
      interactions = c("blk", "lag(union)")
    )
  )
  expect_identical(
    find_terms(m2),
    list(
      response = "lwage",
      conditional = c("lag(union)", "wks"),
      instruments = c("blk", "t"),
      random = c("t", "id")
    )
  )
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "t-statistic")
  expect_identical(find_statistic(m2), "t-statistic")
})

test_that("get_variance", {
  skip_on_cran()
  v <- get_variance(m1)
  expect_equal(v$var.intercept, c(id = 0.125306895731005), tolerance = 1e-4)
  expect_equal(v$var.fixed, 0.0273792999320531, tolerance = 1e-4)
})
