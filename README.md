# GraphShiny

The flow of clinical trials data can quickly become complicated. The dashboard presented can help programmers and project managers understand the data flow and quickly catch discrepancies

The dashboard can help answer such questions as:  
- What datasets are used to create each SDTM dataset on our study?
- Are all raw datasets used?
- Who should I notify if the underlying dataset changes?  

#### Graph showing connections between all the datasets
<img  width="885" height="655" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/shiny_graph.png">

#### Graph showing selected connections
Selecting a single node makes graph filter underlying dataset and show connections only for that dataset
<img  width="888" height="635" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/shiny_graph_select.png">

#### Graph showing connections only for SDTM.MM
<img  width="743" height="611" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/shiny_graph_mm.png">


#### Flow of data going into the Shiny App
<img  width="920" height="760" src="https://github.com/mbalcerzak/GraphShiny/blob/master/img/data_flow.png">
