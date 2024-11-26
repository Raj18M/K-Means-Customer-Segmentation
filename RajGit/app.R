# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Load necessary libraries
library(shiny)
library(shinythemes)
library(readxl)
library(ggplot2)
library(cluster)
library(dplyr)
library(DT)
library(parallel)  # Required for parallel processing

# Define UI for the application
ui <- fluidPage(
  theme = shinytheme("cosmo"),
  titlePanel("Customer Segmentation Using K-Means"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("datafile", "Upload Dataset (CSV/Excel)", accept = c(".csv", ".xlsx")),
      numericInput("clusters", "Number of Clusters (k):", value = 3, min = 2, max = 10),
      actionButton("run_kmeans", "Run K-Means"),
      actionButton("find_optimal_k", "Suggest Optimal k"),
      
      # Display optimal k results below the button
      plotOutput("elbow_plot"),
      verbatimTextOutput("optimal_k_value")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data Preview", DTOutput("data_table")),
        tabPanel("Summary Statistics", verbatimTextOutput("summary_stats")),
        tabPanel(
          "Clustering Results",
          plotOutput("cluster_plot"),
          plotOutput("top_items_plot"),
          DTOutput("cluster_summary"),
          verbatimTextOutput("cluster_insights")
        ),
        tabPanel(
          "Customer Insights",
          verbatimTextOutput("customer_types"),
          DTOutput("significant_items")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive to load and preprocess data
  data <- reactive({
    req(input$datafile)
    ext <- tools::file_ext(input$datafile$name)
    if (ext == "csv") {
      df <- read.csv(input$datafile$datapath)
    } else if (ext == "xlsx") {
      df <- read_excel(input$datafile$datapath)
    } else {
      stop("Unsupported file format")
    }
    
    # Data preprocessing
    df <- df %>%
      filter(Quantity > 0) %>%  # Remove invalid transactions
      mutate(TotalSpent = UnitPrice * Quantity) %>%  # Feature creation
      na.omit()  # Handle missing values
    
    return(df)
  })
  
  # Display data table
  output$data_table <- renderDT({
    req(data())
    datatable(data())
  })
  
  # Display summary statistics
  output$summary_stats <- renderPrint({
    req(data())
    summary(data())
  })
  
  # Calculate optimal k using Elbow Method
  optimal_k <- eventReactive(input$find_optimal_k, {
    req(data())
    df <- data()
    
    # Select features for clustering
    features <- df %>%
      select(TotalSpent, Quantity) %>%
      scale()  # Normalize data
    
    # Calculate total within-cluster sum of squares for a range of k values
    k_values <- 1:10
    wss <- sapply(k_values, function(k) {
      kmeans(features, centers = k, nstart = 25)$tot.withinss
    })
    
    # Return the wss values and k values
    return(list(k_values = k_values, wss = wss))
  })
  
  # Suggest optimal k (Elbow Method)
  output$elbow_plot <- renderPlot({
    req(optimal_k())
    ggplot(data.frame(k = optimal_k()$k_values, wss = optimal_k()$wss), aes(x = k, y = wss)) +
      geom_line() +
      geom_point() +
      labs(title = "Elbow Method for Optimal k", x = "Number of Clusters (k)", y = "Within-Cluster Sum of Squares") +
      theme_minimal()
  })
  
  # Display optimal k value directly below the button
  output$optimal_k_value <- renderPrint({
    req(optimal_k())
    optimal_k_value <- optimal_k()$k_values[which.min(optimal_k()$wss)]  # Finding the k with minimum WSS
    paste("Suggested Optimal k: ", optimal_k_value)
  })
  
  # Perform K-Means clustering and generate outputs
  clustering <- eventReactive(input$run_kmeans, {
    req(data())
    df <- data()
    
    # Select features for clustering
    features <- df %>%
      select(TotalSpent, Quantity) %>%
      scale()  # Normalize data
    
    # Perform k-means clustering
    kmeans_result <- kmeans(features, centers = input$clusters, nstart = 25)
    
    # Add cluster assignments to data
    df$Cluster <- as.factor(kmeans_result$cluster)
    
    return(list(data = df, kmeans_result = kmeans_result))
  })
  
  # Scatter plot of clusters
  output$cluster_plot <- renderPlot({
    req(clustering())
    df <- clustering()$data
    ggplot(df, aes(x = Quantity, y = TotalSpent, color = Cluster)) +
      geom_point(alpha = 0.7, size = 3) +
      labs(title = "Customer Segmentation with K-Means Clustering", x = "Quantity", y = "Total Spent") +
      theme_minimal()
  })
  
  # Bar plot of top items in each cluster
  output$top_items_plot <- renderPlot({
    req(clustering())
    df <- clustering()$data
    
    # Identify top 5 StockCodes in each cluster based on count
    top_items <- df %>% 
      group_by(Cluster, StockCode) %>% 
      summarise(ItemCount = n(), .groups = "drop") %>%
      arrange(Cluster, desc(ItemCount)) %>% 
      group_by(Cluster) %>%
      slice_max(ItemCount, n = 5)  # Select top 5 StockCodes per cluster
    
    ggplot(top_items, aes(x = reorder(StockCode, -ItemCount), y = ItemCount, fill = Cluster)) +
      geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
      facet_wrap(~Cluster, scales = "free_x") +
      labs(
        title = "Top 5 Items by Stock Code in Each Cluster",
        x = "Stock Code",
        y = "Item Count",
        fill = "Cluster"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Cluster summary table
  output$cluster_summary <- renderDT({
    req(clustering())
    df <- clustering()$data
    cluster_summary <- df %>%
      group_by(Cluster) %>%
      summarise(
        Avg_Quantity = round(mean(Quantity), 2),
        Avg_TotalSpent = round(mean(TotalSpent), 2),
        Unique_StockCodes = n_distinct(StockCode),
        Count = n()
      )
    datatable(cluster_summary)
  })
  
  # Customer insights: Significant items and customer types
  output$significant_items <- renderDT({
    req(clustering())
    df <- clustering()$data
    significant_items <- df %>%
      group_by(Cluster, StockCode) %>%
      summarise(ItemCount = n(), .groups = "drop") %>%
      arrange(Cluster, desc(ItemCount)) %>%
      group_by(Cluster) %>%
      slice_max(ItemCount, n = 5)  # Top items in each cluster
    datatable(significant_items)
  })
  
  output$customer_types <- renderPrint({
    req(clustering())
    df <- clustering()$data
    
    # Identify customer types based on average total spend and frequency of purchase
    customer_types <- df %>%
      group_by(Cluster) %>%
      summarise(
        Avg_Spend = mean(TotalSpent),
        Avg_Frequency = n() / n_distinct(InvoiceNo),
        Type = case_when(
          Avg_Spend > 50 & Avg_Frequency > 5 ~ "Frequent Bulk Buyers",
          Avg_Spend > 50 & Avg_Frequency <= 5 ~ "Bulk Buyers",
          Avg_Spend <= 50 & Avg_Frequency > 5 ~ "Frequent Buyers",
          TRUE ~ "Occasional Buyers"
        )
      )
    
    # Display customer types by cluster
    print(customer_types)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
