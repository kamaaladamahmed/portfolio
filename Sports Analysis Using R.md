---
title: "Russell Westbrook's Performance in Los Angeles"
author: "Kamaal Adam Ahmed"
date: "2022-10-12"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

<br>

#### Objective
Throughout this project I will be using nbastatR, along with many other packages, to explore the data on Russell Westbrook's career. I will begin by looking at his seasonal performance throughout his career, then diving deeper into his most recent season with the Los Angeles Lakers.
<br>

#### Load Packages

```{r packages, message = FALSE, warning = FALSE}
library(tidyverse)
library(nbastatR)
library(BasketballAnalyzeR)
library(jsonlite)
library(janitor)
library(extrafont)
library(ggrepel)
library(scales)
library(teamcolors)
library(zoo)
library(future)
library(lubridate)
library(worldfootballR)
library(formattable)
library(cowplot)

Sys.setenv("VROOM_CONNECTION_SIZE" = 999999)
```

<br>

#### Career Performance

```{r career_data, message=FALSE, warning=FALSE}

player_stats <- nbastatR::players_careers(players = c("Russell Westbrook"), modes = c("PerGame")) %>%
  filter(nameTable == "SeasonTotalsRegularSeason") %>%
  unnest(cols = c(dataTable))

```

```{r career_setup, message=FALSE, warning=FALSE}
rw <- player_stats
rw$Season <- rw$slugSeason
rw$Points <- rw$pts
rw$Assists <- rw$ast
rw$Turnovers <- rw$tov
rw$ThreePt_Percent <- rw$pctFG3
rw$TwoPt_Percent <- rw$pctFG2
rw$Percent <- rw$pctFG
rw$FT_Percent <- rw$pctFT
rw$Rebounds <- rw$treb
rw$Steals <- rw$stl

teamcolor <- c("#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#007AC1", "#CE1141", "#002B5C", "#552583")
```

```{r}
## Points
ggplot(data = rw, mapping = aes(x=Season, y = Points, fill = Season)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = teamcolor) +
  labs(title = "Points per Game")

## Assists
ggplot(data = rw, mapping = aes(x=Season, y = Assists, fill = Season)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = teamcolor) +
  labs(title = "Assists per Game")

## Rebounds
ggplot(data = rw, mapping = aes(x=Season, y = Rebounds, fill = Season)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = teamcolor) +
  labs(title = "Rebounds per Game")

## Steals
ggplot(data = rw, mapping = aes(x=Season, y = Steals, fill = Season)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = teamcolor) +
  labs(title = "Steals per Game")

## Turnovers
ggplot(data = rw, mapping = aes(x=Season, y = Turnovers, fill = Season)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = teamcolor) +
  labs(title = "Turnovers per Game")
```

#### 2021-2022 Season with the Los Angeles Lakers

```{r message=FALSE, warning=FALSE}
selectedSeasons <- 2022

gameIds_Reg <- seasons_schedule(seasons = selectedSeasons, season_types = "Regular Season") %>% select(idGame, slugMatchup)

P_gamelog_reg <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "player", season_types = "Regular Season"))

T_gamelog_reg <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "team", season_types = "Regular Season"))

Pbox <- P_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugTeam, "Player"=namePlayer) %>%
  dplyr::summarise(GP=n(), MIN=sum(minutes), PTS=sum(pts),
                   P2M=sum(fg2m), P2A=sum(fg2a), P2p=100*P2M/P2A,
                   P3M=sum(fg3m), P3A=sum(fg3a), P3p=100*P3M/P3A,
                   FTM=sum(ftm), FTA=sum(fta), FTp=100*FTM/FTA, 
                   FGA=sum(fga), OREB=sum(oreb), DREB=sum(dreb),
                   AST=sum(ast), TOV=sum(tov), STL=sum(stl), BLK=sum(blk),
                   PF=sum(pf), P3A=sum(fg3a), P3M=sum(fg3m), REB=sum(treb), 
                   ptsMIN=((sum(pts))/(sum(minutes))), fgaMIN=(sum(fga))/(sum(minutes))) %>%
  as.data.frame()

teamSelected <- "LAL"
Pbox.sel <- subset(Pbox, Team==teamSelected & MIN>=1000)
seasonSelected <- 2022

```

```{r}

# Total Minutes Played

ggplot(data=Pbox.sel[Pbox.sel$Season==seasonSelected,], aes(x = reorder(Player, MIN), y = MIN)) +
  geom_col(fill = "#552583") +
  coord_flip() +
  labs(x = "Player", y = "Minutes", title = "Minutes")

# Points, Assists, Turnovers / Game

ggplot(data=Pbox.sel[Pbox.sel$Season==seasonSelected,], aes(x = AST/GP, y = PTS/GP, colour = TOV/GP)) +
  geom_text(aes(label = Player)) +
  scale_colour_gradient(low="#552583", high="#FDB927") +
  labs(x = "Assists per Game", y = "Points per Game", title = "Assists, Points, and Turnovers Per Game")

# Three Point Shooting Performance

ggplot(data=Pbox.sel[Pbox.sel$Season==seasonSelected,], aes(x = reorder(Player, P3A), y = P3A)) +
  geom_col(fill = "#552583") +
  geom_col(aes(x = reorder(Player, P3A), y= P3M), fill = "#FDB927") +
  coord_flip() +
  labs(x = "Player", y = "Three Pointers", title = "Three Point Shots Made, Attempts")








```



