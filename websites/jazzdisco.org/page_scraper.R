#provide a url of catalog page, it will return the table with columns: 
#AlbumCode LeadArtist AssociatedArtist
page_scraper <- function(page_url){                           
    page_source <- html_session_new(page_url)
    #As you already know, the original web-page format is a total mess, some elements are not even included in the CSS, so this web-scraping script is different with
    #usual ones
    #Get the node with all information ------------------------
    catalog_node <- page_source %>%
        html_node("#catalog-data")
    
    # identify nodes with information we don't want, discard them and we use whatever is left ----------------------
    table_nodes <- catalog_node %>% html_nodes("table")
    date_nodes <- catalog_node %>% html_nodes(".date")
    i_nodes <- catalog_node %>% html_nodes("i")
    h2_nodes <- catalog_node %>% html_nodes("h2")
    xml_remove(table_nodes)
    xml_remove(date_nodes)
    xml_remove(i_nodes)
    xml_remove(h2_nodes)
    
    #remove extra strings ---------------------------
    full_text <- (catalog_node %>% html_text() %>% str_split("\\n"))[[1]]
    removed_1 <- full_text[nchar(full_text) > 0] #remove empty strings
    removed_2 <- removed_1[!str_detect(removed_1,"^same")]#remove string that start with same(same personnel)
    #removed_3 <- removed_2[!str_detect(removed_2,"^no details")]#remove any string that start with no details
    meaningful_text <- removed_2[!str_detect(removed_2,"^\\*\\*")] # remove strings start with ** 
    
    
    
    #album name ----------------
    album_name <- catalog_node %>%
        html_nodes("h3") %>%
        html_text()
    
    #match album name to meaningful_text -------------
    position_matching <- match(meaningful_text,album_name)
    album_position <- which(!is.na(position_matching))
    #match album to artists -----------
    for (i in 2:length(position_matching)) {
        if(is.na(position_matching[i])){
            position_matching[i] <- position_matching[i-1]
        }
    }
    artist_matching <- position_matching[-album_position]
    #create table to store results
    matching_table <- tibble(headline=album_name[artist_matching],
                             artist=meaningful_text[-album_position])
    
    #using regular expression to extract information ------------------
    result_table <- matching_table %>%
        mutate(AlbumCode=str_trim(str_extract(headline,"^.+?(?=\\u00A0)"))) %>% #get album code
        mutate(AssociatedArtist = str_split(artist,";")) %>% unnest(AssociatedArtist) %>% # make all artists in a list and unlist it
        mutate(AssociatedArtist = str_extract(AssociatedArtist,"^.+?(?=,)")) %>%#remove instrument
        mutate(AssociatedArtist = str_trim(AssociatedArtist)) %>% #trim strings
        mutate(AssociatedArtist = if_else(str_detect(AssociatedArtist,"^(\\+)"), # + may apprear at the beginning of the string, remove it
                                          str_extract(AssociatedArtist,"(?<=\\+).+"), #remove it if + appears
                                          AssociatedArtist)) %>% # do not change if not exist
        #headlines have different format that makes it diffcult to extract the Lead Artists, so I have to do this in a complicated way
        group_by(AlbumCode) %>%
        mutate(artists_or = str_c("(",AssociatedArtist,")",collapse = "|")) %>% #create regular expression to match lead artist
        ungroup() %>%
        mutate(LeadArtist = str_extract_all(headline,artists_or)) %>% unnest(LeadArtist)# make all lead artists in a list and unlist it
    
    table_out <-  result_table %>%
        select(AlbumCode,LeadArtist,AssociatedArtist)
    
    return(table_out)
}
