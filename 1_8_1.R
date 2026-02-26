library(shiny)

ui <- fluidPage(
  textInput("nombre", "¿Cuál es tu nombre?"),
  numericInput("edad", "¿Cuál es tu edad?", value = NA),
  textOutput("greeting")
)

server <- function(input, output, session) {
  output$greeting <- renderText({paste0("Hello ", input$nombre)})
}

shinyApp(ui, server)