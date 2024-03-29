skip_if_not_installed("survival")

m1 <- survival::survfit(survival::Surv(time, status) ~ sex + age + ph.ecog, data = survival::lung)

test_that("model_info", {
  expect_true(model_info(m1)$is_logit)
  expect_false(model_info(m1)$is_linear)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("sex", "age", "ph.ecog")))
  expect_null(find_predictors(m1, effects = "random"))
})

test_that("find_response", {
  expect_identical(find_response(m1), "survival::Surv(time, status)")
  expect_identical(find_response(m1, combine = FALSE), c("time", "status"))
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), plogis(0.2), tolerance = 1e-5)
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 227L)
  expect_named(get_data(m1), c("time", "status", "sex", "age", "ph.ecog"))
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula(
      "survival::Surv(time, status) ~ sex + age + ph.ecog"
    )),
    ignore_attr = TRUE
  )
})

test_that("find_variables", {
  expect_identical(find_variables(m1), list(
    response = c("time", "status"),
    conditional = c("sex", "age", "ph.ecog")
  ))
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("time", "status", "sex", "age", "ph.ecog")
  )
})

test_that("n_obs", {
  expect_identical(n_obs(m1), 227L)
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
})

test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      response = "Surv(time, status)",
      conditional = c("sex", "age", "ph.ecog")
    )
  )
})

test_that("find_statistic", {
  expect_null(find_statistic(m1))
})

skip_if_not_installed("withr")
withr::with_package(
  "survival",
  test_that("find_predictors works with strata", {
    data(mtcars)
    mod <- suppressWarnings(survival::clogit(
      am ~ mpg + cyl + mpg:cyl + survival::strata(carb, gear),
      data = mtcars
    ))
    out <- find_predictors(mod)
    expect_identical(out, list(conditional = c("mpg", "cyl"), strata = c("carb", "gear")))

    # works with reserved arguments inside "strata()"
    mod <- suppressWarnings(survival::clogit(
      am ~ mpg + cyl + mpg:cyl + survival::strata(carb, gear, shortlabel = TRUE),
      data = mtcars
    ))
    out <- find_predictors(mod)
    expect_identical(out, list(conditional = c("mpg", "cyl"), strata = c("carb", "gear")))
  })
)
