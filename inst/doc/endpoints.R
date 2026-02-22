## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(worcs)

## -----------------------------------------------------------------------------
# Run analysis
res <- lm(Sepal.Length ~ Sepal.Width + Petal.Length, iris)
# Extract regression coefficients
tab_coef <- summary(res)$coefficients
# Write to file
write.csv(tab_coef, "tab_coef.csv")
# Get checksum for file
digest::digest("tab_coef.csv")

## -----------------------------------------------------------------------------
# Write to file
write.csv(round(tab_coef, digits = 15), "tab_coef2.csv")
# Get checksum for file
digest::digest("tab_coef2.csv")

## -----------------------------------------------------------------------------
testthat::expect_equal(tab_coef, round(tab_coef, digits = 15), tolerance = 1e-3)

## ----eval = F-----------------------------------------------------------------
# worcs::add_testthat()

## ----eval = F-----------------------------------------------------------------
# usethis::use_test("my_first_test.R")

## ----eval = F-----------------------------------------------------------------
# worcs::add_endpoint("testthat")

