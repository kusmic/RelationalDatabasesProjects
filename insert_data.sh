#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# 
# Takes games.csv and turns it into SQL databases. In the end need:
# 2 TABLES:
# 1) games:
#     - game_id SERIAL pk, year INT NOT NULL, winner_id INT NOT NULL fk, opponent_id INT NOT NULL fk, winner_goals INT NOT NULL, opponent_goals INT NOT NULL, round VARCHAR(60) NOT NULL
# 2) teams:
#     - team_id SERIAL pk, name VARCHAR(60) pk

# 20 second time limit on run ***
# Maybe make teams table first

#READ_CSV () { # from https://stackoverflow.com/questions/4286469/how-to-parse-a-csv-file-in-bash#4286841 very nify way, skips header line
#}

if [[ $1 == "test" ]]
then
  CSVFILE="games_test.csv" # change this when testing
else
  CSVFILE="games.csv" # change this when not testing
fi
echo -e "\n~ Tabling $CSVFILE ~"
TRUNC_RESULT=$($PSQL "TRUNCATE TABLE games,teams RESTART IDENTITY")
#CAT_CSV=$(READ_CSV $CSVFILE)

skip_headers=1
while IFS=, read -r YR RND WIN OPP WGL OGL
do
  if ((skip_headers))
  then
    ((skip_headers--))
  else
    #echo $YR #$RND $WIN $OPP $WGL $OGL 
    # get team id for winner
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    if [[ -z $WIN_ID ]]
    then
      TEAM_INSERT=$($PSQL "INSERT INTO teams (name) VALUES ('$WIN')")
      echo -e "Inserted $WIN: $TEAM_INSERT"
      WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    fi

    # get opponent_id
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    if [[ -z $OPP_ID ]]
    then
      TEAM_INSERT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPP')")
      echo -e "Inserted $OPP: $TEAM_INSERT"
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    fi
    # check games table if entry exist, if not add it
    CHECK_GAME_ID_RES=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WIN_ID AND opponent_id=$OPP_ID")
    if [[ -z $CHECK_GAME_ID_RES ]]
    then
      # insert it YR RND WIN OPP WGL OGL
      INSERT_GAME_RES=$($PSQL "INSERT INTO games (year,winner_id,opponent_id,winner_goals,opponent_goals,round) VALUES ($YR,$WIN_ID,$OPP_ID,$WGL,$OGL,'$RND')")
      echo -e "Inserted game: $YR $RND, $WIN-$OPP ($WGL-$OGL): $INSERT_GAME_RES"
    fi
  fi
done < $CSVFILE

#echo -e "\n-- TEAMS --"
#echo "$($PSQL "SELECT * FROM teams")"
#echo -e "\n-- GAMES --"
#echo "$($PSQL "SELECT * FROM games")"

#echo $CAT_CSV
