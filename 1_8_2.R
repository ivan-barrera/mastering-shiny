library(shiny)

ui <- fluidPage(
  sliderInput("x", label = "Si *x* es", min = 1, max = 50, value =30),
  sliderInput("y", label = "y *y* es", min = 1, max = 50, value = 5),
  "entonces, (x por y) es: ", textOutput("producto"),
  "y, (x por y) es: ", textOutput("producto_mas5"),
  "y, (x por y) es: ", textOutput("producto_mas10")
)

server <- function(input, output, session) {
  producto <-reactive(input$x * input$y)

  output$producto <- renderText({
    producto()
  })
  output$producto_mas5 <- renderText({
    producto() + 5
  })
  output$producto_mas10 <- renderText({
    producto() + 10
  })
}

shinyApp(ui, server)