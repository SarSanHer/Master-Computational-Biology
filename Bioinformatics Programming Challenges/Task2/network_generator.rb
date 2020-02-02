# Assignment 2
# Sara Sánchez-Heredero Martínez
# Date 06/11/2019




require 'rest-client'
require './web_access'

#----------------------- CREATE GENE CLASS ----------------------------
class Network_generator
  attr_accessor :input_genes # AGI gene ID code
  @@all_objects = Array.new
  
  
  def initialize (params = {}) 
    @input_genes = params.fetch(:input_genes, Array.new)
    @@all_objects << self
  end
  
  
  def interactions(mygenes_array)
    output_array=Array.new
    mygenes_array.each do |gene|
      interactions = get_interactions(gene,mygenes_array)
        if interactions != [] # if there are interacions
          output_array.push([gene,interactions].flatten) # add that interaction as [my_gene,interaction1,interaction2, ...] 
        end
    end
    return output_array
  end
  
  
  def get_interactions_array(all_genes_array, my_genes)
    new_level=Array.new
    all_genes_array.each do |int| #takes each [my_gene,interaction1,interaction2, ...] 
      new_level.push(int[1..-1]) # include only [interaction1,interaction2, ...], exclude my_gene
    end
    new_level.flatten!.uniq! # un-nest array and remove duplications
    new_level = new_level - (new_level & my_genes) #do not include genes from the previous interaction level
    return new_level
  end

  
  def get_network
    int_L1=interactions(@input_genes) #interactions of co-expressed genes -> [my_geneA, interaction1, interaction2, ...]
    genes_L2 = get_interactions_array(int_L1,@input_genes) #[interaction1, interaction2, ...] with no duplicates
    pre_int_L2 = interactions(genes_L2) # interactions of first level interactions -> [interaction1, intA, my_geneA, interaction 2, ...]
    members = [@input_genes,genes_L2].flatten!
    
    ## The code below is to delete all interaction that don't connect with other interactions or co-expressed genes so to only annotate the relevant genes
    int_L2=[]
    pre_int_L2.each do |int|
      real_int=[]
      int[1..-1].each do |gen_inter|
        if members.include? gen_inter
          real_int.push(gen_inter)
        end
      end
      int_L2.push([int[0],real_int].flatten)
    end
  
    all=[int_L1,int_L2].flatten!(1) # merge interaction arrays
    
    ## If we wanted to add more levels we could just do:
      ###  genes_L3 = get_interactions_array(int_L2) 
      ###  int_L3=interactions(genes_L3)
      ###  all=[int_L1,int_L2. int_L3].flatten!(1)
      ###  (and so on for more levels of depth)

     
    ## create network's arrays
    networks=Array.new
    all.each do |item| # get one array of interactions, for example [gene1 , gene2, gene3]
      net=Array.new
      
      item.each do |elem| # get one of those genes, for example gene1
        (0..all.length-1).each do |i| #iterate over the arrays again (like all[0] = [gene1 , gene2, gene3])
          if all[i].any? elem #if the array contains that gene (for example gene1 is in all[0])
            net.push(all[i].flatten) # include that array of interactions to my new array 
          end
        end
      end
      
      net.flatten! # unnest array
      net.uniq! # delete repetitions
      net.sort! # sort array
      
      if net.length > 2 && (input_genes&net).length > 1 # if the network has more than 2 members and contains two genes from the original list of co-expressed genes
        networks.push(net)
        #puts " my network is \n #{net} \t"
      end
    end
     
    networks.uniq! #remove duplicated networks
    return networks
  end
end


