
gene_file_input = ARGV[0]
stock_file_input = ARGV[1]
cross_file_input = ARGV[2]
stock_file_output = ARGV[3]
#puts "the gene file is #{gene_file_input},the stock file is #{stock_file_input}, the cross file is #{cross_file_input}, the stock output file is #{stock_file_output}"

require "csv" #tool to load the tsv files into matrices


class Gene #create the class  
  attr_accessor :gene_id #this makes the instance accessible as object.id
  attr_accessor :gene_name #this makes the instance accessible as object.name
  attr_accessor :gene_phenotype #this makes the instance accessible as object.phenotype
  attr_accessor :gene_links
 
  # introduce gene ID, name and description of the mutant phenotype
   def initialize (params = {})
     @gene_name = params.fetch(:gene_name,"unknown")
     @gene_phenotype = params.fetch(:gene_phenotype, "unknown")  
     @gene_links = params.fetch(:gene_links, [])      
     @gene_id = params.fetch(:gene_id,"AT0G00000") #gives default value

   end
  
  def load_from_file(file)
    gene_file = CSV.read(file, { :col_sep => "\t" }) 
    #create arrays for the database I'll upload
    gene_id, gene_name, gene_phenotype = [], [], []
    (1..(gene_file.count-1)).each do |i|
      gene_id.push(gene_file[i][0])
      gene_name.push(gene_file[i][1])
      gene_phenotype.push(gene_file[i][2]) 
      gene_links.push("no linked genes")
    end
    self.gene_id = gene_id
    self.gene_name =  gene_name
    self.gene_phenotype = gene_phenotype   
    self.gene_links = gene_links
    #puts "the new IDs array is #{self.gene_id}"
    
    #the following commands will check if the loaded gene IDs have the right format
    code=Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/) #regular expresion for gene identifier format
    (0..gene_id.count-1).each do |i|
      if code.match(gene_id[i])
        nil
        #puts "the gene IDs are correct: #{self.gene_id}"
      else
        #puts "there is an invalid gene ID format in #{item}, setting it to default"
        raise "\n Error: invalid gene ID format in the gene #{gene_id[i]} at position #{i} of your file \n Make sure that ALL gene IDs from your gene file have ATxGxxxxx format"
      end
    end

    
  end
  
  
  ### METHOD to get gene name
  def get_name(somegeneID)
    if self.gene_id.include? somegeneID
      return self.gene_name[self.gene_id.index(somegeneID)]
    end
  end 

end


#create Gene DB object
gene_db = Gene.new
gene_db.load_from_file(gene_file_input)
#puts gene_db.gene_id


class Cross #create the class  
  attr_accessor :parent1 #this makes the instance accessible as object.id
  attr_accessor :parent2
  attr_accessor :F2_wild 
  attr_accessor :F2_p1
  attr_accessor :F2_p2
  attr_accessor :F2_p1p2
   
  # introduce gene parents, f2 wild/parent1/2/1_2
  def initialize (params = {})
    @parent1 = params.fetch(:parent1, "XXXX") #gives default value
    @parent2 = params.fetch(:parent2, "XXXX") 
    @F2_wild = params.fetch(:F2_wild, "XXXX") 
    @F2_p1 = params.fetch(:F2_p1, "XXXX")
    @F2_p2 = params.fetch(:F2_p2, "XXXX")
    @F2_p1p2 = params.fetch(:F2_p1p2, "XXXX")  
  end  
  
  def load_from_file(file)
    cross_file = CSV.read(file, { :col_sep => "\t" }) 
    #create arrays for the database I'll upload
    parent1, parent2, wild, p1, p2, p1p2 = [], [], [], [], [], []
    (1..(cross_file.count-1)).each do |i|
      parent1.push(cross_file[i][0])
      parent2.push(cross_file[i][1])
      wild.push(cross_file[i][2]) 
      p1.push(cross_file[i][3])
      p2.push(cross_file[i][4])
      p1p2.push(cross_file[i][5])
    end
    self.parent1 = parent1
    self.parent2 =  parent2
    self.F2_wild = wild     
    self.F2_p1 = p1
    self.F2_p2 = p2
    self.F2_p1p2 = p1p2
  end
  
end

#create cross DB object
cross_db = Cross.new #first the object will have the default values
cross_db.load_from_file(cross_file_input) #now it loads the information of the class from the file
#puts cross_db.F2_p1p2



