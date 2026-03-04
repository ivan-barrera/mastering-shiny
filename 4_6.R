library(shiny)
library(vroom)
library(tidyverse)

injuries <- vroom::vroom("neiss/injuries.tsv.gz")

products <- vroom::vroom("neiss/products.tsv")

population <- vroom::vroom("neiss/population.tsv")

prod_codes <- setNames(products$prod_code, products$title)

count_top <- function(df, var, n = 5) {
  df %>%
    mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
    group_by({{ var }}) %>%
    summarise(n = as.integer(sum(weight)))
}

ui <- fluidPage(
  fluidRow(
    column(8,
    selectInput("code", "Product",
     choices = prod_codes,
    width = "100%")),
    column(2,
    selectInput("y", "Y axis", c("rate", "count")))
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

  output$diag <- renderTable(count_top(selected(), diag), width = "100%")

  output$body_part <- renderTable(count_top(selected(), body_part), width = "100%")

  output$location <- renderTable(count_top(selected(), location), width = "100%")

  summary <- reactive({
    selected() |> 
      count(age, sex, wt = weight) |> 
      left_join(population, by = c("age", "sex")) |> 
      mutate(rate = n / population * 1e4)
  })

  output$age_sex <- renderPlot({
    if(input$y == "count") {
    summary() |> 
      ggplot(aes(age, n, color = sex)) +
      geom_line() +
      labs(y = "Número estimado de lesiones", x = "Edad")
    } else {
      summary() |> 
        ggplot(aes(age, rate, color = sex)) +
        geom_line(na.rm = TRUE) +
        labs( y = "Lesiones por 10,000 personas")
    }
  }, res = 96)

}

shinyApp(ui, server)