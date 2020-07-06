# Stroke Comorbidity Searches in MedRxiv
# 03 June 2020
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

############################################################################################

# install & load the required packages
# install.packages("devtools")

devtools::install_github("mcguinlu/medrxivr")
library(medrxivr)


## get api info
medrxiv_data <- mx_api_content()


# rough idea of numbers from searching on the web interface
topicD1 <- c("stroke", "mouse", "diabetes")
# 41 in webpage
topicD2 <- c("stroke rat diabetes")
# 72
topicD3 <- c("stroke rodent diabetes")
# 25



################### 
### based on this documentation: https://mcguinlu.github.io/medrxivr/articles/building-complex-search-strategies.html#building-your-search-with-boolean-operators
####################

topicStroke <- c("stroke")
#mouse OR rat OR rodent
topicSpecies <- c("mouse", "rat", "rodent")
topicDisease <- c("diabetes", "obesity", "metabolic syndrome")

# searches stroke AND (mouse OR rat OR rodent) AND diabetes
query <- list(topicStroke, topicSpecies, topicDisease)


## run the search 
mx_results <- mx_search(data = medrxiv_data, 
  query = query, 
  from.date =20190625, to.date =20200703, NOT = c(""), 
  fields = c("title", "abstract"), 
  deduplicate = TRUE)

### print the reuslts to a csv file
## csv2 for german excel that has ';' as seperator
write.csv2(mx_results, file="medrxivResults.csv", row.names = F, sep = ";")

## Download the results PDFs - does not work with biorxiv DOIs as preffix URL is specified to medrxiv.org
mx_download(mx_results, directory = "pdf/", create = TRUE)
