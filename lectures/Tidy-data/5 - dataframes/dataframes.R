## HEADER ####
## Who: Joseph Mhango
## What: tidy data
## Last edited: 2024-09-13
####

# --- Let's find our data file first ----

# Relative location in repo: dataframes/data/5-tidy.xlsx

# Try this

getwd() # Prints working directory in Console

setwd("./data")

# NB the quotes, and escape forward-slash "/"
# NB this is MY directory - change the PATH to YOUR directory :)

getwd() # Check that change worked

# --- Read in Excel data file ----

install.packages(openxlsx, dep = T) # Run if needed

library(openxlsx) # Load package needed to read Excel files

# Make sure the data file "5-tidy.xlsx" is in your working directory
my_data <- read.xlsx("5-tidy.xlsx")

# Note that the same procedure works with Comma Separated Values data files
# The R function used will be specific to the file type.
# E.g., `read.csv()` for CSV files, 
# `read.delim` for TAB delimited files,
# `read.table()` as a generic function to tailor to many types of plain text data files


# --- Let's explore this data' ----


class(my_data) # data.frame, a generic class for holding data


#  The `names()` function returns the name of attributes in R objects. When used on a data frame it returns the names of the variables.

# Try this
names(my_data)


# The `$` operator allows us to access variable names inside `R` objects. Use it like this:
# data_object$variable_name

# Try this

conc.ind # Error because the variable conc.ind is INSIDE my_data

my_data$conc.ind

# The `str()` function returns the STRUCTURE of a data frame. This includes variable names, classes, and the first few values

# Try this
str(my_data)

# The output similar to the graphical Global Environment view in RStudio. Note the `conc.ind` variable is classed numeric
# 
# Note the `treatment` variable is classed as character (not a factor)

 ## `[ , ]` the index operator
  
  # The index operator allows us to access specified rows and columns in data frames (this works exactly the same in matrices and other indexed objects).


# Try this
my_data$conc.tot # The conc.tot variable with $
my_data$conc.tot[1:6] # each variable is a vector - 1st to 6th values

help(dim)
dim(my_data) # my_data has 18 rows, 6 columns

my_data[ , ] # Leaving blanks means return all rows and columns

names(my_data) # Note conc.tot is the 6th variable

names(my_data)[6] # Returns the name of the 6th variable

my_data[ , 6] # Returns all rows of the 6th variable in my_data

# We can explicitly specify all rows (there are 18 remember)
my_data[1:18 , 6] # ALSO returns all rows of the 6th variable in my_data

# We can specify the variable names with a character
my_data[ , "conc.tot"]
my_data[ , "conc.ind"]

# Specify more than 1 by name with c() in the column slot of [ , ]
my_data[ , c("conc.tot", "conc.ind")]

##`attach()`

# The `attach()` function makes variable names available for a data frame in `R` space

# Try this
conc.ind # Error; the Passive-Aggressive Butler doesn't understand...

attach(my_data)
conc.ind # Now that my_data is "attached", the Butler can find variables inside

help(detach) # Undo attach()
detach(my_data)
conc.ind # Is Sir feeling well, Sir?



