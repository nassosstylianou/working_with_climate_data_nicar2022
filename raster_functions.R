library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(RNetCDF) # package for working with netcdfs
library(rgdal) # package for geospatial analysis
library(chron) #package to help with time conversions
library(dplyr) #package for data manipulation in R
library(lubridate) #package  for working with dates in R


tmp_monthly <- brick('data/cru_ts4.05.2011.2020.tmp.dat.nc', 
                     varname = "tmp")

print(tmp_monthly)

plot(tmp_monthly)

plot(tmp_monthly[[1]])

plot(tmp_monthly[[120]])

# creates vector as index for calculating yearly averages

years <- rep(1:10, each = 12)

# calculates average for each year, resulting in 10 layers one for each year from 2011 to 2020
tmp_annual <- stackApply(tmp_monthly, indices = years, fun = mean)

plot(tmp_annual)

#turn into spatial polygons data frame
tmp_annual_df <- as(tmp_annual,
                    "SpatialPolygonsDataFrame")

# turn names of variables in the data frame as years
names(tmp_annual_df@data) <- c(as.character(2011:2020))

writeOGR(tmp_annual_df,
         "temperature_annual.geojson",
         layer = "tmp",
         driver = "GeoJSON")


# subsets years 2011 to 2015, the first 5 years in our annual data
tmp_annual_2011_2015 <- subset(tmp_annual, 1:5)

# calculates the mean for the five years we have subset
tmp_2011_2015_avg <- calc(tmp_annual_2011_2015,
                          mean,
                          na.rm = TRUE) 

# subsets years 2016 to 2020, years 6 to 10 in our annual data
tmp_annual_2016_2020 <- subset(tmp_annual, 6:10)

# calculates the mean for the five years we have subset
tmp_2016_2020_avg <- calc(tmp_annual_2016_2020,
                          mean,
                          na.rm = TRUE) 

# calculates the difference between the two averages 
tmp_avg_diff <- tmp_2016_2020_avg - tmp_2011_2015_avg


plot(tmp_avg_diff)


# write to GeoTIFF
writeRaster(tmp_avg_diff, 
            filename="tmp_avg_diff.tiff", 
            format = "GTiff",
            overwrite = TRUE)

# converts data into a spatial polygons data frame
tmp_avg_diff_df <- as(tmp_avg_diff, 
                      "SpatialPolygonsDataFrame")

# saves out data as a geojson
writeOGR(tmp_avg_diff_df,
         "temperature_annual.geojson",
         layer = "tmp",
         driver = "GeoJSON")
