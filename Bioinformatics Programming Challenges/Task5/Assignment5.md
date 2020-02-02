#### SARA SANCHEZ HEREDERO MARTINEZ
#### ASSIGNMENT 5: SPARQL Queries
#### 18 Dec 2019

# SPARQL

## UniProt SPARQL Endpoint: http://sparql.uniprot.org/sparql/

1. How many protein records are in UniProt? 
```
PREFIX up:<http://purl.uniprot.org/core/> 
SELECT (COUNT(DISTINCT  ?protein) AS ?count)
WHERE{ 
        ?protein a up:Protein .
}
```
**RESULT**: 281303435 records 
<br/><br/><br/>


2. How many Arabidopsis thaliana protein records are in UniProt? 
```
PREFIX up:<http://purl.uniprot.org/core/> 
PREFIX taxon:<http://purl.uniprot.org/taxonomy/> 
SELECT (COUNT(DISTINCT ?protein) AS ?count)
WHERE{ 
        ?protein a up:Protein .
        ?protein up:organism taxon:3702 .  #select only A. thaliana proteins
}

```
**RESULT**: 89182 records 
<br/><br/><br/>


3. What is the description of the enzyme activity of UniProt Protein Q9SZZ8? 
```
PREFIX up:<http://purl.uniprot.org/core/> 
PREFIX uniprot:<http://purl.uniprot.org/uniprot/> 
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#> 
PREFIX label:<http://www.w3.org/2004/02/skos/core#>

SELECT ?description
WHERE {
  uniprot:Q9SZZ8 a up:Protein ;
                   up:enzyme ?enzyme .  
  ?enzyme up:activity ?activity .
  ?activity rdfs:label ?description
}
```
**RESULT**: Beta-carotene + 4 reduced ferredoxin [iron-sulfur] cluster + 2 H(+) + 2 O(2) = zeaxanthin + 4 oxidized ferredoxin [iron-sulfur] cluster + 2 H(2)O
<br/><br/><br/>



4. Retrieve the proteins ids, and date of submission, for proteins that have been added to UniProt this year (HINT Google for “SPARQL FILTER by date”)
```
PREFIX up:<http://purl.uniprot.org/core/> 
PREFIX uniprot:<http://purl.uniprot.org/uniprot/> 

SELECT ?id ?date
WHERE{
  ?protein a up:Protein . 
  ?protein up:mnemonic ?id .
  ?protein up:created ?date .
  FILTER (contains(STR(?date), "2019"))
}
```
<br/><br/><br/>


5. How many species are in the UniProt taxonomy? 
```
PREFIX taxon:<http://purl.uniprot.org/taxonomy/> 
PREFIX up:<http://purl.uniprot.org/core/> 

SELECT (COUNT(DISTINCT ?taxon) AS ?count)
WHERE{
  ?taxon a up:Taxon .
  ?taxon up:rank up:Species 
}
```
**RESULT**: 1766921 species
<br/><br/><br/>


6. How many species have at least one protein record? 
```
PREFIX taxon:<http://purl.uniprot.org/taxonomy/> 
PREFIX up:<http://purl.uniprot.org/core/> 

SELECT (COUNT(DISTINCT ?taxon) AS ?count)
WHERE{
  ?taxon a up:Taxon .
  ?taxon up:rank up:Species .
  ?protein a up:Protein .  
}
```
**RESULT**: 
<br/><br/><br/>

## From the Atlas gene expression database SPARQL Endpoint: http://www.ebi.ac.uk/rdf/services/atlas/sparql


8. Get the experimental description for all experiments where the Arabidopsis Apetala3 gene is DOWN regulated
```
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX atlasterms: <http://rdf.ebi.ac.uk/terms/expressionatlas/>

SELECT distinct ?description
FROM <http://rdf.ebi.ac.uk/dataset/expressionatlas>
WHERE {            
  ?gene rdfs:label 'AP3' .
  ?s atlasterms:refersTo ?gene .
  ?s a atlasterms:DecreasedDifferentialExpressionRatio .
  ?s atlasterms:isOutputOf ?a .
  ?a rdfs:label ?description .
}
```
<br/><br/><br/>

## From the REACTOME database SPARQL endpoint: http://www.ebi.ac.uk/rdf/services/reactome/sparql

9. How many REACTOME pathways are assigned to Arabidopsis (taxon 3702)? (note that REACTOME uses different URLs to define their taxonomy compared to UniProt, so you will first have to learn how to structure those URLs….). 
```
PREFIX biopax3: <http://www.biopax.org/release/biopax-level3.owl#>

SELECT (COUNT(DISTINCT ?pathway) AS ?count)
WHERE {
  ?pathway a biopax3:Pathway .
  ?pathway biopax3:organism ?a .
  FILTER contains(STR(?a),'3702')
 }  
```
**RESULT**: 809 pathways
<br/><br/><br/>

10. Get all PubMed references for the pathway with the name “Degradation of the extracellular matrix”
```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX biopax3: <http://www.biopax.org/release/biopax-level3.owl#>

SELECT (COUNT(DISTINCT ?ref) AS ?count)
WHERE {
  ?pathway rdf:type biopax3:Pathway .
  ?pathway biopax3:displayName ?pathwayname .
  FILTER CONTAINS(STR(?pathwayname),'Degradation of the extracellular matrix') .
  ?pathway biopax3:xref ?ref .
  ?ref a biopax3:PublicationXref .
  FILTER CONTAINS(STR(?ref),'pubmed') .
}
```
**RESULT**: 7 references
<br/><br/><br/>


## BONUS QUERIES


UniProt BONUS 2 points : find the AGI codes and gene names for all Arabidopsis thaliana proteins that have a protein function annotation description that mentions “pattern formation”
```
PREFIX skos:<http://www.w3.org/2004/02/skos/core#> 
PREFIX up:<http://purl.uniprot.org/core/> 
PREFIX taxon:<http://purl.uniprot.org/taxonomy/> 
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#> 

SELECT ?AGI ?name
WHERE{ 
  ?protein a up:Protein .
  ?protein up:organism taxon:3702 . 
  ?protein up:annotation ?annotation .
  ?annotation a up:Function_Annotation ;
           rdfs:comment ?c .
  FILTER (contains(STR(?c), "pattern formation")).

 ?protein up:encodedBy ?gene .
  ?gene up:locusName ?AGI ; 
     	  skos:prefLabel ?name . 

}
```
**RESULT**: There are 15 results ( SELECT (count(distinct ?AGI) as ?count) )
<br/><br/><br/>


REACTOME BONUS 2 points : write a query that proves that all Arabidopsis pathway annotations in Reactome are “inferred from electronic annotation” (evidence code) (...and therefore are probably garbage!!!)
```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX biopax3: <http://www.biopax.org/release/biopax-level3.owl#>

SELECT (COUNT(DISTINCT ?evidence) as ?e2)
WHERE {
  ?pathway a biopax3:Pathway .
  ?pathway biopax3:organism ?a .
  FILTER contains(STR(?a),'3702') . 
  ?pathway biopax3:evidence ?evidence . 
  ?evidence biopax3:evidenceCode ?code .
  FILTER CONTAINS(STR(?code),'EvidenceCodeVocabulary1').   
}
```
**RESULT**: 809 have IEA, and in question 9 we saw that the total number of Arabidopsis pathways was 809; therefore, all Arabidopsis pathway annotations in Reactome are “inferred from electronic annotation”
