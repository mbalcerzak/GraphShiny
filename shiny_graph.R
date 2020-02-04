#### Load necessary packages and data ####
library(shiny)
library(networkD3)

data(MisLinks)
data(MisNodes)

#### Server ####
server <- function(input, output) {
  
  output$simple <- renderSimpleNetwork({
    src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
    target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
    networkData <- data.frame(src, target)
    simpleNetwork(networkData, opacity = 0.8)
  })
  
}

#### UI ####

ui <- shinyUI(fluidPage(
  
  titlePanel("NOZOMI Datasets in Shiny networkD3"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("radio", h3("Datasets"),
                   choices = list("AttrOne" = "Attr1",
                                  "AttrTwo" = "Attr2"))
      
    ),
    mainPanel(
      simpleNetworkOutput("simple")
    )
  )
))

#### Run ####
shinyApp(ui = ui, server = server)