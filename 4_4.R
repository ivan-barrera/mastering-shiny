library(shiny)
library(vroom)
library(tidyverse)

injuries <- vroom::vroom("neiss/injuries.tsv.gz")

products <- vroom::vroom("neiss/products.tsv")

population <- vroom::vroom("neiss/population.tsv")

prod_codes <- setNames(products$prod_code, products$title)

ui <- fluidPage(
  fluidRow(
    column(6,
    selectInput("code", "Product", choices = prod_codes))
  ),
  fluidRow(
    column(4, tableOutput("diag")),
    column(4, tableOutput("body_part")),
    column(4, tableOutput("location"))
  ),
  fluidRow(
    column(12, plotOutput("age_sex"))
  )
)

server <- function(input, output, session) {
  selected <- reactive(injuries |> filter(prod_code == input$code))

  output$diag <- renderTable(selected() |> count(diag, wt = weigt, sort = TRUE))

  output$body_part <- renderTable(selected() |> count(body_part, wt = eigth, sort = TRUE))

  output$location <- renderTable(selected() |> count(location, wt = weight, sort = TRUE))

  summary <- reactive({
    selected() |> 
      count(age, sex, wt = weigth) |> 
      left_join(population, by = c("age", "sex")) |> 
      mutate(rate = n / population * 1e4)
  })

  output$age_sex <- renderPlot({
    summary() |> 
      ggplot(aes(age, n, color = sex)) +
      geom_line() +
      labs(y = "Número estimado de lesiones", x = "Edad")
  }, res = 96)

}

shinyApp(ui, server)