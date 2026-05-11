#!/bin/bash
# Bob was here
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Fetch user data
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then
  echo "Welcome $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME',0,0)")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # Parse existing data
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate secret number 1-1000
SECRET=$(( ( RANDOM % 1000 ) + 1 ))
TRIES=0
GUESSED=false

echo "Guess the secret number between 1 and 1000:"

while [ "$GUESSED" = false ]
do
  read GUESS
  
  # 1. Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  TRIES=$(( $TRIES + 1 ))

  # 2. Check the guess
  if [[ $GUESS -eq $SECRET ]]
  then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
    GUESSED=true
  elif [[ $GUESS -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Update Database
NEW_GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
if [[ -z $BEST_GAME || $BEST_GAME -eq 0 || $TRIES -lt $BEST_GAME ]]
then
  UPDATE_RES=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$TRIES WHERE username='$USERNAME'")
else
  UPDATE_RES=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")
fi
