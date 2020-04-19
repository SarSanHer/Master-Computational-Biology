## Sara Sánchez-Heredero Martínez
## Network: Erdös-Rényi network

#---------------- Load packages --------------------------------------------------
library(igraph)
library(deSolve)

#---------------- Create functions for net interactions --------------------------------------------------

## function to find all interactions of a given vertex
get_interactions <- function(matrix, person){ 
  my_inter <-c()
  indice=1
  for(i in matrix[person,]){
    if(i != 0){ # if the chosen position is not 0 == if there is an interaction 
      my_inter <- c(my_inter, indice) # add the interaction index
    }
    indice = indice + 1
  }
  return(my_inter)
}

## RECURSIVE function to model rumor spreading 
# parameters to initialize function
infected <- 0 #number of people that know the rumor at first
iteration <- 0 
states <- c()

model <- function(people,max_iterations){
  new_interactions <- c()
  if(iteration != max_iterations){
    iteration <<- iteration + 1 #update count
    
    for(person in people){ # iterate over people that have had connection with a rumor spreader
      
      if(V(net)$rumor[person] == 0){ # if that person didnt't already know the rumor
        V(net)$rumor[person] <<- 1 # change that person's state to 'know the rumor'
        V(net)$color[person] <<- "red"
        infected <<- infected + 1 # update the count of people that know the rumor
        
        new_interactions<- c(new_interactions, get_interactions(connections, person)) # find all people in contact with that person that now knows the rumor
        new_interactions <- unique(new_interactions) # remove duplications
      }
    }
    
    plot.igraph(net, layout= positions, vertex.label=NA)
    states <<- c(states, infected) # add the new count to the list
    model(new_interactions, max_iterations)
    
  }else{# when the maxumum number of iterations has been reached
    return(states)
    break # get out of the function
  } 
}
# if(is.na(match(0,V(net)$rumor))){break} # if every item in the network knows the rumor



#---------------- Construct network --------------------------------------------------
n_people = 60
transmision_rate = 0.05

net <- sample_gnp(n_people, transmision_rate, directed = FALSE, loops = FALSE) # sample_gnp(#people, P(propagation))
hist(degree_distribution(net))

V(net)$color <- "lightblue"
V(net)$size <- 7
V(net)$rumor <- 0

positions <- layout_with_fr(net) #fix layout
plot.igraph(net, layout= positions, vertex.label=NA)

#plot(net, vertex.label=NA)





#---------------- Dynamics of the network --------------------------------------------------
connections <- rbind(net[1:length(net[1])])
p1 = sample(1:nrow(connections), 1, replace = FALSE, prob = NULL) # get person to start the rumor
generations <- 10

# parameters to initialize function
infected <- 0 #number of people that know the rumor at first
iteration <- 0 
states <- c()

# call model
dI <- model(p1,generations)

dS <- c()
for (i in dI){
  val <-  n_people - as.integer(i) 
  dS <<- c(dS,val)
}

states_matrix <- cbind.data.frame(dS, dI)






##---------------- Plot Dynamics --------------------------------------------------
time <- seq(1, generations, by = 1)
matplot(x = time, y = states_matrix, type = "l",
        xlab = "Time", ylab = "Number of people who know", main = "Rumor spreading model",
        lwd = 2, lty = 1, bty = "l", col = c("green","red"))

legend(6, 30, c("Still don't know", "Know rumor"), cex= 0.95, pch = 1, col = c("green","red"), bty = "n")



