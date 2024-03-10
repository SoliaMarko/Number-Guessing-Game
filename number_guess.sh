#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

MAIN_MENU () {

  # generate number

  SECRET_NUMBER=$(( RANDOM % 1000 + 1)) 

  # get  user

  echo "Enter your username:"

  read USERNAME

  USERDATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

  # welcome user

  if [[ -z $USERDATA ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"

    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME');")

  else 
    IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USERDATA"

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
  fi

  # get guessing number 

  echo "Guess the secret number between 1 and 1000:"
  read INPUT_NUMBER
  NUMBER_OF_GUESSES=1

  while [[ $INPUT_NUMBER != $SECRET_NUMBER ]]
  do
    # if not a number
    if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
    # if secret is lower
    elif (( $SECRET_NUMBER < $INPUT_NUMBER  ))
    then
      echo -e "\nIt's lower than that, guess again:"
    # if secret is higher
    elif (( $SECRET_NUMBER > $INPUT_NUMBER ))
    then
      echo -e "\nIt's higher than that, guess again:"
    fi

    read INPUT_NUMBER
    (( NUMBER_OF_GUESSES++ ))
  done

  # when guessed
  # update DB

  # increment games played
  INCREMENT_GAMES_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")

  # define best_game

  if (( BEST_GAME > NUMBER_OF_GUESSES || BEST_GAME == 0 ))
  then
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
  fi

  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}


MAIN_MENU