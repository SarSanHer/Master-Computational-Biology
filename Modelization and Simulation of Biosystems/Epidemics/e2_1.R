############################ CREATE SIR MODEL ############################################
library(deSolve)

## define SIR model's mean field equations
SIR_function <- function(time, state, rates) {
  with(as.list(c(state, rates)), {
    dS <- -beta * S * I
    dI <- beta * S * I - mu * I
    dR <- mu * I
    return(list(c(dS, dI, dR)))
  })
}

## Parameters to initialize the model
initial_conditions <- c(S = 0.9, I = 0.1, R = 0.0) #% of population susceptible of infection, infected and recovered

beta = 0.1 #rate of infection
mu = 0.005 #rate of recovert
rates <- c(beta, mu) #rates of infection (beta) and recovery (mu)

times <- seq(0, 365, by = 1) ### THIS ARE THE PARAMS THAT DEFINE THE TIME SCALE OF THE EPIDEMIC


## use ode to get function solution for each time step and store as data frame in SIR_model
SIR_model <- ode(y = initial_conditions, times = times, func = SIR_function, parms = rates)
SIR_model <- as.data.frame(SIR_model) #make it a data frame
time_model <- as.data.frame(SIR_model) #make it a data frame
SIR_model$time <- NULL #deletes the time column from the dataframe

## Show data
head(SIR_model, 10)


## Plot
matplot(x = times, y = SIR_model, type = "l",
        xlab = "Time", ylab = "Number of people", main = "SIR Model",
        lwd = 2, lty = 1, bty = "l", col = c("green","red","blue"))

legend(250, 0.7, c("Susceptible", "Infected", "Recovered", "Thereshold (I)"), cex= 0.95, pch = 1, col = c("green","red","blue","brown"), bty = "n")


############################ EPIDEMIC THRESHOLD (R0) ############################################

##calculate the epidemic threshold value
N=10000
R0=(beta/mu)/100 # = thereshold (I)
abline(h=R0,col="brown",lty=4, lwd=1 ) #print that threshold in the plot

## find interception between threshold and and infected population in order to
## define the end of the epidemic at a certain threshold for the infected population
threshold = approxfun(SIR_model$I, times)
limit= threshold(R0)
#abline(v=limit,col="brown",lty=4, lwd=1 ) #print that threshold in the plot

#the state at the threshold point is:
SIR_model[round(limit),]


############################ max incidence of disease ############################################

initial_conditions <- c(S = 0.9, I = 0.1, R = 0.0) #% of population susceptible of infection, infected and recovered
mu = 0.005 #rate of recovert
b = seq(0, 1, by = 0.01) # create a list of beta values from 0 to 1
times <- seq(0, 365, by = 1) ### THIS ARE THE PARAMS THAT DEFINE THE TIME SCALE OF THE EPIDEMIC

max_incidence<-c()

for(i in b){
  beta <- i
  rates <- c(beta, mu) #rates of infection (beta) and recovery (mu)
  SIR_model <- ode(y = initial_conditions, times = times, func = SIR_function, parms = rates)
  SIR_model <- as.data.frame(SIR_model) #make it a data frame
  max_incidence <- c(max_incidence, max(SIR_model['I']))
}

plot(x=b, y=max_incidence, type = "l", 
     xlab = "ß values", ylab = "Maximum incidence", 
     lwd = 2, lty = 1, bty = "l", col = 'dark green'
     )



############################ changing µ ############################################

initial_conditions <- c(S = 0.9, I = 0.1, R = 0.0) #% of population susceptible of infection, infected and recovered
beta = 0.3 #rate of recovert
m = seq(0, 1, by = 0.001) # create a list of beta values from 0 to 1
times <- seq(0, 365, by = 1) ### THIS ARE THE PARAMS THAT DEFINE THE TIME SCALE OF THE EPIDEMIC

max_incidence<-c()

for(i in m){
  mu <- i
  rates <- c(beta, mu) #rates of infection (beta) and recovery (mu)
  SIR_model <- ode(y = initial_conditions, times = times, func = SIR_function, parms = rates)
  # SIR_model <- as.data.frame(SIR_model) #make it a data frame
  max_incidence <- c(max_incidence, max(SIR_model['I']))
}

plot(x=m, y=max_incidence, type = "l", 
     xlab = "µ values", ylab = "Maximum incidence", 
     lwd = 2, lty = 1, bty = "l", col = 'dark red'
)

