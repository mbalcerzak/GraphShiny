#### Load necessary packages and data ####
library(shiny)
library(networkD3)
library(igraph)

df <- read.csv("dataframe.csv", header=TRUE)

#### Server ####
server <- function(session, input, output) {
  
  output$domains <- renderUI({ selectInput(inputId = "domain",
                         label = "Select domain",
                         choices = c("ALL", "SDTM.VS","SDTM.QS")) })
  
  newData <- reactive({

    if (input$domain != "ALL") {
      isolate({
        
        datadata <- df
        datadata <- subset(datadata, source %in% input$domain)
       
      })
    } else {
      return(df)
    }
  })  
  
  
  output$simple <- renderSimpleNetwork({
    simpleNetwork(newData(), Source = "source", Target = "target",
                  zoom = T, fontSize = 17,
                  linkDistance = 150, charge = -250)
  })
}   

#### UI ####

ui <- shinyUI(fluidPage(
  
  titlePanel("SDTM Datasets in Shiny networkD3"),
  
  sidebarLayout(
    sidebarPanel(
      uiOutput(outputId="domains")
      
    ),
    mainPanel(
      simpleNetworkOutput("simple")
    )
  )
))

#### Run ####
shinyApp(ui = ui, server = server)
