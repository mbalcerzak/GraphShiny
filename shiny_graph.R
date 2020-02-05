#### Load necessary packages and data ####
library(shiny)
library(networkD3)
library(igraph)
library(edgebundleR)

df <- read.csv("dataframe.csv", header=TRUE)

#### Server ####
server <- function(input, output) {
  
  #filter_by <- reactive({input$domain})
  
  #df <- df[df$source == filter_by,]
  
  output$simple <- renderSimpleNetwork({
    simpleNetwork(df, Source = "source", Target = "target",
                  zoom = T, fontSize = 14,
                  linkDistance = 100, charge = -200)
  })

}

#### UI ####

ui <- shinyUI(fluidPage(
  
  titlePanel("SDTM Datasets in Shiny networkD3"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("domain", h3("Datasets"),
                   choices = list("SDTM.VS","RAW.DM"))
      
    ),
    mainPanel(
      simpleNetworkOutput("simple") 
    )
  )
))

#### Run ####
shinyApp(ui = ui, server = server)
