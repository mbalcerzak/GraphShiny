#### Load necessary packages and data ####
library(shiny)
library(networkD3)
library(igraph)
library(visNetwork)
library(DT)

# TODO: make nodes smaller, labels bigger
# edges longer
# add validation log part
# change colors: gradation + no red
# presentation with dataflow chart

masked <- FALSE

if (masked == TRUE){
  
  # masked
  df <- as.data.frame(read.csv("dataframe_masked.csv", header=TRUE))
  namesdf <- as.data.frame(read.csv("unique_masked.csv", header=TRUE))
  
} else {
  
  # not masked
  df <- as.data.frame(read.csv("dataframe.csv", header=TRUE))
  namesdf <- as.data.frame(read.csv("unique_names.csv", header=TRUE))
}

names <- c("ALL", levels(unlist(namesdf$id)))

# ------------------------- Server --------------------------------#
server <- function(session, input, output) {
  
  output$domains <- renderUI({ selectInput(inputId = "domain",
                                           label = "Select domain",
                                           choices = names,
                                           selected = "ALL")
                             })
  
  newdf <- reactive({

    # Filter the dataset by the chosen value
    datadata <- df

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
  
  newnames <-  reactive({

    # Filter the dataset by the chosen value
    datadata <- namesdf

    if (!is.null(input$domain)) {
      if (input$domain != "ALL"){
        
        get_names <- newdf()
        
        from_in_list <- as.list(get_names$from)
        to_in_list <- as.list(get_names$to)
        
        every_dataset <- unique(c(from_in_list, to_in_list))
        s <- unlist(every_dataset)
        
        isolate({
          datadata <- subset(datadata, id %in% s)
        })
      }
    } 
    return(datadata)
  }) 
  

  
  output$network <- renderVisNetwork({visNetwork(edges = newdf(), nodes = newnames(), width = "100%") %>%
                                      visEdges(arrows = "to") %>%
                                      visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T)) %>% 
                                      visIgraphLayout(randomSeed = 13) %>%
                                      visNodes(
                                        shape = "dot",
                                        size = 10,
                                        color = list(
                                          background = "#0085AF",
                                          border = "#013848",
                                          highlight = "#FF8000"
                                        ),
                                        shadow = list(enabled = TRUE, size = 10),
                                        font = list( size = 20)
                                      ) %>%
                                      visEdges(length = 25) %>%
                                      visEvents(click = "function(nodes){
                                                    Shiny.onInputChange('domain', nodes.nodes[0]);
                                                    ;}"
                                      )
    })
  
  
  output$table <- renderDT(
    if (!is.null(input$domain)) {
      if (input$domain != "ALL"){
        newdf()
      }
    })
  
  output$download_data <- downloadHandler(
    filename = "dataset_connections.csv",
    content = function(file) {
      data <- newdf()
      write.csv(data, file, row.names = FALSE)
    }
  )

  output$shiny_return <- renderPrint({
    visNetworkProxy("network") %>%
      visNearestNodes(target = input$click)
  })
  
}   

# ---------------------------- UI ----------------------------------#

ui <- shinyUI(fluidPage(
  
  titlePanel("Clinical Datasets graph"),

  sidebarLayout(
    sidebarPanel(
      uiOutput(outputId="domains"),

      h5("Used datasets:"),
      dataTableOutput('table'),
      downloadButton("download_data")

    ),
    mainPanel(
      visNetworkOutput("network", height = "800px")
    )
  )
))

# ----------------------------- RUN --------------------------------#
shinyApp(ui = ui, server = server)
