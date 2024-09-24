############# chore: update bin/bash #####################
#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

########### Initial commit #####################
# echo 'Please provide an element as an argument.'

########### feat: add search functionality by atomic number #####################
SEARCH_BY_ATOMIC_NUMBER(){
  ATOMIC_NUMBER_RESULT=$($PSQL "
    SELECT * FROM elements
    JOIN properties ON elements.atomic_number = properties.atomic_number
    WHERE elements.atomic_number = $1;
  ")

  if [[ -z $ATOMIC_NUMBER_RESULT ]]
  then
    echo "I could not find that element in the database."
    exit
  fi

  DISPLAY_ATOMIC_DETAIL $ATOMIC_NUMBER_RESULT 
}

########### feat: add search functionality by atomic symbol #####################
SEARCH_BY_SYMBOL(){
  ATOMIC_NUMBER=$($PSQL "
    SELECT atomic_number FROM elements 
    WHERE symbol='$1';
  ")

  ########### feat: add search functionality by atomic name #####################
  if [[ -z $ATOMIC_NUMBER ]]
  then
    ATOMIC_NUMBER=$($PSQL "
      SELECT atomic_number FROM elements 
      WHERE name='$1';
    ")
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
    exit
  fi

  SEARCH_BY_ATOMIC_NUMBER $ATOMIC_NUMBER
}

########### feat: add to return atomic details #####################
DISPLAY_ATOMIC_DETAIL(){

  echo "$1" | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE_ID
  do
    TYPE=$($PSQL "
      SELECT type FROM types
      WHERE type_ID=$TYPE_ID
    ")
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  done
}

########### feat: implement argument type classification feature #####################

if [[ -z $1 ]]
then
  echo 'Please provide an element as an argument.'
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  SEARCH_BY_ATOMIC_NUMBER $1
else
  SEARCH_BY_SYMBOL $1
fi