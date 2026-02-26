library(shiny)
library(bslib)

ui <- page_fluid(
  textInput("caja", NULL, placeholder = "Your name"),
  sliderInput("fecha", "When should we deliver?", value = as.Date("2020-09-17"), min = as.Date("2020-09-16"), max = as.Date("2020-09-23")),
  sliderInput("intervalo", "Intervalo de 5", value = 0, min = 0, max = 100, step = 5),
  selectInput()
)

server <- function(input, output, session) {

}

shinyApp(ui, server)