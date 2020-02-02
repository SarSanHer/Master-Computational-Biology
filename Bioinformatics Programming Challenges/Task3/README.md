# Assigment #3 - GFF feature files and visualization
_(Instructions writen by Mark Wilkinson, taken from Moodle platform)_

Your biologist collaborators are going to do a site-directed/insertional mutagenesis in Arabidopsis, using the list of 167 genes from your last assignment as the desired targets.  Inserts will be targeted to the repeat CTTCTT, and they want inserts to go into EXONS.

### Your task
1) Using BioRuby, examine the sequences of the ~167 Arabidopsis genes from the last assignment by retrieving them from whatever database you wish
2) Take the coordinates of every CTTCTT sequence in every exon and create a new Sequence Feature (you can name the feature type, and source type, whatever you wish; the start and end coordinates are the first ‘C’ and the last ‘T’ of the match.).  Add that new Feature to the EnsEMBL Sequence object.  (YOU NEED TO KNOW:  When you do regular expression matching in Ruby, use RegEx/MatchData objects; there are methods that will tell you the starting and ending coordinates of the match in the string)
3) Once you have found them all, and added them all, loop over each one of your CTTCTT features (using the #features method of the EnsEMBL Sequence object) and create a GFF3-formatted file of these features. Output a report showing which (if any) genes on your list do NOT have exons with the CTTCTT repeat
4)Re-execute your GFF file creation so that the CTTCTT regions are now in the full chromosome coordinates used by EnsEMBL.  Save this as a separate file.
5) Prove that your GFF file is correct by uploading it to ENSEMBL and adding it as a new “track” to the genome browser of Arabidopsis 

### Execute as  
```
ruby main.rb
```
