USAGE
-----
You'll need Docker and the ability to run Docker as your current user.

You'll need to build the container:

    > docker build . -t EPL-Proj-Envir

This Docker container is based on rocker/verse. To run rstudio server:

    > docker run -v `pwd`:/home/rstudio -p 8787:8787 -e PASSWORD=mypass -t EPL-Proj-Envir
      
Then connect the machine on port 8787.

#### Make
Use Makefile as recipe book for building artifacts found in derived directories. 

##### Example:
In local project directory, to build artifact for Game Week 15, Final_Data.csv:

    > Game.Week=15 make Derived_Data/Final_Data.csv
    
Use artifacts before colon as make targets. Dependencies are listed after colon. 

Introduction
------------

This project provides the user with an automated data scraper for Fanatasy English Premier League Football. Analysis builds pivot tables for expected points per gameweek and ranks players by current value.

#### Data:

Data is taken from:

https://0e0c55ie39.execute-api.eu-central-1.amazonaws.com/default/fplAnalytics-DownloadPlayerStatusData 
    
https://public.tableau.com/profile/timbayer#!/vizhome/PremierLeagueFixtures2021/PLFixtures 
    
##### Tableau Data:

Data will need to be saved in Source_Data directory as "Fixture.Data.`DATE`.csv"


