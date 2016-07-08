
## Downloaded from http://www.hockey-reference.com/play-index/pgl_finder.cgi?request=1&match=game&year_min=2016&year_max=2016&season_start=1&season_end=-1&rookie=N&age_min=0&age_max=99&team_id=DET&is_playoffs=N&series_game_min=1&series_game_max=7&team_game_min=1&team_game_max=84&player_game_min=1&player_game_max=9999&pos=S&order_by=date_game&order_by_asc=Y
## Click "Share & More" -> "Get as Excel Workbook" which exports as csv for some reason...

orderNames <- function(playerData){
     
     lastNames <- substr(unique(playerData$Player), regexpr(" ", unique(playerData$Player), fixed=TRUE)+1, nchar(unique(playerData$Player)))
     
     lastNames <- sort(lastNames)
     
    ## orderedNames <- sapply(lastNames, function(x){unique(playerData$Player)[regexpr(x,unique(playerData$Player)) > 0]})
     
     orderedNames <- as.character(sapply(lastNames, function(x){unique(playerData$Player)[regexpr(x,unique(playerData$Player)) > 0]}))
     
     names(orderedNames) <- sapply(lastNames, function(x){paste(unique(playerData$Player)[regexpr(x,unique(playerData$Player)) > 0],playerData[playerData$Player == unique(playerData$Player)[regexpr(x,unique(playerData$Player)) > 0],3][1])})
     
     return(orderedNames)
     
}


neatGraphs <- function(playerData, players, stat){
     
     playerData$factorPlayer <- factor(playerData$Player)
     
     scoringPlot <- ggplot() + 
          labs(x= "Date") + 
          labs(y=stat) + 
        ##  labs(title="Player Stats for 2015-2016 Season") + 
          theme_minimal() + 
          theme(title = element_text(face = "bold", size=18),
                plot.margin=unit(c(2,2,2,2),"lines"),
                axis.text = element_text(size=12, face="bold"),
                axis.title.x = element_text(margin=margin(25,0,0,0), size=16),
                axis.title.y = element_text(margin=margin(0,25,0,0), size=16))
     
     for(player in players){
          
          temp <- subset(playerData, Player %in% player)
          temp$cumSum <- cumsum(temp[,match(stat, names(temp))])
          scoringPlot <- scoringPlot + geom_line(data=temp, aes(x=Date, y=cumSum, color=Player))
             
     }
     
     return(scoringPlot)
}


getPlayerData <- function(){
     
     ## Run through all game data files (since max export size is 300 rows, there are potentially unknown number of export files but certainly less than 100)
     for(i in 1:100){
          
          fileName <- paste("GameStats",i, ".csv", sep="")
          
          ## If out of game stats files, break from loop.
          if(!file.exists(fileName)){
               break
          }
          
          newplayerData <- read.csv(fileName, stringsAsFactors = FALSE);
          
          ## Row 1 contains traditional column headers.
          names(newplayerData) <- newplayerData[1,]
          
          ## Remove all reduntant rows containing column headers.
          newplayerData <- newplayerData[-1,]
          
          if(i==1){
               
               playerData <- newplayerData
                    
          }else{
          
               playerData <- rbind(playerData, newplayerData)
          
          }
          
     }
     
     ## Remove all rows with redundant column name info.
     playerData <- playerData[playerData$Date != "Date",]
     
     ## Player names contain weird backslash thingies. Clean that up.
     playerData[,"Player"] <- substr(playerData[,"Player"],1,as.numeric(regexec("\\\\", playerData[,"Player"]))-1)
     
     ## Get rid of first column (rank)
     playerData <- playerData[,2:length(names(playerData))]
     
     ## Set more descriptive columns names.
     names(playerData) <- c("Player", "Age", "Position", "Date", "Team", "Home Or Away", "Opponent", "Result", "Goals", "Assists", "Points", "Plus Minus", "Penalty Minutes", "Even Strength Goals", "Power Play Goals", "Short Handed Goals", "Shots","Shooting Percentage", "Number Of Shifts", "Time On Ice")
     
     ## Relable Home and Away games.
     playerData[,"Home Or Away"] <- sub("", "Home", playerData[,"Home Or Away"])
     playerData[,"Home Or Away"] <- sub("Home@", "Away", playerData[,"Home Or Away"])
     
     ## Reformate dates as dates and not characters.
     playerData$Date <- as.Date(playerData$Date, format="%Y-%m-%d")
     
     ## Format ages as decimals instead of years and days old
     playerData$Age <- round(as.numeric(substr(playerData$Age, 1, regexpr("-", playerData$Age)-1)) + 
                                as.numeric(substr(playerData$Age, regexpr("-", playerData$Age)+1, nchar(playerData$Age)))/365,2)
     
     ## Format time on ice as decimal instead of minutes and seconds.
     playerData$`Time On Ice` <- round(as.numeric(substr(playerData$`Time On Ice`, 1, regexpr(":", playerData$`Time On Ice`)-1)) + 
                                      as.numeric(substr(playerData$`Time On Ice`, regexpr(":", playerData$`Time On Ice`)+1, nchar(playerData$`Time On Ice`)))/60,2)
     
     ## Format remaining numeric columns as numeric.
     playerData[,9:19] <- sapply(playerData[,9:19], as.numeric)
     
     ## Set NA shooting percentages to 0.
     playerData$`Shooting Percentage`[is.na(playerData$`Shooting Percentage`)] <- 0
     
     return(playerData)
}


downloadData <- function(){
     
     ## This downloads the webpage, but not the csv. I'm not sure how to access the link to the csv programmatically.
     ## This is potentially an awesome way to go since I could grab any team very easily.
     
     require(beepr)
     
     for(n in 1:100){
     
          print(paste("Downloading file",n));
          
          requestUrl <- paste("http://www.hockey-reference.com/play-index/pgl_finder.cgi?request=1&player=&match=game&year_min=2016&year_max=2016&age_min=0&age_max=99&team_id=DET&opp_id=&is_playoffs=N&overtimes=&on_birthday=&game_location=&playoff_round=&round_set=single&game_result=&pos=S&c1stat=&c1comp=&c1val=&c2stat=&c2comp=&c2val=&c3stat=&c3comp=&c3val=&c4stat=&c4comp=&c4val=&order_by=date_game&order_by_asc=Y&season_start=1&season_end=-1&series_game_min=1&series_game_max=84&team_game_min=1&team_game_max=84&player_game_min=1&player_game_max=99999&offset=", 300*(n-1), sep="")
     
          download.file(requestUrl, paste("GameStats", n, sep=""))
     
          beep(2)
          
     }
}
