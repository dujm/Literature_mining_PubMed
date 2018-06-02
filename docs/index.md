### Extract bibliographic content from PubMed




##### 1. Install RISmedpackage 
###### Documentation
###### https://cran.r-project.org/web/packages/RISmed/index.html
    install.packages(RISmed)

    
##### 2. Define searching by keywords(e.g. PTEN), database (pubmed), number (e.g. 500)
    library(RISmed)
    
    res <- EUtilsSummary("PTEN", type="esearch", db="pubmed", retmax=500) 
    
    QueryCount(res) 

##### 3. Download results of a query for any database of the National Center for Biotechnology Information
    EUtilsGet(res,type="efetch",db="pubmed")

###### Check summary of query
    summary(res)

##### 4. Collect information for output file
###### title of literature
    t<-ArticleTitle(EUtilsGet(res))

###### abstract
    a <-AbstractText(EUtilsGet(res))
    
###### pubmed date, title abstract year
    yta<-list(y,t,a)
    
###### year 
    y <- YearPubmed(EUtilsGet(res))

###### I only need the 1st author 
###### select first two of each vector in list
    at <- Author(EUtilsGet(res))
    
###### extract first row of each list
    at1 <-lapply(at, `[[`, 1)
    
###### extract first element of each row
    at_first<-lapply(at1, `[[`, 1)
    
###### format as dataframe, convert row to colomn using transpose, t()
    at_first_row <- as.data.frame(at_first)
    at_first_column <- t(at_first_row)                              



##### 5. Write output to csv
    full <- data.frame('1stAuthor'= at_first_column,'year' = y, 'Title'=t,'Abstract'=a)
    write.csv(full, file = "PTEN_pubmed_full.csv",row.names = FALSE)
