## SARA SANCHEZ HEREDERO MARTINEZ
## ASSIGNMENT 3: GFF feature files and visualization
## 20 Nov 2019


#----------------------- LOAD REQUIREMENTS ----------------------------
require 'bio'
require 'net/http'   # this is how you access the Web
require './exons'
require './seq_finder'

#----------------------- CREATE CLASS ----------------------------
class GFF_creator 
  
  #object variables:
  attr_accessor :input
  attr_accessor :entry
  
  # class variables:
  @@all_objects = Array.new  # array with all the objects from this class  
  
  def initialize (params = {})
    @input = params.fetch(:input, String.new) # my biosequence (created from the entry sequence)
    @entry = params.fetch(:entry, String.new) # I also include entry because it has other methods such as entry.accession to get info about species and scaffold position
    
  end
  
  def write_file_4a(name)
    report = File.open("#{name}.gff3", "a+") # open/ create a gff file with whatever name we want to give it when we call the method
    if not report.readlines.grep(/gff/).size > 0  # if the file doesn't already have a string "##gff-version 3"
      report.puts "##gff-version 3" # write it
    end
    
    @input.features.each do |feature| # iterate over the features of biosequence
      featuretype = feature.feature 
      next unless featuretype == "myrepeat" # if the feature is one of the features I created
      chr=@entry.accession.split(':')[2]  # from st like chromosome:TAIR10:4:11306945:11308925:1, get the index position 2 => 4 in this example
      start=feature.position[0]
      ending=feature.position[1]
      report.puts "chr#{chr}\t·\texon_region\t#{start}\t#{ending}\t·\t#{feature.assoc['strand']}\t·\tID=#{feature.assoc['gene_ID']};Species=#{@entry.species.delete(' ')};Repeat=#{feature.assoc['repeat_motif']}"  
    end
  end
  
  def write_file_5(name)
    report = File.open("#{name}.gff3", "a+") # open/ create a gff file with whatever name we want to give it when we call the method
    if not report.readlines.grep(/gff-version 3/).size > 0 # if the file doesn't already have a string "##gff-version 3"
      report.puts "##gff-version 3" # write it
    end
    
    @input.features.each do |feature| # iterate over the features of biosequence
      featuretype = feature.feature
      next unless featuretype == "myrepeat" # if the feature is one of the features I created
      chr=@entry.accession.split(':')[2] # from st like chromosome:TAIR10:4:11306945:11308925:1, get the index position 2 => 4 in this example
      
      gene_start=@entry.accession.to_s.split(':')[3].to_i # as for the chr above, here its getting the position where the gene starts according to the ENSEMBL whole-chromosome start/end coordinates
      start=feature.position[0] + gene_start
      ending=feature.position[1] + gene_start
      
      report.puts "chr#{chr}\t·\texon_region\t#{start}\t#{ending}\t·\t#{feature.assoc['strand']}\t·\tID=#{feature.assoc['gene_ID']};Species=#{@entry.species.delete(' ')};Repeat=#{feature.assoc['repeat_motif']}"  
    end
  end
  
end
    
                     