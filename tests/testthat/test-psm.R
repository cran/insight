skip_if_not_installed("rms")
skip_if_not_installed("survival")

Surv <- survival::Surv
pol <- rms::pol

n <- 400
set.seed(1)
age <- rnorm(n, 50, 12)
sex <- factor(sample(c("Female", "Male"), n, TRUE))
# Population hazard function:
h <- 0.02 * exp(0.06 * (age - 50) + 0.8 * (sex == "Female"))
d.time <- -log(runif(n)) / h
cens <- 15 * runif(n)
death <- as.integer(d.time <= cens)
d.time <- pmin(d.time, cens)

dat <<- data.frame(d.time, death, sex, age, stringsAsFactors = FALSE)

m1 <- rms::psm(Surv(d.time, death) ~ sex * pol(age, 2),
  dist = "lognormal",
  data = dat
)

test_that("model_info", {
  expect_false(model_info(m1)$is_binomial)
  expect_false(model_info(m1)$is_logit)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("sex", "age")))
  expect_identical(find_predictors(m1, flatten = TRUE), c("sex", "age"))
  expect_null(find_predictors(m1, effects = "random"))
})

test_that("find_random", {
  expect_null(find_random(m1))
})

test_that("get_random", {
  expect_warning(get_random(m1))
})

test_that("find_response", {
  expect_identical(find_response(m1), "Surv(d.time, death)")
  expect_identical(find_response(m1, combine = FALSE), c("d.time", "death"))
})

test_that("get_response", {
  expect_equal(get_response(m1), dat[, c("d.time", "death")])
})

test_that("get_predictors", {
  expect_equal(colnames(get_predictors(m1)), c("sex", "age"))
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), exp(0.2), tolerance = 1e-5)
})

test_that("get_data", {
  expect_equal(nrow(get_data(m1)), 400)
  expect_equal(colnames(get_data(m1)), c("d.time", "death", "sex", "age"))
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula(
      "Surv(d.time, death) ~ sex * pol(age, 2)"
    )),
    ignore_attr = TRUE
  )
})

test_that("find_terms", {
  expect_length(find_terms(m1), 2)
  expect_equal(
    find_terms(m1),
    list(
      response = "Surv(d.time, death)",
      conditional = c("sex", "pol(age, 2)")
    )
  )
})

test_that("find_variables", {
  expect_equal(find_variables(m1), list(
    response = c("d.time", "death"),
    conditional = c("sex", "age")
  ))
  expect_equal(
    find_variables(m1, flatten = TRUE),
    c("d.time", "death", "sex", "age")
  )
})

test_that("n_obs", {
  expect_equal(n_obs(m1), 400)
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
})

test_that("linkinverse", {
  expect_false(is.null(link_inverse(m1)))
})

test_that("find_parameters", {
  expect_equal(
    find_parameters(m1),
    list(
      conditional = c(
        "(Intercept)",
        "sex=Male",
        "age",
        "age^2",
        "sex=Male * age",
        "sex=Male * age^2"
      )
    )
  )
  expect_equal(nrow(get_parameters(m1)), 6)
  expect_equal(
    get_parameters(m1)$Parameter,
    c(
      "(Intercept)",
      "sex=Male",
      "age",
      "age^2",
      "sex=Male * age",
      "sex=Male * age^2"
    )
  )
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
})

test_that("find_algorithm", {
  expect_warning(find_algorithm(m1))
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "z-statistic")
})
