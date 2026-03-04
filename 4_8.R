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
      selectInput("y", "Y axis", c("rate", "count"))),
    column(1,
      numericInput("rows", "Number of rows", value = 5, min = 1, max = 10))
  ),
  fluidRow(
    column(4, tableOutput("diag")),
    column(4, tableOutput("body_part")),
    column(4, tableOutput("location"))
  ),
  fluidRow(
    column(12, plotOutput("age_sex"))
  ),
  fluidRow(
    column(2, actionButton("backward", "Atrás")),
    column(2, actionButton("forward", "Adelante"))
  ),
  fluidRow(
    column(2, h3("Historia", textOutput("clickCount", inline = TRUE))),
    column(4, h3(textOutput("narrative")))
  )
)

server <- function(input, output, session) {
  selected <- reactive(injuries |> filter(prod_code == input$code))

  output$diag <- renderTable(count_top(selected(), diag, n = input$rows), width = "100%")

  output$body_part <- renderTable(count_top(selected(), body_part, n = input$rows), width = "100%")

  output$location <- renderTable(count_top(selected(), location, n = input$rows), width = "100%")

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

# Esta sección retoma la respuesta que se encuentra en: https://mastering-shiny-solutions.org/case-study-er-injuries#exercise-5.8.4
  
  story<- reactiveVal(1)

  max_no_stories <- reactive(nrow(selected()))


  observeEvent(input$code, {
    story(1)
  })

  observeEvent(input$forward, {
    story((story() %% max_no_stories()) + 1)
  })

  observeEvent(input$backward, {
    story(((story() - 2) %% max_no_stories()) + 1)
  })

  
  output$narrative <- renderText({
    selected()$narrative[story()]
  })

  output$clickCount <- renderText({
    story()
  })

}

shinyApp(ui, server)

