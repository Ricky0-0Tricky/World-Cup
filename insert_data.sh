#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Limpeza das Tabelas
echo $($PSQL "TRUNCATE teams, games")

# Inicializar um array para as equipas
Team_Collection=()

# Leitura do ficheiro CSV linha a linha
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip do header
  if [[ $YEAR == "year" && $ROUND == "round" && $WINNER == "winner" && $OPPONENT == "opponent" && $WINNER_GOALS == "winner_goals" && $OPPONENT_GOALS == "opponent_goals" ]]; then
    continue
  fi

  # Check se o WINNER está ou não no array e não se trata do header
  if [[ ! " ${Team_Collection[@]} " =~ " ${WINNER} " ]]; then
    Team_Collection+=("$WINNER")
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    
    # Caso em que o WINNER foi inserido com sucesso
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]; then
      echo "Vencedor inserido: $WINNER"
    fi

    # Captura do ID da equipa vencedora
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  else
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  fi

  # Check se o OPPONENT está ou não no array e não se trata do header
  if [[ ! " ${Team_Collection[@]} " =~ " ${OPPONENT} " ]]; then
    Team_Collection+=("$OPPONENT")
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    
    # Caso em que o OPPONENT foi inserido com sucesso
    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]; then
      echo "Oponente inserido: $OPPONENT"
    fi
    
    # Captura do ID da equipa adversaria
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  else
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  fi

  # Inserção dos jogos na tabela "games"
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
  
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
    echo "O jogo foi adicionado com sucesso!"
  fi
done