## SARA SANCHEZ HEREDERO MARTINEZ
## ASSIGNMENT 4: find orthologs
## 11 Nov 2019

puts '>>> PROGRAM RUNNING...'

#----------------------- LOAD REQUIREMENTS ----------------------------
require 'bio'
require 'stringio'


#------------------------ INPUT CONTROL --------------------

## raise error if input files are not the rigth ones
unless ( ARGV[0].to_s.include?('.tar.gz') || ARGV[0].to_s.include?('.fa') ) && ( ARGV[1].to_s.include?('.tar.gz') || ARGV[1].to_s.include?('.fa') )
  raise "\n Error: Invalid file format\n\tInput files must be fasta file '.fa' or compressed fasta file '.tar.gz' "
end

## Assign name to the input files
organism1 = ARGV[0] ############# PROGRAM WILL RUN FASTER IF BIGGER FILE IS ARG[0]
organism2 = ARGV[1] 


## Decompress files if they are compressed
if organism1.to_s.include?('.tar.gz') # if file is compressed:
  system("tar xvzf #{organism1}") #decompress file
  organism1 = organism1.chomp('.tar.gz') + '.fa' # remove .tar.gz extension and substitute by .fa
end

if organism2.to_s.include?('.tar.gz') # if file is compressed:
  system("tar xvzf #{organism2}") #decompress file
  organism2 = organism2.chomp('.tar.gz') + '.fa' # remove .tar.gz extension and substitute by .fa
end

#------------------------ CREATE DBs --------------------

def seqtype(file) # function to determine if the file contains NA or AA sequences
  f=Bio::FlatFile.auto(file) # first I create a flatfile object with the input file
  s=Bio::Sequence.new(f.next_entry.seq) # I get the first sequence in the file
  if s.guess == Bio::Sequence::NA # if that sequence is type NA
    return 'nucl' 
  else # if it's not NA == if it is AA
    return 'prot'
  end
end
  


system('mkdir Databases') # create a directory to store the databases
system("cp #{organism1} Databases/")
system("cp #{organism2} Databases/")
system("makeblastdb -in #{organism1} -dbtype #{seqtype(organism1)} -out ./Databases/#{organism1}") # create intex for first file
system("makeblastdb -in #{organism2} -dbtype #{seqtype(organism2)} -out ./Databases/#{organism2}") # create incex for second file




#------------------------ CREATE FACTORIES --------------------
## There are 4 cases:
  # A) Two genomes -> blastn
  # B) Two proteomes -> blastp
  # C) Genome vs proteome -> blastx
  # C) Proteome vs genome -> tblastn


type1 = seqtype(organism1)
type2 = seqtype(organism2)

if type1 == 'nucl' && type2 == 'nucl'
  f_org1 =  Bio::Blast.local('blastn', "./Databases/#{organism1}")
  f_org2 =  Bio::Blast.local('blastn', "./Databases/#{organism2}")
  
elsif type1 == 'prot' && type2 == 'prot'
  f_org1 =  Bio::Blast.local('blastp', "./Databases/#{organism1}")
  f_org2 =  Bio::Blast.local('blastp', "./Databases/#{organism2}")
  
elsif type1 == 'nucl' && type2 == 'prot'
  f_org1 =  Bio::Blast.local('tblastn', "./Databases/#{organism1}")
  f_org2 =  Bio::Blast.local('blastx', "./Databases/#{organism2}")
  
elsif type1 == 'prot' && type2 == 'nucl'
  f_org1 =  Bio::Blast.local('blastx', "./Databases/#{organism1}")
  f_org2 =  Bio::Blast.local('tblastn', "./Databases/#{organism2}")
  
end


#------------------------ HOMOLOGUES SEARCH --------------------
## I will use one filter: (reference in report)
  # e-value thereshold 10(-6)
  eval = 10**-6
  # Other filters like query coverage (>50%) are suggested in some papers, but since the genome has introns and the proteome doesnt, this filter might not be a good idea for this experiment
  

