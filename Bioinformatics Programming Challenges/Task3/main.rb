## SARA SANCHEZ HEREDERO MARTINEZ
## ASSIGNMENT 3: GFF feature files and visualization
## 20 Nov 2019

puts '>>> PROGRAM RUNNING...'

#----------------------- LOAD REQUIREMENTS ----------------------------
require 'bio'
require 'net/http'   # this is how you access the Web
require './GFF_creator'



#------------------- LOAD INFO FROM GENE FILE --------------------

#Now I open the gene file and create some arrays that will help create the Class objects
gene_file = File.new("./ArabidopsisSubNetwork_GeneList.txt","r")
genes_list=Array.new 
gene_file.each do |agi| # iterate over the elements of gene_file
  genes_list.push(agi.strip.upcase!) #add AGI codes to a list
end

$good_genes=Array.new

#------------------- CREATE REPETITION OBJECT --------------------

$repeat = Bio::Sequence::NA.new("CTTCTT")   #create a biosequence object for the repetition we want to find
re  = Regexp.new($repeat.to_re) # create a regular expression for the seq
c_re = Regexp.new($repeat.reverse_complement.to_re) # create a regular expression for the complementary and reverse of the seq

## Function to find the repetition object
def get_coords(target,seq,origin)
  origin=origin.to_i
  seq = seq.to_s # transform sequence to string so that it doesnt give an error when working with flatfile_objetc.seq
  coords=Array.new
  pos = seq.enum_for(:scan, target).map { Regexp.last_match.begin(0) } # get the position where the match starts
  pos.each do |p| # for each time the secuence was found
    begining = origin + p # begining is where the seq was found plus the origin of the exon
    ending = begining - 1 + $repeat.length # ends at begining + as many positions as our target seq has (-1 so it ends at the position of the last item)
    coords.push([begining,ending]) # add the coordenates to the array
  end
  return coords
end


#------------------- ITERATE OVER GENES --------------------
genes_list.each do |xxx|
  #xxx = genes_list[1]
  
  ## CREATE FILE 
  address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{xxx}")  # create a "URI" with the genes from the list
  response = Net::HTTP.get_response(address)  # use the Net::HTTP object "get_response" method                                            
  record= response.body
  # create a local file with this data so that latter I can create a flatFile object
  File.open("temp.embl", 'w') do |myfile|  # w makes it writable
    myfile.puts record
  end
  
  
  ## EXPLORE FILE
  
  datafile = Bio::FlatFile.auto("temp.embl") # create Flat File object
  
  
  datafile.each_entry do |entry| # iterate over each record of the file
    next unless entry.features.length != 0 #do not iterate over empty files

    my_bioseq = entry.to_biosequence   #create a biosequence object for the sequence in the entry
    ft0 = my_bioseq.features.length.to_i    # register the number of features it has at the begining
    my_coords=Array.new   # for this entry, all the coordenates where the repetition is found will be stored in this array
    
    
    
    entry.features.each do |feature| # iterate over features of the record
      next unless feature.assoc['note'].to_s.include?('exon')  # go to next feature unless note contains the word 'exon'
      next if feature.position.to_s.include?(':')  # go to next feature if the query references another gene
      
      
      ## Define some exon characteristics
      exon_position = feature.position.to_s.scan(/\d*\.\.\d*/)[0].split('..')
      my_exon = my_bioseq[exon_position[0].to_i..exon_position[1].to_i]
      
      ## Get the position where the repetition is found in relation to the origen of the gen & store in a variable if the strand is + or -
      if feature.position.to_s.include?('complement')
        exon_strand = '-'
        exon_repeats=get_coords(c_re,my_exon,exon_position[0])
      else
        exon_strand = '+'
        o = exon_position[0].to_i + 1  # it's necesary to sum 1 position because there is a displacement of the coordinates in this strand
        exon_repeats=get_coords(re,my_exon, o)
      end
          
      
      next unless exon_repeats != [] # go to next exon if the repetition is not in the this exon
      
      
      ## Create repetition features
      exon_repeats.each do |rep| # create features
        next if my_coords.include?(rep) # don't create a feature if it has already been created
        my_coords.push(rep) # if it was not included, add to array. This is a control in case my repetition is in the same position in the gene sequence but in different exones, and therefore appears multiple times
        f = Bio::Feature.new('myrepeat',rep)
        f.append(Bio::Feature::Qualifier.new('repeat_motif', 'CTTCTT'))
        f.append(Bio::Feature::Qualifier.new('gene_ID', xxx))
        f.append(Bio::Feature::Qualifier.new('strand', exon_strand))
        my_bioseq.features << f
      end
      
      
    end #close the feature

    next unless (my_bioseq.features.length.to_i - ft0) != 0 # go to next entry if the number of features has not increased == no repetition feature was added
    $good_genes.push(xxx) # store here the genes that have created features == have the repetition sequence
    
    ## Write GFF file by:
    # 1. Create a gff object (I decided to create an object here so it would be separated from the main script since its a file with a basically duplicated method)
    gff=GFF_creator.new(:input => my_bioseq, :entry => entry) 
    
    # 2. Execute the method to write gff files
    gff.write_file_4a('ex_4a') # call the method that creates the GFF using gene coordenates
    gff.write_file_5('ex_5') # call the method that creates the GFF using ENSEMBL whole-chromosome start/end coordinates
  
  end #close the entry
end

#------------------- WRITE REPORT--------------------
report_file = File.open('./report1.txt', "a+")
report_file.puts "\n\nSARA SANCHEZ-HEREDERO MARTÍNEZ \n\n\nASSIGNMENT 3: output report"
report_file.puts "\n\nThe genes that do not have the repetition are #{genes_list - $good_genes} \n\n\t\t\t\t      *** *** ***\n\n\n\n"


