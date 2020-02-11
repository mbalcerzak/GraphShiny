#### Load necessary packages and data ####
library(shiny)
library(networkD3)
library(igraph)

df <- read.csv("dataframe.csv", header=TRUE)

# choices = all the unique values in dataset
# both in source and target

# different colours for RAW, SDTM, ...

# ------------------------- Server --------------------------------#
server <- function(session, input, output) {
  
  output$domains <- renderUI({ selectInput(
                          inputId = "domain",
                          label = "Select domain",
                          choices = c("ALL","SDTM.VS","SDTM.QS"),
                          selected = "ALL")})
  
  newData <- reactive({

    # Filter the dataset by the chosen value
    datadata <- df
    
    #print(input$domain) 
    if (!is.null(input$domain)) {
      if (input$domain != "ALL"){
        
        isolate({
          datadata <- subset(datadata, source %in% input$domain |
                                       source %in% input$target)
        })
      }
    } 
    return(datadata)
  })  
  
  output$simple <- renderSimpleNetwork({
    simpleNetwork(newData(), Source = "source", Target = "target",
                  zoom = T, fontSize = 17,
                  linkDistance = 150, charge = -250,
                  height = 500, width = 500)
  })
}   

# ---------------------------- UI ----------------------------------#

ui <- shinyUI(fluidPage(
  
  titlePanel("SDTM Datasets in Shiny networkD3"),
  
  sidebarLayout(
    sidebarPanel(
      uiOutput(outputId="domains")
      
      # "notify" button to send emails to programmers on main an QC side
      
      # "save as csv" button to get a list of all datasets used to create another one
      
    ),
    mainPanel(
      simpleNetworkOutput("simple")
    )
  )
))

# ----------------------------- RUN --------------------------------#
shinyApp(ui = ui, server = server)