class Seed_stock #create the class
  attr_accessor :seed_stock #this makes the instance accessible as object.id
  attr_accessor :mutant_gene_id
  attr_accessor :last_planted 
  attr_accessor :storage
  attr_accessor :grams_remaining
  
  # introduce gene parents, f2 wild/parent1/2/1_2
  def initialize (params = {})
    @seed_stock = params.fetch(:seed_stock, []) #gives default value
    @mutant_gene_id = params.fetch(:mutant_gene_id, []) 
    @last_planted = params.fetch(:last_planted, []) 
    @storage = params.fetch(:storage, [])
    @grams_remaining = params.fetch(:grams_remaining, [])     
  end
  
  
  def load_from_file(file)
    stock_file = CSV.read(file, { :col_sep => "\t" }) 
    
    #create arrays for the database I'll upload
    seed_stock, mutant_gene_id, last_planted, storage, grams_remaining = [], [], [], [], []
    (1..(stock_file.count-1)).each do |i|
      seed_stock.push(stock_file[i][0])
      mutant_gene_id.push(stock_file[i][1])
      last_planted.push(stock_file[i][2])
      storage.push(stock_file[i][3])
      grams_remaining.push(stock_file[i][4])
    end
      
      self.seed_stock = seed_stock
      self.mutant_gene_id =  mutant_gene_id
      self.last_planted = last_planted
      self.storage = storage
      self.grams_remaining = grams_remaining
      
  end
  
  
  def get_seed_stock(id)
    (0..(seed_stock.count-1)).each do |i|
      if id == seed_stock[i]
        return grams_remaining[i]
      end
    end
  end
  
  ### METHOD to link geneIDs
  def get_id(somegeneID)
    (0..(seed_stock.count-1)).each do |i|
      if mutant_gene_id[i] == somegeneID
        return seed_stock[i] 
      elsif seed_stock[i] == somegeneID
        return mutant_gene_id[i]
      end
    end 
  end

  
  def update_file(seeds_retrieved)
    (0..(grams_remaining.count-1)).each do |i|
      grams_remaining[i] = grams_remaining[i].to_i - seeds_retrieved.to_i
      if grams_remaining[i] <= 0
        grams_remaining[i] = 0
        puts "WARNING: we have run out of Seed Stock #{seed_stock[i]}" #and print a warning message
      end
    end
  end
  
  
  def write_database(new_file)
    CSV.open(new_file, "w") do |tsv|
      #puts "CSV has been opened"
      tsv << ["Seed_Stock", "Mutant_Gene_ID", "Last_Planted", "Storage", "Grams_Remaining"]
      (0..4).each do |i| 
        tsv << [seed_stock[i], mutant_gene_id[i], last_planted[i], storage[i], grams_remaining[i]]
      end
    end
  end
 
  
end

#create Seed stock DB object
stock_db = Seed_stock.new
stock_db.load_from_file(stock_file_input)
stock_db.update_file(7)
stock_db.write_database(stock_file_output)

gene_link=[]
chi=0
(0..(cross_db.parent1.count)-1).each do |i| #loop over the cross hybrids in order to perform the chi square test by pairs
  total = cross_db.F2_wild[i].to_i + cross_db.F2_p1[i].to_i + cross_db.F2_p2[i].to_i+ cross_db.F2_p1p2[i].to_i
  expected = [total*0.5625, total*0.1875, total*0.1875, total*0.0625] #creates an array for the expected values
  observed =[cross_db.F2_wild[i].to_i, cross_db.F2_p1[i].to_i, cross_db.F2_p2[i].to_i, cross_db.F2_p1p2[i].to_i]  #creates an array for the observed values
  chi=0

  (0..(observed.count)-1).each do |j| #loop to operate over the expected and observed values of each pair of parent genes
    a=(observed[j]-expected[j])**2
    chi += a/expected[j] #chi value calcularion
    if j == 3 
      if chi.to_i > 4.11 then  #chcking if the resulting chi value is significative or not 
        gene1=gene_db.get_name(stock_db.get_id(cross_db.parent1[i]))
        gene2=gene_db.get_name(stock_db.get_id(cross_db.parent2[i]))
        gene_link.push([gene1,gene2, chi])
        #update Gene object to reflect this correlation
        gene_db.gene_links[gene_db.gene_name.index(gene1)] = "#{gene1} is linked to #{gene2}"
        gene_db.gene_links[gene_db.gene_name.index(gene2)] = "#{gene2} is linked to #{gene1}"
        puts ""
        puts "Recording: #{gene1} is genetically linked to #{gene2} with chisquare score #{chi}"
      end
    end 
  end 
end 

puts ""
puts "Final report:"
gene_db.gene_links.each do |item|
  if item != "no linked genes"
    puts item
  end
end


