#!/bin/bash

PSQL="psql --username=freecodecamp --no-align --tuples-only --dbname=salon -c"

MAIN () {

  if [[ $1 ]]
  then
    echo $1
  else
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ [0-5] ]]
  then
    MAIN "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    INSERT_APPT=$($PSQL "INSERT INTO appointments (service_id,customer_id,time) VALUES ($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN