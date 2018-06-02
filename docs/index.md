### Extract bibliographic content from PubMed




##### Install RISmedpackage 
##### https://cran.r-project.org/web/packages/RISmed/index.html
    install.packages(RISmed)
    library(RISmed)
    
##### Define searching 
    res <- EUtilsSummary("PTEN", type="esearch", db="pubmed", retmax=500)
    
    QueryCount(res) 

##### Download results of a query for any database of the National Center for Biotechnology Information
    EUtilsGet(res,type="efetch",db="pubmed")

##### summary
    summary(res)

#####  Download results of a query for any database of the National Center for Biotechnology Information
    EUtilsGet(res,type="efetch",db="pubmed")

##### title
    t<-ArticleTitle(EUtilsGet(res))

##### abstract
    a <-AbstractText(EUtilsGet(res))
    
##### pubmed date, title abstract year
    yta<-list(y,t,a)
    
##### year 
    y <- YearPubmed(EUtilsGet(res))

##### I only need the 1st author 
###### select first two of each vector in list
    at <- Author(EUtilsGet(res))
###### extract first row of each list
    at1 <-lapply(at, `[[`, 1)
###### extract first element of each row
    at_first<-lapply(at1, `[[`, 1)
###### format as dataframe, convert row to colomn using transpose, t()
    at_first_row <- as.data.frame(at_first)
    at_first_column <- t(at_first_row)                              



##### Write output to csv
    full <- data.frame('1stAuthor'= at_first_column,'year' = y, 'Title'=t,'Abstract'=a)
    write.csv(full, file = "PTEN_pubmed_full.csv",row.names = FALSE)
