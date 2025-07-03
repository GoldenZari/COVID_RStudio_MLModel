# load libraries

library(readr)
library(tibble)
library(dplyr)
library(skimr)
library(dplyr)
library(caret)
library(mlbench)
library(ggplot2)
library(randomForest)


## Data 

# load data

covid <- read_csv("C:/Portfolio Projects/RStudio Projects/COVID Testing App/Data/tested_worldwide.csv")
covid <- as_tibble(covid)

# check data

str(covid)
summary(covid)

# filter na data

covid_data <- na.omit(covid)

# change to factors

covid_data <- covid_data %>%
  mutate_if(is.character, as.factor)

# check table

table(covid_data$active)


## Machine Learning

### Model 1: Predicting Daily Positive

# Vector for positivity rate

covid_data$Country_Region <- as.factor(covid_data$Country_Region)
covid_data$Province_State <- as.factor(covid_data$Province_State)
covid_data$positivity_rate <- covid_data$daily_positive / covid_data$daily_tested
covid_data <- covid_data[is.finite(covid_data$positivity_rate), ]

# Partition Data

set.seed(100)
index <- createDataPartition(covid_data$daily_positive, p = 0.8, list = FALSE)
train_data <- covid_data[index, ]
test_data <- covid_data[-index, ]

# Model 1: Daily Positive

mod_daily <- train(daily_positive ~ daily_tested + total_tested + Province_State,
                data = train_data,
                method = "rf",
                trControl = trainControl(method = "cv", number = 5))


### Model 2: Predicting Positivity Rates

# Model 2: Positivity Rates

mod_rates <- train(positivity_rate ~ daily_tested + total_tested + Province_State,
                data = train_data,
                method = "rf",
                trControl = trainControl(method = "cv", number = 5))


## Model Evaluations

# Model 1 Eval

pred_daily <- predict(mod_daily, newdata = test_data)
postResample(pred_daily, test_data$daily_positive)

# Model 2 Eval

pred_rates <- predict(mod_rates, newdata = test_data)
postResample(pred_rates, test_data$positivity_rate)
