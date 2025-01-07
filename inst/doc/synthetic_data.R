## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
thedir <- getwd()

library(worcs)
library(lavaan)
file.create(file.path(thedir, ".worcs"))

## ----setup--------------------------------------------------------------------
library(worcs)
library(lavaan)

## ----echo = TRUE, eval = FALSE------------------------------------------------
# library(lavaan)
# library(tidySEM)
# set.seed(4)
# dat <- PoliticalDemocracy
# closed_data(dat)

## ----echo = FALSE, eval = TRUE, error=FALSE, warning=FALSE, message=FALSE, results = "hide"----
library(lavaan)
library(tidySEM)
dat <- PoliticalDemocracy
file.create(".worcs")
set.seed(4)
closed_data(dat, worcs_directory = thedir)

## ----echo = TRUE, eval = FALSE------------------------------------------------
# load_data()
# model <- '
# ind60 =~ x1 + x2 + x3
# dem60 =~ y1 + a*y2 + b*y3 + c*y4
# dem65 =~ y5 + a*y6 + b*y7 + c*y8
# 
# # regressions
# dem60 ~ ind60
# dem65 ~ ind60 + dem60
# 
# # residual correlations
# y1 ~~ y5
# y2 ~~ y4 + y6
# y3 ~~ y7
# y4 ~~ y8
# y6 ~~ y8'
# 
# fit <- lavaan::sem(model, data = dat)
# tidySEM::table_results(fit)

## ----echo = FALSE, eval = TRUE, error=FALSE, warning=FALSE--------------------
load_data(worcs_directory = thedir)
model <- '
ind60 =~ x1 + x2 + x3
dem60 =~ y1 + a*y2 + b*y3 + c*y4
dem65 =~ y5 + a*y6 + b*y7 + c*y8

# regressions
dem60 ~ ind60
dem65 ~ ind60 + dem60

# residual correlations
y1 ~~ y5
y2 ~~ y4 + y6
y3 ~~ y7
y4 ~~ y8
y6 ~~ y8'

fit <- lavaan::sem(model, data = dat)
tidySEM::table_results(fit)

## ----echo = TRUE, eval = FALSE------------------------------------------------
# dat2 <- read.csv("synthetic_dat.csv", stringsAsFactors = FALSE)
# fit2 <- lavaan::sem(model, data = dat2)

## ----echo = FALSE, eval = TRUE, error=FALSE, warning=TRUE---------------------
dat2 <- read.csv("synthetic_dat.csv", stringsAsFactors = FALSE)
fit2 <- lavaan::sem(model, data = dat2)

## ----eval = TRUE, echo = TRUE-------------------------------------------------
set.seed(33)
dat_synthetic <- lavaan::simulateData(model = lavaan::partable(fit))

## ----echo = TRUE, eval = FALSE------------------------------------------------
# add_synthetic(dat_synthetic, original_name = "dat.csv")

## ----echo = FALSE, eval = TRUE, error=FALSE, warning=FALSE--------------------
add_synthetic(dat_synthetic, original_name = "dat.csv", worcs_directory = thedir)

## ----echo = TRUE, eval = FALSE------------------------------------------------
# file.remove("dat.csv")
# load_data()
# fit2 <- lavaan::sem(model, data = dat)
# tidySEM::table_results(fit2)

## ----echo = FALSE, eval = TRUE, error=FALSE, warning=FALSE--------------------
file.remove(file.path(thedir, "dat.csv"))
load_data(worcs_directory = thedir)
fit2 <- lavaan::sem(model, data = dat)
tidySEM::table_results(fit2)

## ----echo = FALSE, results='hide'---------------------------------------------
f <- list.files(pattern = "_dat\\.")
file.remove(f)
file.remove(".worcs")
#setwd(curdir)
#unlink(thedir, recursive = TRUE)

