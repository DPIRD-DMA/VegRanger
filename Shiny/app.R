
# 12-Sep-2021
# Simple Leaflet for Pasture type and MAU, to share with Rangelands group.  WOuld be nice to have opacity slider sometime. 

options("rgdal_show_exportToProj4_warnings"="none") 

library(shiny)
library(shinydashboard)
library(leaflet)
library(shinycssloaders)
library(shinyjs)


##################################################################################
#### Read in datasets and prep   ################

bounds <- readOGR("./data", layer = "Kimberley_Leases" ) #PROPERTY_I, PROPERTY_N, and Region

####################################################
# Define UI 
ui<-function(request){
  
  dashboardPage(
    skin = "blue",
    dashboardHeader(
      title = "Kimberley pasture types",
      titleWidth = 450
    ),

    dashboardSidebar(useShinyjs(),
                     tags$a(href='https://www.agric.wa.gov.au/rangelands/assessing-rangeland-condition',
                            tags$img(src='DPIRD-logo-white2.png'), style = 'position:absolute; top:65px;left:10px;',
                            tags$img(src='Legend_whiteText.png', height="80%", width="80%"), style = 'position:absolute; top:110px;left:20px;')
                 
    ), # end sidebar
    
    dashboardBody(
      fluidRow(
        width=800, height=700,
                leafletOutput("map1", width = "100%", height=850)
      ) # end fluidRow  
    ) # end dashboardBody
  ) # end dashboardPage
}  # end of ui function
#####################################################################
# Define server logic 

server <- function(input, output) {
  
  addResourcePath("myMAUtiles", "./data/MAU_tiles")
  addResourcePath("myVegtiles", "./data/Veg_tiles")
  
  # Leaflet map, with Esri imagery, calling as function
  output$map1 <- renderLeaflet({
    leaflet() %>% 
      setView(lat = -18, lng = 124.2, zoom =6.5) %>%
      addProviderTiles("OpenStreetMap.HOT", group = "Street map")%>% 
      addProviderTiles("Esri.WorldImagery", group = "Satellite")%>%
      addProviderTiles("OpenTopoMap", group = "Topo map") %>%
      
    #inset map showing location
      addMiniMap(
      tiles = providers$OpenStreetMap.HOT,
      toggleDisplay = TRUE, zoomLevelOffset=-5) %>%
      # Button to zoom to broader scale.
      addEasyButton(easyButton(
        icon="fa-globe", title="Zoom to full extent",
        onClick=JS("function(btn, map){ map.setZoom(6.5); }"))) %>%
      #button to zoom to location
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Locate Me",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
      # scale bar
      addScaleBar(position = "bottomleft", options = scaleBarOptions(metric=TRUE, imperial = FALSE)) %>%
      
      # custom tiles - MAU raster, exported from QGIS at 10000 dpi, then tiled in gdal. See text file. 
      addTiles(urlTemplate = "/myMAUtiles/{z}/{x}/{y}.png", 
               options = tileOptions(minZoom = 5, maxZoom = 14, tms = TRUE, opacity = 0.5),
               group= "MAU")%>%
      
      addTiles(urlTemplate = "/myVegtiles/{z}/{x}/{y}.png", 
               options = tileOptions(minZoom = 5, maxZoom = 14, tms = TRUE, opacity = 0.5),
               group= "Pasture types")%>%
      
      addLayersControl(baseGroups = c("Satellite", "Street map",  "Topo map"),
                       overlayGroups = c("MAU", "Pasture types"), 
                       options = layersControlOptions(collapsed = FALSE))%>%   
      hideGroup(c("MAU"))%>%    #this makes default 'uncheck'
      
      # add property polygons
      addPolygons(data = bounds,   
                  weight = 1,
                  #color = "black",
                  color = "#303030",  #dark grey
                  smoothFactor = 0.3,
                  fillOpacity = 0.0,
                  highlight = highlightOptions(
                    weight = 3,
                    color = "#ffea03", # bright yellow
                    #color = "#FF4500",  # orange red
                    fillOpacity = 0.0,
                    bringToFront = TRUE),
                  layerId = ~PROPERTY_I,
                  popup = paste0("Region: " , bounds$Region,"<br>", 
                                 bounds$PROPERTY_N, "<br>"),
                  group= "Property view") %>% 
      groupOptions("Property view", zoomLevels = 6:20) 
  })
  } # End server
  
  ###############################################
  # Run the application 
  shinyApp(ui = ui, server = server)  