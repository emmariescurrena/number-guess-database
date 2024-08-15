#!/bin/bash

PSQL="psql \
    --username=freecodecamp \
    --dbname=number_guess \
    -t \
    --no-align \
    --field-separator ' ' \
    --quiet \
    -c" \

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where name = '$USERNAME'")

if [ $USER_ID ] ; then
  GAMES_PLAYED=$($PSQL "select count(guesses) from games where user_id = $USER_ID")
  BEST_GAME=$($PSQL "select min(guesses) from games where user_id = '$USER_ID'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $($PSQL "insert into users(name) values('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where name = '$USERNAME'")
fi

SECRET_NUMBER=$((1 + $RANDOM % 1000))
TRIES=0
echo "Guess the secret number between 1 and 1000:"
while : ; do {
  read USER_GUESS

  if ! [[ $USER_GUESS =~ ^[0-9]+$ ]] ; then
    echo "That is not an integer, guess again:"
  else
  ((TRIES+=1))
  if [[ $USER_GUESS -eq $SECRET_NUMBER ]]; then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    $($PSQL "insert into games(user_id, guesses) values ($USER_ID, $TRIES)")
    exit
  elif [[ $USER_GUESS -gt $SECRET_NUMBER ]] ; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  fi  
} done
