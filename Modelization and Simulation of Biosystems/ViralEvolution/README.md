# Viral evolution

The goal of this code is to study the dynamics of infection within an individual in the following scenario:  
Consider a person infected by a virus. Use the basic model of virus dynamics to simulate the initial stages of the infection with parameters l=105, d=0.1, a=0.5, b=2x10-7, k=100, u=5.
When the viral load reaches 106, this person starts to be treated with an antiviral drug that inhibits viral replication in a 99% (meaning k → k’=1 now). The virus, which is quite homogeneous phenotypically during this period, can generate a mutant variant resistant to the antiviral drug (this -9 means it replicates at the original value of k) with probability 10 . (This means that the rate of mutant production upon virus replication is 10-9 k’).  

Implement and simulate the dynamics of the process. Discuss how would the generation of mutants occur in a finite population (where stochastic effects are important and mean-field descriptions may fail). How long could it take for a mutant to appear?
Discuss possible situations where the infection could be eradicated (joint action of the immune system, of an additional drug, or others).
