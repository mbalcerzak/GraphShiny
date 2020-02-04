#### Load necessary packages and data ####
library(shiny)
library(networkD3)

df <- read.csv("dataframe.csv", header=TRUE)

#### Server ####
server <- function(input, output) {
  
  #filter_by <- input$domain
  
  output$simple <- renderSimpleNetwork({
    simpleNetwork(df, Source = "source", Target = "target",
                  fontSize = 7, zoom = T)
  })
  
}

#### UI ####

ui <- shinyUI(fluidPage(
  
  titlePanel("SDTM Datasets in Shiny networkD3"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("domain", h3("Datasets"),
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
