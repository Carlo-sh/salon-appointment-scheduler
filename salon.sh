#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  APPOINTMENT_MENU
  
}

APPOINTMENT_MENU() {
  read SERVICE_ID_SELECTED

  SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SELECTED_SERVICE ]]; then
    MAIN_MENU "I could not find that service. What would you like today?\n"
  else
    echo -e "What's your phone number?\n"
    read CUSTOMER_PHONE

    PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $PHONE ]]; then
      echo -e "I don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME
      echo -e "What time would you like your cut, Fabio?\n"
      read SERVICE_TIME

      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SELECTED_SERVICE")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")

      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME')")

      echo -e "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SELECTED_SERVICE")
      NAME=$($PSQL "SELECT name FROM customers WHERE phone = $PHONE")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$NAME'")

      echo -e "What time would you like your $SERVICE, $NAME?\n"
      read SERVICE_TIME

      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME')")

      echo -e "I have put you down for a $SERVICE at $SERVICE_TIME, $NAME."
    fi
  fi
}

MAIN_MENU