## I will create 2 hashes to store ID-seq for each organism:
org1=Hash.new
org2=Hash.new


Bio::FlatFile.auto(organism1).each_entry do |entry| # iterate over the sequences in Arabidopsis file
  org1[entry.entry_id]=entry.seq             # gen/prot_ID => seq 
end

Bio::FlatFile.auto(organism2).each_entry do |entry| # iterate over the sequences in Arabidopsis file
  org2[entry.entry_id]=entry.seq             # gen/prot_ID => seq
end


orthologues = [] # empty array to store posible orthologues from blast round


org2.each do |entry|
  r_org2 = f_org1.query(">myseq\n#{entry[1]}")
  
  next unless r_org2.hits.length != 0 # if there are no hits it goes to the next sequence
  next unless r_org2.hits[0].evalue <= eval # continue only if e-value is under threshold
  #puts "evalue: #{r_org2.hits[0].evalue}"
  
  ## if best hit passes all filters, we find best reciprocal hits: 
  
  hit_id = r_org2.hits[0].definition.split('|')[0].strip # get the best hit's ID to access its sequence
  #puts "best hit of #{entry[0]} is #{hit_id} of seq:\n#{org1[hit_id.to_s]}\n\n"
  
  r_org1 = f_org2.query(">myseq\n#{org1[hit_id]}") # blast top hit sequence with Arabidopsis genome

  next unless r_org1.hits.length != 0 # if there are no hits it goes to the next sequence
  next unless r_org1.hits[0].evalue <= eval # continue only if e-value is under threshold
  
  if r_org1.hits[0].definition.split('|')[0].to_s.strip == entry[0]  # if best hit ID is Arabidopsis seq ID that had this as its top hit:
    orthologues.push([entry[0],hit_id]) # add org1 ID to list of orthologues
    puts '...'
  end
end




#------------------- WRITE REPORT--------------------
report_file = File.open('./orthologuesReport.txt', "a+")
report_file.puts "\n\nSARA SANCHEZ-HEREDERO MARTÍNEZ \n\n\nASSIGNMENT 4: orthologues search with BLAST BRH"
report_file.puts "\n\n\t\t\t\t      *** *** ***\n\n"
report_file.puts "The orthologues were found using the Best Reciprocal Hit technique. In orther to filter out the non-orthologues homologues, there is a filter: \n\t Only hits with an e-value under 10(-6) are selected\n * Other filters like query coverage (>50%) are suggested in some papers, but since the genome has introns and the proteome doesnt, this filter might not be a good idea for this experiment"
report_file.puts "\nReferences:\n\t - Gabriel Moreno-Hagelsieb, Kristen Latimer, Choosing BLAST options for better detection of orthologs as reciprocal best hits, Bioinformatics, Volume 24, Issue 3, 1 February 2008, Pages 319–324, https://doi.org/10.1093/bioinformatics/btm585\n\t- Ward, N., & Moreno-Hagelsieb, G. (2014). Quickly finding orthologs as reciprocal best hits with BLAT, LAST, and UBLAST: how much do we miss?. PloS one, 9(7), e101850. doi:10.1371/journal.pone.0101850"
report_file.puts "\n\n\t\t\t\t      *** *** ***\n\n"
report_file.puts "This methodology finds sequences that are likely to be orthologues, but to make sure that those are true orthologues, some complementary analyses are necesary. Some posible ways to continue the orthologue search would be:"
report_file.puts "\n\t1) Test for paralogues detection, for example using RDP\n\t2) Test for xenologous detection, using for example T-Rex\n\t3) Phylogenetic tree analyses of sequences in both species"
report_file.puts "\n\n\t\t\t\t      *** *** ***\n\n"
report_file.puts "The #{orthologues.length} sequences identified as posible orthologues using only BLAST are:"
report_file.puts "\n#{organism1.to_s.chomp('.fa')} -> #{organism2.to_s.chomp('.fa')} "
orthologues.each do |pair|
  report_file.puts "#{pair[0]} -> #{pair[1]}"
end