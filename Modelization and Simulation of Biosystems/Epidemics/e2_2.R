## Sara Sánchez-Heredero Martínez
## Epidemic dynamics

library(deSolve)

#--------------------SIR model--------------------------------------------
rootfun <- function (t, y, parms) { return((y['R']+y['S']) - 1) } # function that tells the function to stop when humankind goes extinct (=0)

SIR_function <- function(time, state, rates) {
  with(as.list(c(state, rates)), {
    dS <- -beta * S * I - 0.2 * S * vac # - infected - veccinated
    dI <- beta * S * I - 0.8 * I * vac # infected - recovered - vaccinated/cured
    dR <- 0.2 * S * vac + 0.8 * I * vac # recovered + vaccinated/cured

    # if((R + S) < 0.1){
    #   print("Humankind has been erased... you should have found the cure sooner!!!")
    #   return(list(c(dS, dI, dR)))
    #   break 
    #   #else 
    #   #humankind <- append(n_humans, humankind)
    # }
    return(list(c(dS, dI, dR)))
  })
}

#-------------------- general parameters --------------------------------------------

# DEFINE D DAY
D=300
Epidemic_period=365*20

# Epidemic rates
infectious_period = 1           # infectious period
latent_period = 0.009259259259  # latent period

beta = 0.01 #infection rate
delta = latent_period #transmision rate
vac = 0  #recovery rate


#-------------------- Apocalypse Stage I: no cure -----------------------------------

# Parameters to initialize the model
initial_conditions <- c(S = 0.9, I=0.1, R = 0.0) #% of population susceptible of infection, infected and recovered
rates_beforeDday <- c(beta, delta, vac) #rates of infection (beta) and recovery (gamma)
time_beforeDday <- seq(0, D, by = 1) # time before finding the cure for the zombie virus

# model
SIR_beforeDday <- ode(y = initial_conditions, times = time_beforeDday, func = SIR_function, parms = rates_beforeDday, rootfun = rootfun, method="lsodar")
SIR_beforeDday <- as.data.frame(SIR_beforeDday) #make it a data frame
SIR_beforeDday$time <- NULL #deletes the time column from the dataframe



#-------------------- Apocalypse Stage II: YES cure -----------------------------------

# Parameters after finding the cure the model
afterDday_conditions <- c(S = SIR_beforeDday[D,1], I=SIR_beforeDday[D,2], R = SIR_beforeDday[D,3]) #% of population susceptible of infection, infected and recovered

V = 500000 # number of people that within gets "vaccinated" and therefore cured
N=700000000 # population of 7 billion people
vac = V/N
rates_afterDday <- c(beta, delta, vac) #rates of infection (beta) and recovery (gamma)
time_afterDday <- seq(0, Epidemic_period-D-1, by = 1) # time before finding the cure for the zombie virus

# model
SIR_afterDday <- ode(y = afterDday_conditions, times = time_afterDday, func = SIR_function, parms = rates_afterDday,rootfun = rootfun, method="lsodar")
SIR_afterDday <- as.data.frame(SIR_afterDday) #make it a data frame
SIR_afterDday$time <- NULL #deletes the time column from the dataframe





#-------------------- Apocalypse overall -----------------------------------

# merge the population values before and after D day in order to plot them
y_values = rbind.data.frame(SIR_beforeDday,SIR_afterDday)
time_apocalypse <- seq(0, Epidemic_period, by = 1) # apocalyses 




#-------------------- plot simulation -------------------------------------

matplot(x = time_apocalypse, y = y_values, type = "l",
        # xlab = "Time", ylab = "Number of people", main = "SIR Model",
        lwd = 2, lty = 1, bty = "l", col = c("green","red","blue"))

legend(4000, 0.6, c("Susceptible","Infected","Recovered"), cex= 0.75, pch = 1, col = c("green","red","blue"), bty = "n")




#-------------------- Humakind -------------------------------------

humankind <- y_values['R'] + y_values['S']
matplot(x = time_apocalypse, y = humankind, type = "l",
        xlab = "Time", ylab = "Number of healthy people", main = "SIR Model",
        lwd = 2, lty = 1, bty = "l", col = 'dark green')

min(humankind) # 0.1569561 -> 15% of population


# plot how low humankind would go as the days before the vaccine is found increases
posible_D_days <- seq(2, 2*365, by = 1) # two years
minim<-c()

for(i in posible_D_days){

  D <- i

  #stage I
  initial_conditions <- c(S = 0.9, I=0.1, R = 0.0) 
  vac <- 0
  rates_beforeDday <- c(beta, delta, vac) 
  time_beforeDday <- seq(0, D, by = 1) 
  SIR_beforeDday <- ode(y = initial_conditions, times = time_beforeDday, func = SIR_function, parms = rates_beforeDday)
  SIR_beforeDday <- as.data.frame(SIR_beforeDday) #make it a data frame
  SIR_beforeDday$time <- NULL #deletes the time column from the dataframe
  
  #stage II
  afterDday_conditions <- c(S = SIR_beforeDday[D,1], I=SIR_beforeDday[D,2], R = SIR_beforeDday[D,3]) 
  vac <- V/N
  rates_afterDday <- c(beta, delta, vac) #rates of infection (beta) and recovery (gamma)
  time_afterDday <- seq(0, Epidemic_period-D-1, by = 1) # time before finding the cure for the zombie virus
  SIR_afterDday <- ode(y = afterDday_conditions, times = time_afterDday, func = SIR_function, parms = rates_afterDday)
  SIR_afterDday <- as.data.frame(SIR_afterDday) #make it a data frame
  SIR_afterDday$time <- NULL #deletes the time column from the dataframe
  
  #merge
  y_values = rbind.data.frame(SIR_beforeDday,SIR_afterDday)
  humankind <- y_values['R'] + y_values['S']
  
  #estimate minimum
  minim <- c(minim, min(humankind))
  
}

plot(x=posible_D_days, y=minim, type = "l", 
     xlab = "Days", ylab = "Humankind", 
     lwd = 2, lty = 1, bty = "l", col = 'dark red')


