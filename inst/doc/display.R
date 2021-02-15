## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- warning=FALSE, message=FALSE--------------------------------------------
library(insight)
library(dplyr)

df <- data.frame(
  Variable = c(1, 3, 5, 3, 1),
  Group = c("A", "A", "A", "B", "B"),
  CI = c(0.95, 0.95, 0.95, 0.95, 0.95),
  CI_low = c(3.35, 2.425, 6.213, 12.1, 1.23),
  CI_high = c(4.23, 5.31, 7.123, 13.5, 3.61),
  p = c(0.001, 0.0456, 0.45, 0.0042, 0.34)
)

df

## ---- results='asis'----------------------------------------------------------
knitr::kable(df, format = "markdown")

## ---- eval=FALSE--------------------------------------------------------------
#  knitr::kable(df, format = "html")

## ---- results='asis', echo=FALSE----------------------------------------------
knitr::kable(df, format = "html")

## -----------------------------------------------------------------------------
insight::format_table(df)

## -----------------------------------------------------------------------------
df %>% 
  mutate(p = format_p(p, stars = TRUE)) %>% 
  format_table()

## -----------------------------------------------------------------------------
cat(export_table(df))

