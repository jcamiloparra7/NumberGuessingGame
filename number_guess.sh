#!/bin/bash

# database query boiler plate code
PSQL="psql -X --dbname number_guess --username freecodecamp --tuples-only -c"
# generate random number between 1 and 1000
RANDOM_NUMBER=$(( $(($RANDOM % 1000)) + 1 ))

echo "Enter your username:"
read USERNAME

# get user info for greetings
USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  # greetins message when new user and register new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_REGISTER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # greeting message when the user was already registered
  echo $USER_INFO | while read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# start game guessing logic
NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"

# infinite loop for number guessing logic
while [[  $INPUT_NUMBER != $RANDOM_NUMBER ]]
do
  read INPUT_NUMBER
  # increase try counter
  (( NUMBER_OF_GUESSES++ ))

  if [[ $INPUT_NUMBER =~ ^[0-9]+$ ]]
  then
    if [[ $INPUT_NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      if [[ $INPUT_NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

# update user info about games
UPDATE_NUMBER_GAMES=$($PSQL "UPDATE users SET games_played= games_played + 1 WHERE username='$USERNAME'")
UPDATE_MIN_TRIES=$($PSQL "UPDATE users SET best_game = LEAST(best_game, $NUMBER_OF_GUESSES)")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $INPUT_NUMBER. Nice job!"


