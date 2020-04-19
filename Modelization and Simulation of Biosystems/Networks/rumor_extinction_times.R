## Sara Sánchez-Heredero Martínez
## Networks: Repeat the simulation a large number of times. 
            # Record the time at which the rumor stops propagating (if it does at all). 
            # Plot the distribution of rumor extinction times.


#---------------- Load packages --------------------------------------------------
library(igraph)
library(deSolve)
library(sm)

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

model <- function(people,max_iterations){
  new_interactions <- c()
  if(is.na(match(0,V(g)$rumor))){  # if every item in the network knows the rumor
    #plot.igraph(g, layout= positions, vertex.label=NA)
    #print('break1')
    return(iteration)
    break
    
  }else if (iteration != max_iterations){
    iteration <<- iteration + 1 #update count
    
    for(person in people){ # iterate over people that have had connection with a rumor spreader
      if(V(g)$rumor[person] == 0){ # if that person didnt't already know the rumor
        V(g)$rumor[person] <<- 1 # change that person's state to 'know the rumor'
        V(g)$color[person] <<- "red"
        #print('here!')
        infected <<- infected + 1 # update the count of people that know the rumor
        
        new_interactions<- c(new_interactions, get_interactions(connections, person)) # find all people in contact with that person that now knows the rumor
        new_interactions <- unique(new_interactions) # remove duplications
      }
    }
    
    states <<- c(states, infected) # add the new count to the list
    model(new_interactions, max_iterations)
    
  }else{# when the maxumum number of iterations has been reached
    #plot.igraph(g, layout= positions, vertex.label=NA)
    #print('break2')
    return(max_iterations + 1)
    break # get out of the function
  } 
}
# if(is.na(match(0,V(g)$rumor))){break} # if every item in the network knows the rumor



#---------------- Params --------------------------------------------------
n_people = 60
transmision_rate = 0.05


#---------------- Small-Wordl network --------------------------------------------------
sm_net <- c()

for(a in 1:100){ #repeat the model 100 times
  #cat('iteration:',a,"\n")
  
  # create net:
  g <- watts.strogatz.game(1, n_people, 5, transmision_rate) 
  
  #plot
  V(g)$color <- "lightblue"
  V(g)$size <- 7
  V(g)$rumor <- 0
  positions <- layout_with_fr(g) #fix layout
  #plot.igraph(g, layout= positions, vertex.label=NA)
  
  
  # set rumor start:
  connections <- rbind(g[1:length(g[1])])
  p1 = sample(1:nrow(connections), 1, replace = FALSE, prob = NULL) # get person to start the rumor
  #cat("\tperson:",p1,"\n")
  generations <- 20
  
  # parameters to initialize function
  infected <- 0 #number of people that know the rumor at first
  iteration <- 0 
  states <- c()
  
  # call functio 
  rounds <- model(p1,generations)
  sm_net <<- c(sm_net, rounds)
}




#---------------- Preferential-attachment network --------------------------------------------------
pa_net <- c()

for(a in 1:100){ #repeat the model 100 times
  #cat('iteration:',a,"\n")
  
  # create net:
  g <- sample_pa(n_people, power = 1,m = NULL,out.dist = NULL,out.seq = NULL,out.pref = FALSE,zero.appeal = 1,
                 directed = FALSE,algorithm = c("psumtree", "psumtree-multiple", "bag"),start.graph = NULL)
  
  #plot
  V(g)$color <- "lightblue"
  V(g)$size <- 7
  V(g)$rumor <- 0
  positions <- layout_with_fr(g) #fix layout
  #plot.igraph(g, layout= positions, vertex.label=NA)
  
  
  # set rumor start:
  connections <- rbind(g[1:length(g[1])])
  p1 = sample(1:nrow(connections), 1, replace = FALSE, prob = NULL) # get person to start the rumor
  #cat("\tperson:",p1,"\n")
  generations <- 20
  
  # parameters to initialize function
  infected <- 0 #number of people that know the rumor at first
  iteration <- 0 
  states <- c()
  
  # call functio 
  rounds <- model(p1,generations)
  pa_net <<- c(pa_net, rounds)
}



#---------------- Erdös-Rényi network --------------------------------------------------
er_net <- c()

for(a in 1:100){ #repeat the model 100 times
  #cat('iteration:',a,"\n")
  
  # create net:
  g <- sample_gnp(n_people, transmision_rate, directed = FALSE, loops = FALSE) # sample_gnp(#people, P(propagation))
  
  #plot
  V(g)$color <- "lightblue"
  V(g)$size <- 7
  V(g)$rumor <- 0
  positions <- layout_with_fr(g) #fix layout
  #plot.igraph(g, layout= positions, vertex.label=NA)
  
  
  # set rumor start:
  connections <- rbind(g[1:length(g[1])])
  p1 = sample(1:nrow(connections), 1, replace = FALSE, prob = NULL) # get person to start the rumor
  #cat("\tperson:",p1,"\n")
  generations <- 20
  
  # parameters to initialize function
  infected <- 0 #number of people that know the rumor at first
  iteration <- 0 
  states <- c()
  
  # call functio 
  rounds <- model(p1,generations)
  #plot.igraph(g, layout= positions, vertex.label=NA)
  er_net <<- c(er_net, rounds)
}

##---------------- Plot Distribution Rumor Extinction Times --------------------------------------------------

group.index <- rep(1:3, c(length(sm_net), length(pa_net), length(er_net)))

den <- sm.density.compare(c(sm_net, pa_net, er_net), group = group.index, model = "equal", xlim=c(0,20), main = "Distribution of rumor extinction times", xlab = "Generations before everyone knows the rumor")

legend(0.5, 1, c("small-world", "preferential-attachment", "Erdös-Rényi"), cex= 0.95, pch = 1, col = c("red","green","blue"), bty = "n")


