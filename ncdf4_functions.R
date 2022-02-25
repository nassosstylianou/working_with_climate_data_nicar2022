library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(RNetCDF) # package for working with netcdfs
library(rgdal) # package for geospatial analysis
library(dplyr) #package for data manipulation in R
library(lubridate) #package  for working with dates in R
library(lattice) #package for data visualisation and graphics in R
library(RColorBrewer) #package  for colour scales in R


#This loads the data in and saves it to a variable called nc_data
nc_data <- nc_open('data/cru_ts4.05.2011.2020.tmp.dat.nc')

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

# The line of code below extracts the time variable from the netcdf file as an array into the time variable.
time <- ncvar_get(nc_data,"time")

time

#  Given the time variable will need to be interpreted based on the time units, we need to extract the units attribute and we can do so using the ncatt_get function
tunits <- ncatt_get(nc_data,"time","units")

# Save the time dimension
ntime <- dim(time)

# example of how we can convert time from days since to an actual date
time_cols <- as.character(lubridate::ymd(tunits$value) + time)

# Using the  ncvar_get() function as we have done to extract our three dimnensions of lon, lat and time, we use it to extract our temperature data, which is extracted as an array
tmp_array <- ncvar_get(nc_data, "tmp")

print(tmp_array)

# Finds the fill value used for missing data for the precipitation variable
fillvalue <- ncatt_get(nc_data, "tmp", "_FillValue")
fillvalue

# Assigns the fill value used for missing data for the temperature variable to be NA
tmp_array[tmp_array == fillvalue$value] <- NA

# Turn our array into a long vector
tmp_vector_long <- as.vector(tmp_array)
head(na.omit(tmp_vector_long))

# reshape the vector into a matrix using the dimensions we saved out when saving the individual variables lon, lat and time
tmp_matrix <- matrix(tmp_vector_long, nrow=nlon*nlat, ncol=ntime)

# looking at the dimensions of our matrix
dim(tmp_matrix)

head(na.omit(tmp_matrix))

# Creates a matrix for lon and lat together, which will be used to prepend to the tmp matrix when turning it into a dataframe 
lonlat_matrix <- as.matrix(expand.grid(lon,lat))

# Creates a joined up dataframe by first binding the two matrices and then converting it into a dataframe using the data.frame function
tmp_dataframe <- data.frame(cbind(lonlat_matrix, tmp_matrix))

# creates column headings for lon and lat cols
lon_lat_cols <- c("lon", "lat")

# joins the column names for lon and lat with the time columns
tmp_cols <- c(lon_lat_cols, 
              time_cols)

# assigns the column names for the tmp_dataframe
colnames(tmp_dataframe) <- tmp_cols

# ---------------
# Plotting our data

# selects a single array, a single slice, in this case January 2011 (the first array slide)
tmp_slice_january2011 <- tmp_array[,,1]
dim(tmp_slice_january2011)

# creates a set of 720 by 360 pairs of latitude and longitude values, one for each element in the temperature array
grid <- expand.grid(lon = lon, lat = lat)

# Sets breakpoints for the map we want to use below -specific values of the cutpoints of temperature categories are defined to cover the range of temperature - you can obviously tweak these and adjust to your data. 
cutpts <- c(-50, -25, -10, -5, 0, 5, 10, 25, 50)

# Visualises data in a map using the levelplot() function from the lattice package - using the grid above and the breakpoints we set above 
lattice::levelplot(tmp_slice_january2011 ~ lon * lat,
                   data = grid, at = cutpts, cuts = 11, pretty = T, 
                   col.regions = rev(brewer.pal(9, "RdYlBu")))


