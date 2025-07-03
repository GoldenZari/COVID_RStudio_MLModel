# server.R

server <- function(input, output, session) {
  
  updateSelectInput(session, "eda_var", choices = names(covid_data))
  updateSelectInput(session, "inp_province", choices = levels(covid_data$Province_State))
  
  output$head_data <- renderTable({
    head(covid_data)
  })
  
  output$data_summary <- renderPrint({
    skimr::skim(covid_data)
  })
  
  output$eda_plot <- renderPlot({
    var <- input$eda_var
    if (is.null(var)) return()
    if (is.numeric(covid_data[[var]])) {
      ggplot(covid_data, aes_string(var)) +
        geom_histogram(bins = 30, fill = "skyblue", color = "black")
    } else {
      ggplot(covid_data, aes_string(var)) +
        geom_bar(fill = "lightgreen")
    }
  })
  
  output$mod_daily_perf <- renderPrint({
    postResample(pred_daily, test_data$daily_positive)
  })
  
  output$mod_rates_perf <- renderPrint({
    postResample(pred_rates, test_data$positivity_rate)
  })
  
  # ML model plots
  output$mod_daily_plot <- renderPlot({
    ggplot(data.frame(Actual = test_data$daily_positive, Predicted = pred_daily),
           aes(x = Actual, y = Predicted)) +
      geom_point(alpha = 0.5, color = "darkred") +
      geom_smooth(method = "lm", se = FALSE) +
      labs(title = "Model 1: Actual vs Predicted Daily Positives")
  })
  
  output$mod_rates_plot <- renderPlot({
    ggplot(data.frame(Actual = test_data$positivity_rate, Predicted = pred_rates),
           aes(x = Actual, y = Predicted)) +
      geom_point(alpha = 0.5, color = "darkblue") +
      geom_smooth(method = "lm", se = FALSE) +
      labs(title = "Model 2: Actual vs Predicted Positivity Rate")
  })
  
  # predictions for the models 
  observeEvent(input$predict_btn, {
    newdata <- data.frame(
      daily_tested = input$inp_daily_tested,
      total_tested = input$inp_total_tested,
      Province_State = input$inp_province
    )
    
    output$user_pred1 <- renderPrint({
      predict(mod_daily, newdata = newdata)
    })
    
    output$user_pred2 <- renderPrint({
      predict(mod_rates, newdata = newdata)
    })
  })
  
  covid_filter <- covid %>%
    filter(!is.na(total_tested), !is.na(daily_positive)) %>%
    select(Country_Region, total_tested, daily_positive)
  
  summary_covid <- covid_filter %>%
    group_by(Country_Region) %>%
    summarise(
      tot_tests = sum(total_tested),
      tot_pos_cases = sum(daily_positive),
      pos_rate = (tot_pos_cases / tot_tests) * 100
    ) %>%
    arrange(desc(pos_rate))
  
  top_10_pos <- summary_covid %>%
    arrange(desc(pos_rate)) %>%
    slice_head(n = 10)
  
  # Plot: Top 10 countries by positivity rate
  output$top_country_plot <- renderPlot({
    ggplot(top_10_pos, aes(x = reorder(Country_Region, pos_rate), y = pos_rate)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(
        title = "Top 10 Countries by COVID-19 Positivity Rates",
        x = "Country",
        y = "Positivity Rate (%)"
      ) +
      theme_minimal()
  })
  
  # Table: Top 10 countries summary
  output$top_country_table <- renderTable({
    top_10_pos
  })
  
}

