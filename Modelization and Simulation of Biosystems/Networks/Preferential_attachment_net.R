## Sara Sánchez-Heredero Martínez
## Networks: Preferential attachment network
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
      
      if(V(g)$rumor[person] == 0){ # if that person didnt't already know the rumor
        V(g)$rumor[person] <<- 1 # change that person's state to 'know the rumor'
        V(g)$color[person] <<- "red"
        infected <<- infected + 1 # update the count of people that know the rumor
        
        new_interactions<- c(new_interactions, get_interactions(connections, person)) # find all people in contact with that person that now knows the rumor
        new_interactions <- unique(new_interactions) # remove duplications
      }
    }
    
    plot.igraph(g, layout= positions, vertex.label=NA)
    states <<- c(states, infected) # add the new count to the list
    model(new_interactions, max_iterations)
    
  }else{# when the maxumum number of iterations has been reached
    return(states)
    break # get out of the function
  } 
}
# if(is.na(match(0,V(g)$rumor))){break} # if every item in the network knows the rumor



#---------------- Construct network --------------------------------------------------
n_people = 60
transmision_rate = 0.05

g <- sample_pa(n_people, # Number of vertices.
          power = 1, # The power of the preferential attachment, the default is one, ie. linear preferential attachment.
          m = NULL, # Numeric constant, the number of edges to add in each time step This argument is only used if both out.dist and out.seq are omitted or NULL.
          out.dist = NULL, # Numeric vector, the distribution of the number of edges to add in each time step. This argument is only used if the out.seq argument is omitted or NULL.
          out.seq = NULL, #  Numeric vector giving the number of edges to add in each time step. Its first element is ignored as no edges are added in the first time step.
          out.pref = FALSE, #	Logical, if true the total degree is used for calculating the citation probability, otherwise the in-degree is used.
          zero.appeal = 1, # The ‘attractiveness’ of the vertices with no adjacent edges. See details below.
          directed = FALSE, # Whether to create a directed graph.
          algorithm = c("psumtree", "psumtree-multiple", "bag"),
          start.graph = NULL)

V(g)$color <- "lightblue"
V(g)$size <- 7
V(g)$rumor <- 0

positions <- layout_with_fr(g) #fix layout
plot.igraph(g, layout= positions, vertex.label=NA)

hist(degree_distribution(g))

average.path.length(g)
transitivity(g, type="average")




#---------------- Dynamics of the network --------------------------------------------------
connections <- rbind(g[1:length(g[1])])
p1 = sample(1:nrow(connections), 1, replace = FALSE, prob = NULL) # get person to start the rumor
generations <- 10

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



