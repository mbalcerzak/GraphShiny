#### Load necessary packages and data ####
library(shiny)
library(networkD3)
library(igraph)
library(visNetwork)

df <- read.csv("dataframe.csv", header=TRUE)
colnames(df) <- c("from","to")

namesdf <- read.csv("unique_names.csv", header=TRUE)

names <- c("ALL", levels(unlist(namesdf$x)))


visNetwork(nodes = namesdf, edges = df, width = "100%")


# %>% 
#   visEdges(arrows = "from") %>% 
#   visHierarchicalLayout() 


# ------------------------- Server --------------------------------#
server <- function(session, input, output) {
  
  output$domains <- renderUI({ selectInput(
                          inputId = "domain",
                          label = "Select domain",
                          choices = names,
                          selected = "ALL")})
  
  newData <- reactive({

    # Filter the dataset by the chosen value
    datadata <- df
    
    #print(input$domain) 
    if (!is.null(input$domain)) {
      if (input$domain != "ALL"){
        
        isolate({
          datadata <- subset(datadata, from %in% input$domain |
                                       to %in% input$domain)
        })
      }
    } 
    return(datadata)
  })  
  
  # output$network <- renderSimpleNetwork({
  #   simpleNetwork(newData(), Source = "source", Target = "target",
  #                 zoom = T, fontSize = 17,
  #                 linkDistance = 150, charge = -250,
  #                 height = 700, width = 500)
  # })
  
  output$network <- renderVisNetwork({visNetwork(nodes = names, 
                                                 edges = newData(), 
                                                 width = "100%") %>% 
                                      visEdges(arrows = "from") %>% 
                                      visHierarchicalLayout()  
                                    #,visOptions(nodesIdSelection = TRUE)
                                      })
}   

# ---------------------------- UI ----------------------------------#

ui <- shinyUI(fluidPage(
  
  titlePanel("SDTM Datasets in Shiny networkD3"),
  
  sidebarLayout(
    sidebarPanel(
      uiOutput(outputId="domains")
      
      #h3(textOutput("Unused datasets:"))
      
      # "save as csv" button to get a list of all datasets used to create another one
      
    ),
    mainPanel(
      simpleNetworkOutput("network")
    )
  )
))

# ----------------------------- RUN --------------------------------#
shinyApp(ui = ui, server = server)
