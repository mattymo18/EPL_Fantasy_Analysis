library(tidyverse)

args <- commandArgs(trailingOnly = T)
Game.Week <- as.numeric(args[[1]])

DF.player.raw <- read.csv("https://0e0c55ie39.execute-api.eu-central-1.amazonaws.com/default/fplAnalytics-DownloadPlayerStatusData")
DF.fixture.raw <- read.csv("Source_Data/Fixture.Data.DEC13.csv") #going to have to fix this for cmd line use

#ok not sure yet how to do this part but will figure it out, I want him to specify the Game.Week in cmd line

Current.game.week <- 13

Past.game.week <- as.numeric(Current.game.week - 1)

DF.player.clean <- DF.player.raw %>% 
  select(name, position, team, cost, status, minutes, total_points, points_per_game, 
         bonus, selected_by_percent)

DF.fixture.pivot.clean <- DF.fixture.raw %>% 
  group_by(team_name_short, fpl_gw) %>% 
  summarise("Fixture_Difficulty_Rating" = 100-spi_opponent) %>% 
  na.omit() 

SPI.Games.Played.Table <- DF.fixture.pivot.clean %>% 
  filter(fpl_gw <= Past.game.week) %>% 
  group_by(team_name_short) %>% 
  summarise("Total_SPI_to_Date" = sum(Fixture_Difficulty_Rating))

SPI.Current.Game.Table <- DF.fixture.pivot.clean %>% 
  filter(fpl_gw == Current.game.week) %>% 
  group_by(team_name_short) %>% 
  select(-fpl_gw) %>% 
  rename("Current_Gameweek_Difficulty_Rating" = Fixture_Difficulty_Rating)

SPI.Next4.Game.Table <- DF.fixture.pivot.clean %>% 
  filter(fpl_gw >= Current.game.week & fpl_gw <= Current.game.week + 3) %>% 
  group_by(team_name_short) %>% 
  summarise("Next4_Games_Difficulty_Rating" = sum(Fixture_Difficulty_Rating))

SPI.Next6.Game.Table <- DF.fixture.pivot.clean %>% 
  filter(fpl_gw >= Current.game.week & fpl_gw <= Current.game.week + 5) %>% 
  group_by(team_name_short) %>% 
  summarise("Next6_Games_Difficulty_Rating" = sum(Fixture_Difficulty_Rating))

Team.Names <- c("ARS", "AVL", "BHA", "BUR", "CHE", "CRY", "EVE", "FUL", "LEE", "LEI", "LIV", "MCI", "MUN", "NEW", "SHU", "SOU", "TOT", "WBA", "WHU", "WOL")
DF.player.clean <- DF.player.clean %>% 
  mutate(Estimated_Player_Points = points_per_game*(Current.game.week-1)) %>% 
  mutate(Estimated_Player_Points_per_fixture_difficulty = 
           ifelse(DF.player.clean$team == Team.Names[1], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[1, 2]), 
                  ifelse(DF.player.clean$team == Team.Names[2], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[2, 2]),
                         ifelse(DF.player.clean$team == Team.Names[3], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[3, 2]),
                                ifelse(DF.player.clean$team == Team.Names[4], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[4, 2]),
                                       ifelse(DF.player.clean$team == Team.Names[5], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[5, 2]),
                                              ifelse( DF.player.clean$team == Team.Names[6], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[6, 2]),
                                                      ifelse(DF.player.clean$team == Team.Names[7], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[7, 2]),
                                                             ifelse(DF.player.clean$team == Team.Names[8], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[8, 2]),
                                                                    ifelse(DF.player.clean$team == Team.Names[9], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[9, 2]),
                                                                           ifelse(DF.player.clean$team == Team.Names[10], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[10, 2]),
                                                                                  ifelse(DF.player.clean$team == Team.Names[11], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[11, 2]),
                                                                                         ifelse(DF.player.clean$team == Team.Names[12], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[12, 2]),
                                                                                                ifelse(DF.player.clean$team == Team.Names[13], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[13, 2]),
                                                                                                       ifelse(DF.player.clean$team == Team.Names[14], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[14, 2]),
                                                                                                              ifelse(DF.player.clean$team == Team.Names[15], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[15, 2]),
                                                                                                                     ifelse(DF.player.clean$team == Team.Names[16], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[16, 2]),
                                                                                                                            ifelse(DF.player.clean$team == Team.Names[17], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[17, 2]),
                                                                                                                                   ifelse(DF.player.clean$team == Team.Names[18], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[18, 2]),
                                                                                                                                          ifelse(DF.player.clean$team == Team.Names[19], Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[19, 2]), 
                                                                                                                                                 Estimated_Player_Points/as.numeric(SPI.Games.Played.Table[20, 2])))))))))))))))))))))
#not sure yet how I want to do this, I'm thinking a bunch of nested ifelse for each team, I cant think of a better way to do it honestly, other than doing it by hand individually for each team, but nested ifelse should work

DF.player.clean.1 <- left_join(DF.player.clean, SPI.Current.Game.Table %>% rename(team = team_name_short))
DF.player.clean.2 <- left_join(DF.player.clean.1, SPI.Next4.Game.Table %>% rename(team = team_name_short))
DF.player.clean.3 <- left_join(DF.player.clean.2, SPI.Next6.Game.Table %>% rename(team = team_name_short))

DF.Final <- DF.player.clean.3 %>% 
  mutate(Expected_Point_Current_Gameweek = Estimated_Player_Points_per_fixture_difficulty*Current_Gameweek_Difficulty_Rating) %>% 
  mutate(Expected_Point_Next4_Gameweek = Estimated_Player_Points_per_fixture_difficulty*Next4_Games_Difficulty_Rating) %>% 
  mutate(Expected_Point_Next6_Gameweek = Estimated_Player_Points_per_fixture_difficulty*Next6_Games_Difficulty_Rating) %>% 
  select(-c(Estimated_Player_Points_per_fixture_difficulty, Current_Gameweek_Difficulty_Rating, Next4_Games_Difficulty_Rating, Next6_Games_Difficulty_Rating)) %>% 
  filter(minutes >= Past.game.week*60) %>% 
  filter(status == "Available") %>% 
  mutate(Value = (Past.game.week*points_per_game)/cost) %>% 
  arrange(desc(Value))

write.csv(DF.Final, "Derived_Data/Gameweek13.Final.csv") #again I'll have to figure this out with the whole cmd line input