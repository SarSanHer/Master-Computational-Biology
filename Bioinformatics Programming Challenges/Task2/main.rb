# Assignment 2
# Sara Sánchez-Heredero Martínez
# Date 06/11/2019



puts ">>> PROGRAM RUNNING"
puts " "
#----------------------- LOAD REQUIREMENTS ----------------------------
require 'rest-client'
require 'json' 
require './web_access'
require './network_generator'
require './annotation_class'
require './network_members'



#------------------- LOAD INFO FROM GENE FILE --------------------

#Now I open the gene file and create some arrays that will help create the Class objects
gene_file = File.new("./ArabidopsisSubNetwork_GeneList.txt","r")

genes_list=Array.new 
gene_file.each do |agi| # iterate over the elements of gene_file
  genes_list.push(agi.strip.upcase!) #add AGI codes to a list
end

#------------------- CREATE NETWORK with class Network --------------------
object_networks = Network_generator.new(:input_genes => genes_list)
my_networks = object_networks.get_network


##------------------- CREATE NETWORKS' MEMBERS OBJECT  & ANNOTATE --------------------
interaction_network=Network_members.new(:my_networks => my_networks, :all_genes => genes_list)


#------------------- PRINT REPORT--------------------
for_report=interaction_network.net_members
i=0

report_file = File.open('./report.txt', "a+")
report_file.puts "\n\nSARA SANCHEZ-HEREDERO MARTÍNEZ \n\n\nASSIGNMENT 2 OUTPUT\n\nNetworks depth: 2"
report_file.puts "\n\nInteractions filters: Species (only Arabidopsis thaliana) and Intact MI-score (above 0.485)"
report_file.puts "\n\nThere is a total of #{my_networks.length} networks \n\n\t\t\t\t      *** *** ***\n\n\n\n"

for_report.keys.each do |key|
  i+=1
  report_file.puts "\nNetwork #{i} has the following genes:\n\n"
  for_report[key].each do |gene|
    report_file.puts "\t\t 1) Gene ID: #{$annotated_members_array[0].get_info(gene)[0]}"
    report_file.puts  "\t\t 2) Networks IDs: #{$annotated_members_array[0].get_info(gene)[1]}"
    report_file.puts  "\t\t 3) Protein IDs: #{$annotated_members_array[0].get_info(gene)[2]}"
    report_file.puts  "\t\t 4) KEGG ID and pathways: #{$annotated_members_array[0].get_info(gene)[3]}"
    report_file.puts "\t\t 5) GO ID and pathways: #{$annotated_members_array[0].get_info(gene)[4]}"
    report_file.puts "\t\t 6) Interactions with genes from the co-expressed file: #{($annotated_members_array[0].get_info(gene)[5])&genes_list}"
    report_file.puts "\n\n\n\n"
      end
  report_file.puts "\n\n\n\n\t\t\t\t      *** *** ***\n\n\n\n"
end                                                                                                                                
  
      