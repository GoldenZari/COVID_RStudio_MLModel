# global.R

library(readr)
library(tibble)
library(dplyr)
library(skimr)
library(caret)
library(mlbench)
library(ggplot2)
library(randomForest)
library(shiny)

# Load data
covid <- read_csv("Data/tested_worldwide.csv")
covid <- as_tibble(covid)

# Clean data
covid_data <- na.omit(covid) %>%
  mutate_if(is.character, as.factor)

covid_data$Country_Region <- as.factor(covid_data$Country_Region)
covid_data$Province_State <- as.factor(covid_data$Province_State)
covid_data$positivity_rate <- covid_data$daily_positive / covid_data$daily_tested
covid_data <- covid_data[is.finite(covid_data$positivity_rate), ]

# Partition
set.seed(100)
index <- createDataPartition(covid_data$daily_positive, p = 0.8, list = FALSE)
train_data <- covid_data[index, ]
test_data <- covid_data[-index, ]

# Train models
mod_daily <- train(daily_positive ~ daily_tested + total_tested + Province_State,
                   data = train_data,
                   method = "rf",
                   trControl = trainControl(method = "cv", number = 5))

mod_rates <- train(positivity_rate ~ daily_tested + total_tested + Province_State,
                   data = train_data,
                   method = "rf",
                   trControl = trainControl(method = "cv", number = 5))

# Predictions
pred_daily <- predict(mod_daily, newdata = test_data)
pred_rates <- predict(mod_rates, newdata = test_data)


## Graphs

# Clean and filter data
covid_filter <- covid %>%
  filter(!is.na(total_tested), !is.na(daily_positive)) %>%
  select(Country_Region, total_tested, daily_positive)

# Summary statistics
summary_covid <- covid_filter %>%
  group_by(Country_Region) %>%
  summarise(
    tot_tests = sum(total_tested),
    tot_pos_cases = sum(daily_positive),
    pos_rate = (tot_pos_cases / tot_tests) * 100
  ) %>%
  arrange(desc(pos_rate))

# Top 10 by tests and positivity
top_tested <- summary_covid %>%
  arrange(desc(tot_tests)) %>%
  slice_head(n = 10)

top_10_pos <- summary_covid %>%
  arrange(desc(pos_rate)) %>%
  slice_head(n = 10)