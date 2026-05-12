library(shiny)
library(shinydashboard)
library(DBI)
library(RSQLite)
library(ggplot2)
library(dplyr)
library(reshape2)
library(lubridate)
library(shinyWidgets)
library(rmarkdown)

con <- dbConnect(SQLite(), "C:/Users/Randiv/Desktop/ASSIGNMENT/northstar_dataset/NorthStar.db")

ui <- dashboardPage(
  dashboardHeader(title = "NorthStar Analytics Pro"),

  dashboardSidebar(
    dateRangeInput("date", "Date Range", start = Sys.Date()-30, end = Sys.Date()),

    pickerInput("hub", "Hub",
                choices = c("All", dbGetQuery(con, "SELECT DISTINCT hub_id FROM deliveries")$hub_id),
                multiple = TRUE),

    pickerInput("driver", "Driver",
                choices = c("All", dbGetQuery(con, "SELECT DISTINCT driver_id FROM deliveries")$driver_id),
                multiple = TRUE),

    downloadButton("report", "Export PDF")
  ),

  dashboardBody(
    fluidRow(
      valueBoxOutput("kpi1"),
      valueBoxOutput("kpi2"),
      valueBoxOutput("kpi3"),
      valueBoxOutput("kpi4")
    ),

    fluidRow(
      box(plotOutput("hubDelay"), width = 6),
      box(plotOutput("hubRating"), width = 6)
    ),

    fluidRow(
      box(plotOutput("driverPerf"), width = 6),
      box(plotOutput("hubScatter"), width = 6)
    ),

    fluidRow(
      box(plotOutput("heatmap"), width = 12)
    )
  )
)

server <- function(input, output) {

  filtered_data <- reactive({
    dbGetQuery(con, "
      SELECT *,
      julianday(delivery_completed_at) - julianday(dispatch_time) AS delivery_days
      FROM deliveries
    ")
  })

  output$kpi1 <- renderValueBox({
    valueBox(round(mean(filtered_data()$delivery_days, na.rm = TRUE)*1440,1),
             "Avg Delivery Time", icon = icon("clock"))
  })

  output$kpi2 <- renderValueBox({
    valueBox(round(mean(filtered_data()$customer_rating_post_delivery, na.rm = TRUE),2),
             "Avg Rating", icon = icon("star"))
  })

  output$kpi3 <- renderValueBox({
    valueBox(round(mean(filtered_data()$fuel_or_charge_cost, na.rm = TRUE),2),
             "Avg Fuel Cost", icon = icon("gas-pump"))
  })

  output$kpi4 <- renderValueBox({
    valueBox(nrow(filtered_data()), "Total Deliveries", icon = icon("truck"))
  })

  output$hubDelay <- renderPlot({
    df <- filtered_data() %>%
      group_by(hub_id) %>%
      summarise(avg_time = mean(delivery_days, na.rm=TRUE)*1440)

    ggplot(df, aes(hub_id, avg_time)) + geom_col()
  })

  output$hubRating <- renderPlot({
    df <- filtered_data() %>%
      group_by(hub_id) %>%
      summarise(avg_rating = mean(customer_rating_post_delivery, na.rm=TRUE))

    ggplot(df, aes(hub_id, avg_rating)) + geom_col()
  })

  output$driverPerf <- renderPlot({
    df <- filtered_data() %>%
      group_by(driver_id) %>%
      summarise(avg_rating = mean(customer_rating_post_delivery, na.rm=TRUE)) %>%
      arrange(desc(avg_rating)) %>%
      head(10)

    ggplot(df, aes(reorder(driver_id, avg_rating), avg_rating)) +
      geom_col() + coord_flip()
  })

  output$hubScatter <- renderPlot({
    df <- filtered_data() %>%
      group_by(hub_id) %>%
      summarise(avg_time = mean(delivery_days, na.rm=TRUE)*1440,
                avg_rating = mean(customer_rating_post_delivery, na.rm=TRUE))

    ggplot(df, aes(avg_time, avg_rating, label = hub_id)) +
      geom_point(size=4) +
      geom_text(vjust=-1)
  })

  output$heatmap <- renderPlot({
    df <- filtered_data() %>%
      select(delivery_days, manual_route_override_count, fuel_or_charge_cost, customer_rating_post_delivery)

    c <- cor(df, use="complete.obs")
    m <- melt(c)

    ggplot(m, aes(Var1, Var2, fill=value)) +
      geom_tile()
  })

  output$report <- downloadHandler(
    filename = function() {
      paste("NorthStar_Report", Sys.Date(), ".pdf", sep="")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      writeLines(c(
        "---",
        "title: 'NorthStar Report'",
        "output: pdf_document",
        "---",
        "```{r}",
        "print(summary(filtered_data()))",
        "```"
      ), tempReport)

      rmarkdown::render(tempReport, output_file = file, envir = new.env(parent = globalenv()))
    }
  )
}

shinyApp(ui, server)