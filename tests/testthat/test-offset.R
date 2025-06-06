skip_if_not_installed("pscl")

# Generate some zero-inflated data
set.seed(123)
N <- 100 # Samples
x <- runif(N, 0, 10) # Predictor
off <- rgamma(N, 3, 2) # Offset variable
yhat <- -1 + x * 0.5 + log(off) # Prediction on log scale
y <- rpois(N, exp(yhat)) # Poisson process
y <- ifelse(rbinom(N, 1, 0.3), 0, y) # Zero-inflation process

d <<- data.frame(y = y, x, logOff = log(off), raw_off = off) # Storage dataframe

# Fit zeroinfl model using 2 methods of offset input
m1 <- pscl::zeroinfl(y ~ offset(logOff) + x | 1, data = d, dist = "poisson")
m2 <- pscl::zeroinfl(y ~ x | 1,
  data = d,
  offset = logOff,
  dist = "poisson"
)

# Fit zeroinfl model without offset data
m3 <- pscl::zeroinfl(y ~ x | 1, data = d, dist = "poisson")

m4 <- pscl::zeroinfl(
  y ~ offset(log(raw_off)) + x | 1,
  data = d,
  dist = "poisson"
)

m5 <- pscl::zeroinfl(
  y ~ x | 1,
  data = d,
  dist = "poisson",
  offset = log(raw_off)
)

test_that("offset in get_data()", {
  expect_equal(colnames(get_data(m1)), c("y", "logOff", "x"))
  expect_equal(colnames(get_data(m2)), c("y", "x", "logOff"))
  expect_equal(colnames(get_data(m3)), c("y", "x"))
})

test_that("offset in get_data()", {
  expect_equal(find_offset(m1), "logOff")
  expect_equal(find_offset(m2), "logOff")
  expect_null(find_offset(m3))
})

test_that("offset as term", {
  expect_identical(find_offset(m4), "raw_off")
  expect_identical(find_offset(m4, as_term = TRUE), "log(raw_off)")
  expect_identical(find_offset(m1), "logOff")
  expect_identical(find_offset(m1, as_term = TRUE), "logOff")
  expect_identical(find_offset(m5), "raw_off")
  expect_identical(find_offset(m5, as_term = TRUE), "log(raw_off)")
})

# test_that("offset in null_model()", {
#   nm1 <- null_model(m1)
#   nm2 <- null_model(m2)
#   expect_equal(coef(nm1), coef(nm2), tolerance = 1e-4)
# })
