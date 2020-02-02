##------------------- Mark's fuction to prevent web accessing errors --------------------
#puts "now I load the fetch function"
def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
  response = RestClient::Request.execute({
    method: :get,
    url: url.to_s,
    user: user,
    password: pass,
    headers: headers})
  return response
  
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.response
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue RestClient::Exception => e
    $stderr.puts e.response
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue Exception => e
    $stderr.puts e
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end


#####
#####      WEB ACCESSING FUNCTIONS 
#####

#------------------- get protein ID --------------------
def get_protID(my_gene)
  address="http://togows.org/entry/ebi-uniprot/#{my_gene}/accessions.json"
  response = fetch(address)  
  if response  # if there is a response to calling that URI
    body = response.body  # get the "body" of the response
    data = JSON.parse(response.body)
    return data[0]
  end
end

#------------------- get KEGG annotations --------------------
def get_KEGG(my_gene)
  address = "http://togows.org/entry/kegg-genes/ath:#{my_gene}/pathways.json"
  my_KEGG_list=Array.new
  response = fetch(address)  
  if response  # if there is a response to calling that URI
    body = response.body  # get the "body" of the response
    data = JSON.parse(response.body)
    my_KEGG_list.push(data[0].to_a)
    unless data[0].nil?
      if data[0].length != 0
        my_KEGG_list = data[0].to_a
      end
    end
    return my_KEGG_list
  else 
    return Array.new
  end
end


#------------------- get GO annotations --------------------
def get_GO(my_gene)
  address = "http://togows.dbcls.jp/entry/uniprot/#{my_gene}/dr.json"
  my_GO_list=Array.new
  response = fetch(address)  
  if response  # if there is a response to calling that URI
    body = response.body  # get the "body" of the response
    data = JSON.parse(response.body)
    if data[0]["GO"]
      data[0]["GO"].each do |go| 
      if go[1] =~ /P:/#if its a biological process it will have the key 'P'
        my_GO_list.push(go[0..1])
      end
    end
      return my_GO_list
    end
  else 
    return Array.new
  end
end


#------------------- get gene interactions --------------------

def get_interactions(my_gene,all_genes)
  address="http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/query/#{my_gene}?format=tab25"
  response = fetch(address)
  interactions_array=Array.new
  #puts "get_interactions function has been called"
  
  if response  # if there is a response to calling that URI
    body = response.body  # get the "body" of the response
    data = body.split("\n").to_a #first I split the rows into different arrays


    (0..data.length-1).each do |i|
      
      data[i] = data[i].split("\t") #then I create an array's element per each tab separated value 
      
      
      unless data[i][9].include?("3702") && data[i][10].include?("3702") #if both proteins are NOT from Arabidopsis thaliana (taxa code 3702)
        next # discard this protein interaction, jumps to next posible interaction
      end
        
        
      intact_miscore = data[i][14].split(":")[1]
      if intact_miscore.to_f < 0.485  # if interaction's score is under cutoff (according to doi:10.1093/database/bau131)
        next # discard this protein interaction, jumps to next posible interaction
      end
          
    
      data[i] = data[i][4..5] #these columns of the tab25 format cointain the gene locus name      
      (0..data[i].length-1).each do |k|
        interactions_array.push(data[i][k].scan(/A[Tt]\d[Gg]\d\d\d\d\d/)) #find the agi code in the text, retrieve it and add it to the array
        end
      end    


    
    interactions_array = interactions_array.flatten.uniq  #unnest the arrray, delete repetitions and interactions with itself
    interactions_array.map!(&:upcase) #make all the codes uppercase so that I can compare them latter
    interactions_array = interactions_array- [my_gene.upcase] #dont include my own gene as an interaction
    #puts "interactions_array created"
    
    return interactions_array
    
  end
end
