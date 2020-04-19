## Sara Sánchez-Heredero Martínez
## Viral evolution

#---------------- Load packages --------------------------------------------------
library(deSolve)

#---------------- Viral dynamics function --------------------------------------------------

rootfun <- function (t, y, parms) { return(y['v'] - 10**6) } # function that tells the function to stop when viral load > 10**6

viral_dynamics1 <- function(time, state, rates) {
  with(as.list(c(state, rates)), {
    dx <- lambda - d*x - beta*x*v
    dy <- beta*x*v - a*y
    dv <- k*y - u*v
    dw <- w
    return(list(c(dx, dy, dv, dw)))
  })
}

viral_dynamics2 <- function(time, state, rates) {
  with(as.list(c(state, rates)), {
    dx <- lambda - d*x - beta*x*(v+w)
    dy <- beta*x*(v+w) - a*y
    dv <- r*y - r*y*p - u*v
    dw <- r*y*p + k*y - u*w
    return(list(c(dx, dy, dv, dw)))
  })
}




#---------------- Infection before antiviral drug --------------------------------------------------

## Set infection parameters and initial conditions
initial_conditions <- c(x = 5e+9, y = 5, v = 1, w = 0) 
                        # x: uninfected cells
                        # y: infected cells
                        # x: viral load
lambda = 10**5 # healthy cell replication rate
beta = 2*10**(-7) # spreading, human transmision rate
d = 0.1 # natural cell death rate
a = 0.5  # infection cell death rate
u = 5  # viral death rate
k = 100 # viral replication rate

rates <- c(lambda, beta,d,a,u,k) #rates of infection (beta) and recovery (mu)
times1 <- seq(0, 2, by = 0.0001) # time scale (I set a small number because it will be cut off as soon as v > 10**6)

# model infection 
sol1<-ode(initial_conditions,times1,viral_dynamics1, parms=rates, rootfun = rootfun, method="lsodar")


#---------------- Infection before antiviral drug --------------------------------------------------

# add a new variable for the mutant virus that appears as a resistance to the antiviral drug
middle_conditions <- c(sol1[nrow(sol1),2], sol1[nrow(sol1),3], sol1[nrow(sol1),4], w = 0) 
middle_conditions <- c(x=4975214317, y=3177594, v=1000000, w = 0) 

p = 10**(-9) # generation rate of mutant variant 
r = 1 # viral replication rate when drug is administered 

rates2 <- c(lambda,beta,d,a,u,k,p,r) # rates of infection (beta) and recovery (mu)
times2 <- seq(sol1[nrow(sol1),'time'] , 0.2, by = 0.0001) # time scale

## use ode to get function solution for each time step and store as data frame in model
sol2 <- ode(middle_conditions, times2, viral_dynamics2, parms = rates2)

#---------------- Bind two infection stages --------------------------------------------------

y_values = rbind.data.frame(sol1[1:nrow(sol1)-1,],sol2)
y_values <- y_values[,2:5]
t = as.list(c(sol1[,'time'][1:nrow(sol1)-1], sol2[,'time']))

log_y = log(y_values)

#---------------- plot ------------------------------------------------------------------------
matplot(x = t, y = log_y, type = "l",
        xlab = "Days", ylab = "log(# infected)", main = "Viral infection", 
        col = c(x="green",y="red",v="blue",w='purple'))

legend(0.1, 15, c("healthy cells", "infected cells", "viral load",'mutant viral load'), cex= 0.95, pch = 1, col=c(x="green", y="red",v="blue",w='purple'), bty = "n")


#---------- NO DRUG & no mutant ----------------------------------------------------------------------

viral_dynamics <- function(time, state, rates) {
  with(as.list(c(state, rates)), {
    dx <- lambda - d*x - beta*x*v
    dy <- beta*x*v - a*y
    dv <- k*y - u*v
    dw <- w
    return(list(c(dx, dy, dv, dw)))
  })
}

## Set infection parameters and initial conditions
init <- c(x = 5e+9, y = 5, v = 1, w = 0) 
lambda = 10**5 # healthy cell replication rate
beta = 2*10**(-7) # spreading, human transmision rate
d = 0.1 # natural cell death rate
a = 0.5  # infection cell death rate
u = 5  # viral death rate
k = 100 # viral replication rate
r <- c(lambda, beta,d,a,u,k) #rates of infection (beta) and recovery (mu)
tim <- seq(0, 0.2, by = 0.0001) # time scale (I set a small number because it will be cut off as soon as v > 10**6)

# model infection 
sol<-ode(init,tim,viral_dynamics, parms=r)

# Plot
matplot(x = tim, y = log(sol[,2:5]), type = "l",
        xlab = "Days", ylab = "log(# infected)", main = "Viral infection", 
        col = c(x="green",y="red",v="blue",w='purple'))

legend(0.1, 15, c("healthy cells", "infected cells", "viral load",'mutant viral load'), cex= 0.95, pch = 1, col=c(x="green", y="red",v="blue",w='purple'), bty = "n")


