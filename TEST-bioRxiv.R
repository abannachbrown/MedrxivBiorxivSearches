# Stroke Comorbidity Searches in BioRxiv
# 22 June 2020
# ABB

### Search Terms from Torsten
#Search in bioRxiv and medRxiv
# Search terms for Diabetes:
# for abstract or title "stroke mouse diabetes" (match all words)
# for abstract or title "stroke rat diabetes" (match all words)
# for abstract or title "stroke rodent diabetes" (match all words)
# 
# Search terms for obesity:
# for abstract or title "stroke mouse obesity" (match all words)
# for abstract or title "stroke rat obesity" (match all words)
# for abstract or title "stroke rodent obesity" (match all words)
# 
# Search terms for metabolic syndrome:
# for abstract or title "stroke mouse metabolic syndrome" (match all words)
# for abstract or title "stroke rat metabolic syndrome" (match all words)
# for abstract or title "stroke rodent metabolic syndrome" (match all words)

###########################################################################################
## Problem with all biorxiv packages is that the search function is only on full text
############################################################################################

# install.packages("biorxivr")
### install developmental version
# library(devtools)
# install_github("emhart/biorxiv")

library(biorxivr)

### so far each of these are limited to 10 records because downloading approx 2000 articles 
### will take along time so we need to be sure we need all these articles
# change limit to max when running 'properly' to retreive all records
diabetes1 <- bx_search("stroke mouse diabetes", limit = 100)
# should retrieve 558 on 23.06.2020
diabetes1$found

diabetes2 <- bx_search("stroke rat diabetes", limit = 100)
# should retrieve 1,808 on 23.06.2020
diabetes2$found

diabetes3 <- bx_search("stroke rodent diabetes", limit = 100)
# should retrieve 996 on 23.06.2020
diabetes3$found


##### extract details
diabetes1
diabetes1details <-  bx_extract(diabetes1)

diabetes2
diabetes2details <-  bx_extract(diabetes2)

diabetes3
diabetes3details <-  bx_extract(diabetes3)

# combine and ensure unique
diabetest_all <- c(diabetes1details, diabetes2details, diabetes3details)
refs_unique_diabetes <- unique(diabetest_all)

#### download PDFs
bx_download(diabetes1,"~/biorxiv_pdfs")
bx_download(diabetes2,"~/biorxiv_pdfs")
bx_download(diabetes3,"~/biorxiv_pdfs")

#####################################
# this package cannot search specific queries - only download all articles between 2 dates

# # Install package
# install.packages("devtools")
# devtools::install_github("nicholasmfraser/rbiorxiv")
# 
# # Load package
# library(rbiorxiv)
 #########################################

######################################
### 'fulltext' package method
### does essentially the same as the 'emhart/biorxiv' package above
### but gives more options of what information to download including full text in XML machine-readable

install.packages("fulltext")
library(fulltext)

# expand limit = - to download all refs (will take a long time)
FTdiabetes1 <- fulltext::ft_search(query = 'stroke mouse diabetes', from = 'biorxiv', limit = 10)
FTdiabetes2 <- fulltext::ft_search(query = 'stroke rat diabetes', from = 'biorxiv', limit = 10)
FTdiabetes3 <- fulltext::ft_search(query = 'stroke rodent diabetes', from = 'biorxiv', limit = 10)

FTobesity1 <- fulltext::ft_search(query = 'stroke mouse obesity', from = 'biorxiv', limit = 10)
FTobesity2 <- fulltext::ft_search(query = 'stroke rat obesity', from = 'biorxiv', limit = 10)
FTobesity3 <- fulltext::ft_search(query = 'stroke rodent obesity', from = 'biorxiv', limit = 10)

FTmeta1 <- fulltext::ft_search(query = 'stroke mouse metabolic syndrome', from = 'biorxiv', limit = 10)
FTmeta2 <- fulltext::ft_search(query = 'stroke rat metabolic syndrome', from = 'biorxiv', limit = 10)
FTmeta3 <- fulltext::ft_search(query = 'stroke rodent metabolic syndrome', from = 'biorxiv', limit = 10)

# number found
FTdiabetes1 #562
FTdiabetes2 #1821
FTdiabetes3 #1006

## get full text in XML if we want
# out <- ft_get(FTdiabetes1)
# out <- ft_get(FTdiabetes1$biorxiv$data$id[1:100], from = "crossref")

## get the full text links seperately
# links <- ft_links(FTdiabetes1$biorxiv$data$doi, from = "crossref")

## get the abstract seperately
# abstracts <- ft_abstract(x = FTdiabetes1$biorxiv$data$doi, from = "crossref")


##### get data in clean format
refs <- data.frame("doi"=c(FTdiabetes1$biorxiv$data$doi, 
                          FTdiabetes2$biorxiv$data$doi,
                          FTdiabetes3$biorxiv$data$doi),
                  "title"=c(
                    FTdiabetes1$biorxiv$data$title,
                    FTdiabetes2$biorxiv$data$title,
                    FTdiabetes3$biorxiv$data$title
                  ), 
                  "url"=c(
                    FTdiabetes1$biorxiv$data$url,
                    FTdiabetes2$biorxiv$data$url,
                    FTdiabetes3$biorxiv$data$url
                  ),
                  "abstract"=c(
                    FTdiabetes1$biorxiv$data$abstract,
                    FTdiabetes2$biorxiv$data$abstract,
                    FTdiabetes3$biorxiv$data$abstract
                  ), 
                  "date_published"=c(
                    FTdiabetes1$biorxiv$data$deposited,
                    FTdiabetes2$biorxiv$data$deposited,
                    FTdiabetes3$biorxiv$data$deposited
                  )
                  ### do something with authors here
                  
)

## identify unique articles across each search
refs_unique_diabetes <- unique(refs) # Clean repeated dois
length(refs_unique_diabetes$doi)

#######################################################################
# do filtering for search terms in title and abstract only
