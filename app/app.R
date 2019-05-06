library(shiny)
library(shinythemes)
library(RISmed)
library(DT)

shinyApp(
  ui = fluidPage(
                 titlePanel(h3("PubMed Literature Search",style = "margin:20px 60px") ,windowTitle = "PubMed Literature"),
                 theme = shinytheme("journal"),
                 
                 
                 ########################condition one#############
                 
                 conditionalPanel(condition="input.conditionedPanels",
                                  sidebarPanel(width=3,
                                               textAreaInput("txt",
                                                             label = h5("Key Words"), 
                                                             value ='PTEN AND therapy',
                                                             width = "200px"),
                                               br() ,
                                               br() ,
                                               dateInput('date',format = "yyyy/mm/dd",
                                                         label = 'Earliest date',
                                                         value = Sys.Date() - 364,
                                                         width = "250px"
                                               ),
                                               dateInput('date2',format = "yyyy/mm/dd",
                                                         label = 'Last available date',
                                                         value = Sys.Date() + 1,
                                                         width = "250px"
                                               ),br() ,br() ,
                                               sliderInput("max",
                                                           "Maximum Number of Publications:",
                                                           min = 1,  max = 300,  value = 20,width = "300px"),
                                               br() ,br() ,
                                               
                                               actionButton("search", label = h6("Search"),width = "100px", 
                                                            style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
                                  
                                  mainPanel(
                                    tabsetPanel(
                                      id = "conditionedPanels",# this is the id of the conditional panels
                                      tabPanel(value=1,
                                               
                                               h4('Result'),
                                               br(),
                                               verbatimTextOutput("txtout",placeholder = TRUE),
                                               br() ,br() ,
                                               verbatimTextOutput("dateRangeText", placeholder = TRUE),
                                               DT::dataTableOutput("table"),
                                               #downloadLink("downloadData1", "Download results"),br(),
                                               style = "width:100%"),

                                      tabPanel(value=2,
                                                h4('FAQ'),
                                               hr(), h4("1. How can I build my own literature search app?"), 
                                               h5("Check here https://github.com/dujm/PubMed-Literature-mining"),
                                               br(), h4("2. What package did you use?"),
                                               h5("RISMed and R Shiny")
                                      )
)
)
)
),

  server = function(input, output) {
    column(6,
           verbatimTextOutput("txt"),
           verbatimTextOutput("dateRangeText")

    )
    output$txtout <- renderText({
      paste("Key words are", 
      paste(input$txt)
      )
    })
    output$dateRangeText  <- renderText({
      paste("Publications from", 
            paste(input$date, "to ",input$date2)
      )
    })
    
    
    
    df_gene <- eventReactive(eventExpr = input$search, {
      if(input$search > 0) {
        # Key words
        value = input$txt
        print(value)
        split_query <- strsplit(value,'\n')
        print(split_query) 
        
        # date
        print(input$date)
        start_date = gsub("-", "/", as.character(input$date))
        end_date = gsub("-", "/", as.character(input$date2))
        print(start_date)

        # Max results
        max_pub = as.integer(input$max)
        

        res <- EUtilsSummary(split_query, type="esearch", db="pubmed", mindate= start_date, maxdate=end_date, retmax=max_pub)
        print(res)
        EUtilsGet(res,type="efetch",db="pubmed")
        QueryCount(res) # No. of results returned
        summary(res) # Summary of your query
        y <- YearPubmed(EUtilsGet(res)) # Year of publication
        t<-ArticleTitle(EUtilsGet(res)) # Title
        a <-AbstractText(EUtilsGet(res)) # Abstract
        at <- Author(EUtilsGet(res))
        at1 <-lapply(at, `[[`, 1) # Extract the first row of each list because I only need the 1st author
        at_first<-lapply(at1, `[[`, 1) # Extract the first element of each row
        at_first_row <- as.data.frame(at_first) # Format as dataframe
        at_first_column <- t(at_first_row)  # Convert row to column using transpose t()  
        myresults <- data.frame('Author'= at_first_column,'year' = y, 'Title'=t,'Abstract'=a) 
        #print(myresults)
        return(myresults)
      }
    })
    
    output$table<- DT::renderDataTable(server = FALSE,{
      gdf <- df_gene()
      DT::datatable(gdf, escape=F ,rownames = F,
                    extensions = c('Buttons', 'Scroller'), 
                    options = list(
                      dom = "lfrtBip",
                      
                      deferRender = TRUE,
                      #scrollY = 500,
                      #scroller = TRUE,
                      buttons = list(list(extend = 'collection', buttons = c('csv', 'excel'), text = 'Download searching results'))
                      
                    )
                    
      ) %>%
        formatStyle(columns = 1:4,color = "black")
      
      
    })
  }

)