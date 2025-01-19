#!/bin/bash

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Identify if the input is a number or a string
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $1"
else
  CONDITION="e.symbol = '$1' OR e.name = '$1'"
fi

# Query the database
ELEMENT_INFO=$(psql -U postgres -d periodic_table -t -c "
  SELECT 
    e.atomic_number, e.symbol, e.name, 
    p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, 
    t.type
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE $CONDITION;
")

if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the output and format it correctly
while IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME MASS MELTING BOILING TYPE; do
  # Remove leading/trailing whitespace
  ATOMIC_NUMBER=$(echo "$ATOMIC_NUMBER" | xargs)
  SYMBOL=$(echo "$SYMBOL" | xargs)
  NAME=$(echo "$NAME" | xargs)
  MASS=$(echo "$MASS" | xargs)
  MELTING=$(echo "$MELTING" | xargs)
  BOILING=$(echo "$BOILING" | xargs)
  TYPE=$(echo "$TYPE" | xargs)
  
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
done <<< "$ELEMENT_INFO"
