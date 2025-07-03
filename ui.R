# ui.R

ui <- navbarPage(
  title = "COVID Testing Model",
  id = "main_nav",
  
  # CSS for tabs
  header = tags$head(
    tags$style(HTML("
      /* General tab styling */
      .navbar {
        background-color: #f8f9fa;
        border-bottom: 2px solid #e3e3e3;
      }
      .navbar-default .navbar-nav > li > a {
        color: #333333;
        font-weight: 500;
        font-size: 15px;
      }
      .navbar-default .navbar-nav > li > a:hover {
        color: #ffffff !important;
        background-color: #007acc !important;
      }
      .navbar-default .navbar-nav > .active > a {
        background-color: #005b99 !important;
        color: white !important;
        font-weight: 600;
      }
      body {
        font-family: 'Segoe UI', sans-serif;
        font-size: 15px;
        color: #222222;
        background-color: #ffffff;
      }
      .tab-content {
        padding: 20px;
      }
      h2, h3 {
        color: #005b99;
      }
      .well {
        background-color: #f4f4f4;
        border: 1px solid #ddd;
        border-radius: 5px;
      }
    "))
  ),
                 
                 tabPanel("Data Summary",
                          fluidPage(
                            titlePanel("Exploratory Data Analysis"),
                            sidebarLayout(
                              sidebarPanel(
                                selectInput("eda_var", "Select a variable:", choices = NULL)
                              ),
                              mainPanel(
                                tableOutput("head_data"),
                                verbatimTextOutput("data_summary"),
                                plotOutput("eda_plot")
                              )
                            )
                          )
                 ),
                 
                 tabPanel("Daily Positive Model",
                          fluidPage(
                            titlePanel("Model 1: Daily Positive Cases"),
                            p("This model predicts the expected number of daily 
                              positive COVID-19 cases based on the number of 
                              daily and total tests conducted and the region 
                              (Province/State). The goal is to assist in 
                              regional risk assessment and resource allocation. 
                              The model shows reasonably strong predictive 
                              performance, as most predicted values align 
                              closely with the actual data. While there may be 
                              minor underpredictions, the overall reliability of 
                              this model remains high for general use in 
                              forecasting case volumes."),
                            verbatimTextOutput("mod_daily_perf"),
                            plotOutput("mod_daily_plot")
                          )
                 ),
                 
                 tabPanel("Positivity Rate Model",
                          fluidPage(
                            titlePanel("Model 2: Positivity Rate"),
                            p("This model estimates the likelihood that a given 
                              COVID-19 test will return a positive result—also 
                              known as the positivity rate. This metric can help 
                              assess local transmission intensity. While the model 
                              performs respectably overall, lower variance and a 
                              degree of clustering suggest that important predictive 
                              factors may be missing from the dataset. This could 
                              be due to unobserved variables or data limitations 
                              such as narrow value ranges or zero-inflation. 
                              Therefore, predicting positivity rates is more 
                              challenging and may require more complex modeling 
                              or additional features."),
                            verbatimTextOutput("mod_rates_perf"),
                            plotOutput("mod_rates_plot")
                          )
                 ),
                 
  
                tabPanel("Top Countries",
                         fluidPage(
                           titlePanel("COVID-19 Positivity Rate Analysis by Country"),
                           p("This visualization ranks countries based on the positivity 
                             rate of COVID-19 tests. A high positivity rate may indicate 
                             limited testing and underreporting, while lower rates may 
                             reflect broader testing and better detection."),
                           fluidRow(
                             column(12,
                                    plotOutput("top_country_plot"),
                                    br(),
                                    h4("Top 10 Countries by Positivity Rate"),
                                    tableOutput("top_country_table")
                             )
                           )
                         )
                ),
                
                tabPanel("Compare & Predict",
                         fluidPage(
                           titlePanel("Predict with Your Own Input"),
                           p("This tool lets you simulate and compare two COVID-19 model predictions using your own data. 
                     By entering the number of daily and total tests along with a province/state, the app uses 
                     trained machine learning models to estimate: 
                     (1) the expected number of daily positive cases, and 
                     (2) the likely positivity rate. 
                     This can be useful for scenario analysis, planning, or understanding how testing volume affects outcomes."),
                           sidebarLayout(
                             sidebarPanel(
                               numericInput("inp_daily_tested", "Daily Tested", value = 10000),
                               numericInput("inp_total_tested", "Total Tested", value = 500000),
                               selectInput("inp_province", "Province/State", choices = NULL),
                               actionButton("predict_btn", "Predict")
                             ),
                             mainPanel(
                               h4("Model 1 Prediction (Daily Positive Cases)"),
                               verbatimTextOutput("user_pred1"),
                               h4("Model 2 Prediction (Positivity Rate)"),
                               verbatimTextOutput("user_pred2")
                             )
                           )
                         )
                ),
                 
                tabPanel("Discussion",
                         fluidPage(
                           titlePanel("Discussion of Dataset Insights"),
                           fluidRow(
                             column(12,
                                    HTML("<h4>📘 Overview</h4>"),
                                    tags$p("The dataset contains 6,141 observations 
                                           across 13 variables related to COVID-19 
                                           testing and outcomes. The data spans 
                                           from March 25 to November 7, 2020, 
                                           covering a wide timeframe for analysis. 
                                           Although there is a column labeled 
                                           Country_Region, it includes only a 
                                           single unique value, making it unhelpful 
                                           for modeling purposes. In contrast, 
                                           Province_State includes 37 distinct 
                                           entries and serves as a meaningful 
                                           categorical predictor in the models."),
                                    
                                    HTML("<h4>📊 Numeric Variables</h4>"),
                                    tags$p("Among the 10 numeric variables, 
                                           several key trends emerge. The number 
                                           of daily positive cases (daily_positive) 
                                           averages around 651 cases per day, 
                                           but also contains negative values—ranging 
                                           as low as -7,757. These are likely data 
                                           entry or reporting errors and should 
                                           be removed or corrected in a preprocessing 
                                           step. Similarly, daily_tested values 
                                           show the same issue with extreme 
                                           negatives, which further suggests the 
                                           need for validation and cleaning."),
                                    
                                    tags$p("The positivity_rate, which is 
                                           calculated as daily positives divided 
                                           by daily tested cases, reveals potential 
                                           anomalies. While the average rate is 
                                           15.2%, some entries exceed 100% or 
                                           fall below 0—values that are mathematically 
                                           invalid and may stem from very low testing 
                                           numbers or missing values during the 
                                           division process. Filtering for valid 
                                           positivity rates (e.g., between 0 and 
                                           1) will improve the reliability of any 
                                           predictive modeling."),
                                    
                                    HTML("<h4>🧮 Distribution & Preprocessing</h4>"),
                                    tags$p("In general, the data shows skewed 
                                           distributions, particularly for total 
                                           tested, positive cases, and hospitalization 
                                           metrics. These distributions, combined 
                                           with the presence of extreme values and 
                                           data inconsistencies, suggest that transformation 
                                           techniques (like log-scaling) and careful 
                                           data cleaning are essential before 
                                           building accurate models."),
                                    
                                    tags$p("Overall, while the dataset provides 
                                           a valuable snapshot of COVID-19 
                                           testing and outcomes across various 
                                           states, its quality requires attention 
                                           before reliable analysis and prediction. 
                                           This discussion underpins the importance 
                                           of preprocessing steps, which ensure 
                                           the machine learning models are not 
                                           adversely affected by erroneous or 
                                           misleading values.")
                             )
                           )
                         )
                )
)

