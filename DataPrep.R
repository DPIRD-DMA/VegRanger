# basic prep for VegRanger

library(rgdal)
library(raster)


# rasters
veg <- raster("C:/ALL_PROJECTS/Fitzroy_veg/VegDSM/Attributes/VEG_GROUP/North/VEG_GROUP_North.tif")
  
lkup <- read.csv("C:/ALL_PROJECTS/Fitzroy_veg/VegDSM/Attributes/VEG_GROUP/Lookup_North_VegGroups.csv")

rmaptable <- lkup[, c("GridCode", "MauCode")]

# need to make MAU raster
rc <- reclassify(veg, rmaptable)

# reproject, so no need to do in shiny
pVeg <- projectRaster(veg, crs = CRS(SRS_string = "EPSG:3857"), method = "ngb")
writeRaster(pVeg,"C:/ALL_PROJECTS/Github/VegRanger/Shiny/data/VegGroup_North_9Sep2021.tif", datatype='INT2U', format="GTiff", overwrite=TRUE )

pMau <- projectRaster(rc, crs = CRS(SRS_string = "EPSG:3857"), method = "ngb")
writeRaster(pMau, "C:/ALL_PROJECTS/Github/VegRanger/Shiny/data/MAU_reclass_9Sep2021.tif", datatype='INT2U', format="GTiff", overwrite=TRUE)



### IN TEH END, I MADE IMAGE IN QGIS AND EXPORTED AS HIGH RES JPG, THEN TILED USING GDAL for leaflet.
### See text file about tiles.  

########################
# make color palettes 

########################
# read in shapefile

shp <- readOGR("C:/ALL_PROJECTS/Fitzroy_veg/Polygons", "Kimberley_PastLeases_zone51")

# transform to dd
shp.dd <- spTransform(shp, crs(veg))
  #show Property_I and Property_N, and use Region as tooltip, if possible. 
writeOGR(shp.dd, "C:/ALL_PROJECTS/Github/VegRanger/Shiny/data", "Kimberley_Leases", driver= "ESRI Shapefile")
