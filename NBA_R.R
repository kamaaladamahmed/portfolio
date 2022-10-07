# Get the game IDs from the past 3 seasons
selectedSeasons <- c(2020:2022)

# Get game IDs for Regular Season and Playoffs
gameIds_Reg <- suppressWarnings(seasons_schedule(seasons = selectedSeasons, season_types = "Regular Season") %>% select(idGame, slugMatchup))

gameIds_PO <- suppressWarnings(seasons_schedule(seasons = selectedSeasons, season_types = "Playoffs") %>% select(idGame, slugMatchup))

gameIds_all <- rbind(gameIds_Reg, gameIds_PO)

# Peek at the game IDs
head(gameIds_all)
tail(gameIds_all)

## Retrieve gamelog data for players and teams
# Get player gamelogs
P_gamelog_reg <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "player", season_types = "Regular Season"))

P_gamelog_po <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "player", season_types = "Playoffs"))

P_gamelog_all <- rbind(P_gamelog_reg, P_gamelog_po)
View(head(P_gamelog_all))

# Get team gamelogs
T_gamelog_reg <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "team", season_types = "Regular Season"))

T_gamelog_po <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "team", season_types = "Playoffs"))

T_gamelog_all <- rbind(T_gamelog_reg, T_gamelog_po)
View(head(T_gamelog_all))

## In this example, we use Regular Season data for our analysis
# Create Tbox (Team boxscore) for each Regular Season and create variables
Tbox <- T_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugTeam) %>%
  dplyr::summarise(GP=n(), MIN=sum(round(minutesTeam/5)),
                   PTS=sum(ptsTeam),
                   W=sum(outcomeGame=="W"), L=sum(outcomeGame=="L"),
                   P2M=sum(fg2mTeam), P2A=sum(fg2aTeam), P2p=P2M/P2A,
                   P3M=sum(fg3mTeam), P3A=sum(fg3aTeam), P3p=P3M/P3A,
                   FTM=sum(ftmTeam), FTA=sum(ftaTeam), FTp=FTM/FTA,
                   OREB=sum(orebTeam), DREB=sum(drebTeam), AST=sum(astTeam),
                   TOV=sum(tovTeam), STL=sum(stlTeam), BLK=sum(blkTeam),
                   PF=sum(pfTeam), PM=sum(plusminusTeam)) %>%
  as.data.frame()

# Create Obox (Opponent Team boxscore) for each Regular Season
Obox <- T_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugOpponent) %>%
  dplyr::summarise(GP=n(), MIN=sum(round(minutesTeam/5)),
                   PTS=sum(ptsTeam),
                   W=sum(outcomeGame=="L"), L=sum(outcomeGame=="W"),
                   P2M=sum(fg2mTeam), P2A=sum(fg2aTeam), P2p=P2M/P2A,
                   P3M=sum(fg3mTeam), P3A=sum(fg3aTeam), P3p=P3M/P3A,
                   FTM=sum(ftmTeam), FTA=sum(ftaTeam), FTp=FTM/FTA,
                   OREB=sum(orebTeam), DREB=sum(drebTeam), AST=sum(astTeam),
                   TOV=sum(tovTeam), STL=sum(stlTeam), BLK=sum(blkTeam),
                   PF=sum(pfTeam), PM=sum(plusminusTeam)) %>%
  as.data.frame()

# Create Pbox (Player boxscore) for each Regular Season
Pbox <- P_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugTeam, "Player"=namePlayer) %>%
  dplyr::summarise(GP=n(), MIN=sum(minutes), PTS=sum(pts),
                   P2M=sum(fg2m), P2A=sum(fg2a), P2p=100*P2M/P2A,
                   P3M=sum(fg3m), P3A=sum(fg3a), P3p=100*P3M/P3A,
                   FTM=sum(ftm), FTA=sum(fta), FTp=100*FTM/FTA,
                   OREB=sum(oreb), DREB=sum(dreb), AST=sum(ast),
                   TOV=sum(tov), STL=sum(stl), BLK=sum(blk),
                   PF=sum(pf)) %>%
  as.data.frame()


######## Exploring Turnovers/Minute and Points/Minute | Lakers, Warriors, Celtics, Heat


teamSelected <- "LAL"

Pbox.sel <- subset(Pbox, Team==teamSelected & MIN>=1000)

Pbox.sel$TOVmin <- Pbox.sel$TOV/Pbox.sel$MIN
Pbox.sel$PTSmin <- Pbox.sel$PTS/Pbox.sel$MIN


la <- ggplot(data=Pbox.sel, mapping = aes(x = reorder(Player, TOVmin), y = TOVmin, fill = PTSmin)) +
  geom_col() +
  labs( y = "TOV / MIN",
        x = "Player",
        title = " 'Turnovers per Minute, Points per Minute")

la + scale_fill_gradient(low="blue", high="red")



