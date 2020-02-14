# GraphShiny

The flow of clinical trials data can quickly become complicated. The dashboard presented can help programmers and project managers understand the data flow and quickly catch discrepancies

**The dashboard can help with:**
- visually exploring dataset connections  
- ensuring that all main/QC programmers get notified if the underlying dataset changes  
- making sure all raw datasets are necessary and used on the study  
- checking if the actual data flow is in accordance with specification and industry/company standards
- comparing inputs between main and QC programs  
- making sure we have all the datasets necessary to create each domain
  

## Creating the dataset

Program **create_graph_input.R** checks SAS programs using regular expressions (REGEX). Program looks for mentions of "RAW", "SDTM" and "ADAM" to create a list of all datasets used while creating the program. 

## Graph showing connections between all the datasets

While the app is starting the graph shows all the datasets in the input data

<img  width="885" height="655" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/shiny_graph.png">

## Graph showing connections only for SDTM.MM

Selecting a single node makes graph filter underlying dataset and show connections only for that dataset. It also outputs a reactive table where we can see the relations in a tabular form. User can download the dataset any time.

<img  width="743" height="611" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/shiny_graph_mm.png">


## Flow of data going into the Shiny App

<img  width="920" height="760" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/data_flow.png">
