#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  echo -e "\n~ Welcome to the Salon. ~\n"
  # get list of services
  SERVICE_LIST=$($PSQL "select service_id,name from services order by service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID PIPE SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  # Choose a service
  echo -e "\nPlease choose a service:"
  read SERVICE_ID_SELECTED
  SELECTED_SERVICE=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SELECTED_SERVICE ]]
    then
      echo "That service is not available. Please try again."
      MAIN_MENU
    else 
      # get customer
      echo -e "\nPlease enter your phone number:"
      read CUSTOMER_PHONE

      # check if customer exists
      CHECK_CUSTOMER_PHONE=$($PSQL "select phone from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CHECK_CUSTOMER_PHONE ]]
      then
        # create a new customer
        echo -e "\nPlease enter your name:"
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi

      echo -e "\nPlease enter service time:"
      read SERVICE_TIME
      
      # add appointment
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SELECTED_SERVICE,'$SERVICE_TIME')")

      # check for appt
      if [[ $INSERT_APPOINTMENT ]]
      then
        SERVICE=$($PSQL "select name from services where service_id=$SELECTED_SERVICE")
        CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")
        echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      else
        echo "There was an error booking your appointment."
      fi      
  fi
}

MAIN_MENU
