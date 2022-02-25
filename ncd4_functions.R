library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(RNetCDF) # package for working with netcdfs
library(rgdal) # package for geospatial analysis
library(chron) #package to help with time conversions
library(dplyr) #package for data manipulation in R
library(lubridate) #package  for working with dates in R

#This loads the data in and saves it to a variable called nc_data
nc_data <- nc_open('~/Dropbox (BBC)/Visual Journalism/Data/2022/working_with_climate_data_nicar22/data/cru_ts4.05.2011.2020.tmp.dat.nc')

#To see some basic information about the data, print out the file. 
print(nc_data)

View(nc_data)


# The line of code below extracts the longitude variable from the netcdf file as an array into the lon variable.
lon <- ncvar_get(nc_data,"lon")
# Using the dim() function and passing our new lon variable to it gives us the dimensions of the l and saves it to the nlon variable.
nlon <- dim(lon)

# These functions just give you some insight into the lon variable
head(lon)
tail(lon)
max(lon)
min(lon)


# The line of code below extracts the latitude variable from the netcdf file as an array into the lat variable.
lat <- ncvar_get(nc_data,"lat")
# Using the dim() function and passing our new lat variable to it gives us the dimensions of the lat and saves it to the nlat variable.
nlat <- dim(lat)
# These functions just give you some insight into the lat variable
head(lat)
tail(lat)
max(lat)
min(lat)


time <- ncvar_get(nc_data,"time")

time


tunits <- ncatt_get(nc_data,"time","units")


ntime <- dim(time)

# old way of creating time cols
# # example of how we can convert time -- split the time units string into fields
# tustr <- strsplit(tunits$value, " ")
# tdstr <- strsplit(unlist(tustr)[3], "-")
# tmonth <- as.integer(unlist(tdstr)[2])
# tday <- as.integer(unlist(tdstr)[3])
# tyear <- as.integer(unlist(tdstr)[1])
# time_cols <- chron(time, origin=c(tmonth, tday, tyear)) %>% lubridate::mdy() %>% as.character()
# 
# time_cols %>% str()

time_cols <- as.character(lubridate::ymd(tunits$value) + time)


tmp_array <- ncvar_get(nc_data, "tmp")


# Finds the fill value used for missing data for the precipitation variable
fillvalue <- ncatt_get(nc_data, "tmp", "_FillValue")
fillvalue


tmp_array[tmp_array == fillvalue$value] <- NA



tmp_vector_long <- as.vector(tmp_array)


# reshape the vector into a matrix
tmp_matrix <- matrix(tmp_vector_long, nrow=nlon*nlat, ncol=ntime)

dim(tmp_matrix)


lonlat_matrix <- as.matrix(expand.grid(lon,lat))

tmp_dataframe <- data.frame(cbind(lonlat_matrix, tmp_matrix))

lon_lat_cols <- c("lon", "lat")

tmp_cols <- c(lon_lat_cols, 
              time_cols)

colnames(tmp_dataframe) <- tmp_cols



