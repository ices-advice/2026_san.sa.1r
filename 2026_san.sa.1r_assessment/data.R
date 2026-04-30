## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)
taf.library(smsR)

mkdir("data")

# set data directory
wd <- taf.data.path("1r")

wd <- "1r"

maxage <- 4
years = 1983:2025
nyear <- length(years)
seasons <- 1:2
dat <- getDataSMS(wd,
                  maxage = maxage,
                  survey.age = list(0:1, 1:3), # Ages in the two surveys
                  survey.years = list(2004:2025, 2016:2025),# 2015:2024),
                  survey.names = c('Dredge','RTM'),
                  survey.quarter = c(2, 1),
                  years = years,
                  seasons = seasons
                  
)


Qminage = c(0,1) # Qminage = c(0,1) minimum age in surveys
Qmaxage = c(1,3) #Qmaxage = c(1,3)
surveyStart = c(0.75,0) #c(0.75,0)
surveyEnd =  c(1,0) # c(1,0) Does the survey last throughout the season it's conducted?
surveySeason = c(2,1) # c(2,1)Which seasons do the surveys occur in
surveyCV =  list(c(0,1),c(1,2)) #c(1,2)),
# Load packages and files #

ages <- 0:maxage
nseason <- 2 # Number of seasons
beta <- 105809
Bpa <- 140824
# Fishing effort
# Get the effort data
Feffort <- matrix(scan(file.path(wd,'effort.in'), comment.char = '#'),
                  ncol = 2, nrow = nyear)

# Normalize effort to 1
# Format input data matrices into TMB style
Surveyobs <- survey_to_matrix(dat[['survey']], years)
Catchobs <- df_to_matrix(dat[['canum']], season =  1:2)

nocatch <- read.table(file.path(wd,'zero_catch_year_season.in'), comment = '#', skip = 3)

# Save some data for package example
dat$effort <- Feffort
dat$nocatch <- nocatch
mtrx <- dat[['mtrx']]


df.tmb <- get_TMB_parameters(
  mtrx = mtrx, # List that contains M, mat, west, weca
  Surveyobs = Surveyobs, # Survey observations (dimensions age, year, quarter, number of surveys)
  Catchobs = Catchobs, # Catch observations  (dimensions age, year, quarter)
  years = years, # Years to run
  nseason = nseason, # Number of seasons
  useEffort = 1,
  endYear = 2025,
  ages = ages, # Ages of the species
  recseason = 2, # Season where recruitment occurs
  CminageSeason = c(1,1),
  Fmaxage = 3, # Full selected fishing mortality age
  Qminage = Qminage, # Qminage = c(0,1) minimum age in surveys
  Qmaxage = Qmaxage, #Qmaxage = c(1,3)
  Fbarage = c(1,2),
  isFseason = c(1,0), # Seasons to calculate fishing in
  effort = Feffort,
  # tuneCatch = 1,
  # tuneStart = 2015,
  # leavesurveyout = c(1,1),
  blocks = c(1983,1999, 2022), ##, SSB retro goes away with a block in 2010
  endFseason = 2, # which season does fishing stop in the final year of data
  nocatch = as.matrix(nocatch),
  surveyStart = surveyStart, #c(0.75,0)
  surveyEnd =  surveyEnd, # c(1,0) Does the survey last throughout the season it's conducted?
  surveySeason = surveySeason, # c(2,1)Which seasons do the surveys occur in
  surveySD =  surveyCV, #c(1,2)),
  catchSD = list(c(0,1,3),
                 c(0,1,3)),
  recmodel = 1, # Chose recruitment model (2 = estimated)
  estSD = c(0,2,0), # Estimate
  beta = 105809, # Hockey stick plateau
  nllfactor = c(1,1,0.05)
  
)


df.tmb$Bpa <- Bpa

saveRDS(df.tmb, file = "data/df.tmb.rds")
saveRDS(Bpa, file = "data/Bpa.rds")
