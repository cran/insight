skip_if_not_installed("MASS")

data(housing, package = "MASS")

m1 <- MASS::polr(Sat ~ Infl + Type + Cont, data = housing, weights = Freq)

test_that("model_info", {
  expect_true(model_info(m1)$is_ordinal)
  expect_false(model_info(m1)$is_multinomial)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("Infl", "Type", "Cont")))
  expect_identical(
    find_predictors(m1, flatten = TRUE),
    c("Infl", "Type", "Cont")
  )
  expect_null(find_predictors(m1, effects = "random"))
})

test_that("find_response", {
  expect_identical(find_response(m1), "Sat")
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), plogis(0.2), tolerance = 1e-5)
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 72L)
  expect_named(
    get_data(m1),
    c("Sat", "Infl", "Type", "Cont", "Freq")
  )
})

test_that("get_df", {
  expect_equal(
    get_df(m1, type = "residual"),
    df.residual(m1),
    ignore_attr = TRUE
  )
  expect_equal(
    get_df(m1, type = "normal"),
    Inf,
    ignore_attr = TRUE
  )
  expect_equal(
    get_df(m1, type = "wald"),
    df.residual(m1), # model has t-statistic
    ignore_attr = TRUE
  )
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula("Sat ~ Infl + Type + Cont")),
    ignore_attr = TRUE
  )
})

test_that("find_terms", {
  expect_identical(find_terms(m1), list(
    response = "Sat",
    conditional = c("Infl", "Type", "Cont")
  ))
  expect_identical(
    find_terms(m1, flatten = TRUE),
    c("Sat", "Infl", "Type", "Cont")
  )
})

test_that("n_obs", {
  expect_identical(n_obs(m1), 1681L)
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
})


test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(
      conditional =
        c(
          "Intercept: Low|Medium",
          "Intercept: Medium|High",
          "InflMedium",
          "InflHigh",
          "TypeApartment",
          "TypeAtrium",
          "TypeTerrace",
          "ContHigh"
        )
    )
  )
})

test_that("get_parameters", {
  expect_equal(
    get_parameters(m1),
    data.frame(
      Parameter = c(
        "Intercept: Low|Medium",
        "Intercept: Medium|High",
        "InflMedium",
        "InflHigh",
        "TypeApartment",
        "TypeAtrium",
        "TypeTerrace",
        "ContHigh"
      ),
      Estimate = c(
        -0.4961353438375,
        0.690708290379271,
        0.566393738890106,
        1.28881906381232,
        -0.572350146429611,
        -0.366186566153346,
        -1.09101490767244,
        0.360284149947385
      ),
      stringsAsFactors = FALSE,
      row.names = NULL
    ),
    tolerance = 1e-5,
    ignore_attr = TRUE
  )
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "t-statistic")
})

test_that("get_predicted", {
  p1 <- get_predicted(m1, predict = "expectation")
  p2 <- get_predicted(m1, predict = "classification")
  p3 <- get_predicted(m1, predict = NULL, type = "probs")
  p4 <- get_predicted(m1, predict = NULL, type = "class")
  expect_s3_class(p1, "get_predicted")
  expect_s3_class(p2, "get_predicted")
  expect_s3_class(p3, "get_predicted")
  expect_s3_class(p4, "get_predicted")
  expect_identical(p1, p3)
  expect_identical(p2, p4)
  expect_s3_class(p1, "data.frame")
  expect_s3_class(p2, "factor")
  expect_s3_class(p3, "data.frame")
  expect_s3_class(p4, "factor")
  expect_true(all(c("Row", "Response", "Predicted") %in% colnames(p1)))
  expect_true(all(c("Row", "Response", "Predicted") %in% colnames(p3)))

  d <- get_datagrid(m1, by = "Type", verbose = FALSE)

  p1 <- get_predicted(m1, predict = "expectation", data = d, verbose = FALSE)

  expect_named(p1, c("Row", "Type", "Response", "Predicted"))
  expect_identical(dim(p1), c(12L, 4L))
})
