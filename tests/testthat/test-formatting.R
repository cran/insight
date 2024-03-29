x <- c(0.0000453, 0.12, 1.2, 0.0001234)
test_that("format_value", {
  f <- format_value(x, zap_small = FALSE)
  expect_equal(f, c("4.53e-05", "0.12", "1.20", "1.23e-04"))
  f <- format_value(x, zap_small = TRUE)
  expect_equal(f, c("0.00", "0.12", "1.20", "0.00"))
})

p <- c(1, 0.9, 0.05, 0.01, 0.001, 0.0009)

test_that("format_p", {
  expect_equal(format_p(p, name = NULL), c("> .999", "0.900", "0.050", "0.010", "0.001", "< .001"))
  expect_equal(format_p(p, name = NULL, whitespace = FALSE), c(">.999", "0.900", "0.050", "0.010", "0.001", "<.001"))
  expect_equal(format_p(p, name = NULL, whitespace = FALSE, decimal_separator = ","), c(">,999", "0,900", "0,050", "0,010", "0,001", "<,001"))
})

test_that("format_message", {
  msg <- "R is free software and comes with ABSOLUTELY NO WARRANTY. You are welcome to redistribute it under certain conditions. Type 'license()' or 'licence()' for distribution details."
  expect_equal(format_message(msg, line_length = 80), "R is free software and comes with ABSOLUTELY NO WARRANTY. You are welcome to\n  redistribute it under certain conditions. Type 'license()' or 'licence()' for\n  distribution details.")
  expect_equal(format_message(msg, line_length = 43.35), "R is free software and comes with\n  ABSOLUTELY NO WARRANTY. You are welcome to\n  redistribute it under certain conditions.\n  Type 'license()' or 'licence()' for\n  distribution details.")
  msg1 <- "R is free software and comes with ABSOLUTELY NO WARRANTY."
  msg2 <- "You are welcome to redistribute it under certain conditions. Type 'license()' or 'licence()' for distribution details."
  expect_equal(format_message(msg1, msg2, line_length = 40), "R is free software and comes with\n  ABSOLUTELY NO WARRANTY.\n  You are welcome to redistribute it under\n  certain conditions. Type 'license()' or\n  'licence()' for distribution details.")
})

test_that("format_alert", {
  msg <- "R is free software and comes with ABSOLUTELY NO WARRANTY. You are welcome to redistribute it under certain conditions. Type 'license()' or 'licence()' for distribution details."
  expect_message(format_alert(msg))
  expect_message(format_alert(msg, type = "message"))
  expect_warning(format_alert(msg, type = "warning"))
  expect_error(format_alert(msg, type = "error"))
  expect_warning(format_warning(msg))
  expect_error(format_error(msg))
})
