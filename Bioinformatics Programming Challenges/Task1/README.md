# Assigment #1 - Creating Objects 
_(Instructions writen by Mark Wilkinson, taken from Moodle platform)_

This assignment reflects one of the most common scenarios in bioinformatics: a series of files that are linked with each other based on (different) identifier numbers. It also asks you to start thinking about "databases", and the fact that databases are dynamic and must be updated (in this case, the amount of seed left in your genebank).

### Your task
1) "Simulate" planting 7 grams of seeds from each of the records in the seed stock genebank then you should update the genebank information to show the new quantity of seeds that remain after a planting. The new state of the genebank
should be printed to a new file, using exactly the same format as the original file seed_stock_data.tsv
-- if the amount of seed is reduced to zero or less than zero, then
a friendly warning message should appear on the screen. The amount
of seed left in the gene bank is, of course, not LESS than zero guiño

2) Process the information in cross_data.tsv and determine which genes are genetically-linked. To achieve this, you will have to do a Chi-square test on the F2 cross data. If you discover genes that are linked, this information should be added as a property of each of the genes (they are both linked to each other).

### Execute as  
```
ruby process_database.rb gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_file.tsv
```
