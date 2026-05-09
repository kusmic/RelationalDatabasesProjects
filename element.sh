#!/bin/bash

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

  if [[ $1 =~ ^[0-9]+$ ]]
  then
    EL_ID=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
  else
    EL_ID=$($PSQL "SELECT atomic_number FROM elements WHERE symbol ILIKE '$1' OR name ILIKE '$1'")
  fi 

  if [[ -z $EL_ID ]]
  then
    echo "I could not find that element in the database."
  else

    ELEMENT_DETAILS=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$EL_ID")

    # 5. Parse the result into variables
    echo "$ELEMENT_DETAILS" | while IFS="|" read AT_NUM SYM NAME TYPE MASS MELT BOIL
    do
      echo "The element with atomic number $AT_NUM is $NAME ($SYM). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done  
  fi
fi