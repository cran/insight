skip_if_not_installed("betareg")

data("GasolineYield", package = "betareg")
data("FoodExpenditure", package = "betareg")


m1 <- betareg::betareg(yield ~ batch + temp, data = GasolineYield)
m2 <- betareg::betareg(I(food / income) ~ income + persons, data = FoodExpenditure)

test_that("model_info", {
  expect_true(model_info(m1)$is_beta)
  expect_false(model_info(m1)$is_linear)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("batch", "temp")))
  expect_identical(find_predictors(m1, flatten = TRUE), c("batch", "temp"))
  expect_null(find_predictors(m1, effects = "random"))
})

test_that("find_response", {
  expect_identical(find_response(m1), "yield")
  expect_identical(find_response(m2), "I(food/income)")
  expect_identical(find_response(m2, combine = FALSE), c("food", "income"))
})

test_that("get_response", {
  expect_identical(get_response(m1), GasolineYield$yield)
  expect_identical(get_response(m2), FoodExpenditure[, c("food", "income")])
})

test_that("get_varcov", {
  expect_equal(get_varcov(m1, component = "all"), vcov(m1), tolerance = 1e-3)
  expect_equal(get_varcov(m1), vcov(m1)[-12, -12], tolerance = 1e-3)
})

test_that("link_inverse", {
  expect_identical(link_inverse(m1)(0.2), plogis(0.2))
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 32L)
  expect_named(get_data(m1), c("yield", "batch", "temp"))
  expect_identical(nrow(get_data(m2)), 38L)
  expect_named(get_data(m2), c("food", "income", "persons"))
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula("yield ~ batch + temp")),
    ignore_attr = TRUE
  )
  expect_equal(
    find_formula(m2),
    list(conditional = as.formula("I(food/income) ~ income + persons")),
    ignore_attr = TRUE
  )
})

test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = "yield",
      conditional = c("batch", "temp")
    )
  )
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("yield", "batch", "temp")
  )
  expect_identical(
    find_variables(m2, flatten = TRUE),
    c("food", "income", "persons")
  )
})

test_that("n_obs", {
  expect_equal(n_obs(m1), 32, ignore_attr = TRUE)
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
})

test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(
      conditional = c(
        "(Intercept)",
        "batch1",
        "batch2",
        "batch3",
        "batch4",
        "batch5",
        "batch6",
        "batch7",
        "batch8",
        "batch9",
        "temp"
      ),
      precision = "(phi)"
    )
  )
  expect_identical(nrow(get_parameters(m1)), 12L)
  expect_identical(
    get_parameters(m1)$Parameter,
    c(
      "(Intercept)",
      "batch1",
      "batch2",
      "batch3",
      "batch4",
      "batch5",
      "batch6",
      "batch7",
      "batch8",
      "batch9",
      "temp",
      "(phi)"
    )
  )
})

test_that("find_terms", {
  expect_identical(
    find_terms(m2),
    list(
      response = "I(food/income)",
      conditional = c("income", "persons")
    )
  )
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "z-statistic")
  expect_identical(find_statistic(m2), "z-statistic")
})

test_that("get_modelmatrix", {
  mm <- get_modelmatrix(m1)
  expect_true(is.matrix(mm))
  expect_identical(dim(mm), c(32L, 11L))
  mm <- get_modelmatrix(m1, data = head(GasolineYield))
  expect_true(is.matrix(mm))
  expect_identical(dim(mm), c(6L, 11L))
})

skip_if_not_installed("withr")

withr::with_environment(
  new.env(),
  test_that("get_predicted", {
    data("GasolineYield", package = "betareg")
    data("FoodExpenditure", package = "betareg")
    mp1 <- betareg::betareg(yield ~ batch + temp, data = GasolineYield)
    mp2 <- betareg::betareg(I(food / income) ~ income + persons, data = FoodExpenditure)
    p <- suppressWarnings(get_predicted(mp1))
    expect_s3_class(p, "get_predicted")
    expect_length(p, 32)
    p <- suppressWarnings(get_predicted(mp1, data = head(GasolineYield)))
    expect_s3_class(p, "get_predicted")
    expect_length(p, 6)
    # delta method does not work, so we omit SE and issue warning
    # expect_warning(get_predicted(mp2, predict = "expectation"))
    expect_warning(get_predicted(mp2, predict = "link"), NA)
    p1 <- suppressWarnings(get_predicted(mp2, predict = "expectation", ci = 0.95))
    p2 <- get_predicted(mp2, predict = "link", ci = 0.95)
    p1 <- data.frame(p1)
    p2 <- data.frame(p2)
    # expect_false("SE" %in% colnames(p1))
    expect_true("SE" %in% colnames(p2))
  })
)
