import 'dart:math';

import 'package:love_letter_flutter/model/player.dart';

import 'card.dart';

class Game {
  List<Player> allPlayers;
  late List<Player> allActivePlayers;
  List<Card> deck = [];
  late Card removedCard;
  late Player currentPlayer;
  bool gameEnded = false;
  GameState state = GameState.gameStarted;

  Game(this.allPlayers);

  void start() {
    allActivePlayers = allPlayers;

    // In case a backward to home page has been done
    _cleanPlayers();

    //_initializeDeck();

    //For debug
    _initializeDeckDebug();

    _cardDistribution();

    // First turn
    currentPlayer = allActivePlayers.first;
    currentPlayer.addCard(deck.removeAt(0));

    state = GameState.newTurnToConfirm;
  }

  void _initializeDeck() {
    // 2 Espionnes
    deck.add(Card.ofCardEnum(CardEnum.spy));
    deck.add(Card.ofCardEnum(CardEnum.spy));
    // 6 Gardes
    deck.add(Card.ofCardEnum(CardEnum.guard));
    deck.add(Card.ofCardEnum(CardEnum.guard));
    deck.add(Card.ofCardEnum(CardEnum.guard));
    deck.add(Card.ofCardEnum(CardEnum.guard));
    deck.add(Card.ofCardEnum(CardEnum.guard));
    deck.add(Card.ofCardEnum(CardEnum.guard));
    // 2 Pretres
    deck.add(Card.ofCardEnum(CardEnum.priest));
    deck.add(Card.ofCardEnum(CardEnum.priest));
    // 2 Barons
    deck.add(Card.ofCardEnum(CardEnum.baron));
    deck.add(Card.ofCardEnum(CardEnum.baron));
    // 2 Servantes
    deck.add(Card.ofCardEnum(CardEnum.handmaid));
    deck.add(Card.ofCardEnum(CardEnum.handmaid));
    // 2 Princes
    deck.add(Card.ofCardEnum(CardEnum.prince));
    deck.add(Card.ofCardEnum(CardEnum.prince));
    // 2 Chanceliers
    deck.add(Card.ofCardEnum(CardEnum.chanceller));
    deck.add(Card.ofCardEnum(CardEnum.chanceller));
    // 1 Roi
    deck.add(Card.ofCardEnum(CardEnum.king));
    // 1 Comtesse
    deck.add(Card.ofCardEnum(CardEnum.comtess));
    //1 Princesse
    deck.add(Card.ofCardEnum(CardEnum.princess));

    // Shuffle
    for (int round = 0; round < 200; round++) {
      int position = Random().nextInt(deck.length);
      Card removedCard = deck.elementAt(position);
      deck.removeAt(position);
      deck.add(removedCard);
    }

    // Remove 1 card (the first one)
    removedCard = deck.first;
  }

  void _initializeDeckDebug() {
    deck.add(Card.ofCardEnum(CardEnum.chanceller));
    deck.add(Card.ofCardEnum(CardEnum.chanceller));
    deck.add(Card.ofCardEnum(CardEnum.guard));
    deck.add(Card.ofCardEnum(CardEnum.priest));
    deck.add(Card.ofCardEnum(CardEnum.baron));
    deck.add(Card.ofCardEnum(CardEnum.handmaid));
    deck.add(Card.ofCardEnum(CardEnum.princess));
  }

  void _cardDistribution() {
    for (Player player in allActivePlayers) {
      player.addCard(deck.removeAt(0));
    }
  }

  void newTurn() {
    // If current player is still alive
    if (currentPlayer == allActivePlayers[0]) {
      allActivePlayers.removeAt(0);
      allActivePlayers.add(currentPlayer);

    }
    currentPlayer = allActivePlayers.first;
    currentPlayer.addCard(deck.removeAt(0));
    state = GameState.newTurnToConfirm;
  }

  void startTurn() {
    state = GameState.newTurnToPlay;
  }

  Player getCurrentPlayer() {
    return currentPlayer;
  }

  void selectPlayer(Player player) {
    bool wasSelected = player.isSelected;
    for (Player player in allActivePlayers) {
      player.isSelected = false;
    }
    // Only select if not already selected.
    // If already selected, the selection will just be cancelled.
    if (!wasSelected) {
      player.isSelected = !player.isSelected;
    }
  }

  /// Retrieve all the selectable players :
  /// - Not if has played a handmaid
  /// - Not the current player
  List<Player> getSelectablePlayers() {
    List<Player> selectablePlayers = [];
    selectablePlayers.addAll(allActivePlayers);
    for (Player player in allActivePlayers) {
      if (player == currentPlayer || player.handmaidPlayed) {
        selectablePlayers.remove(player);
      }
    }
    return selectablePlayers;
  }

  bool isOver() {
    bool isOver = deck.isEmpty || allActivePlayers.length == 1;
    gameEnded = isOver;
    return isOver;
  }

  Player getWinner() {
    // The only one player remaining if alone
    Player winner = allActivePlayers[0];
    // Else the player with the greatest card
    if (allActivePlayers.length > 1) {
      for (int i = 1; i < allActivePlayers.length; i++) {
        Player player = allActivePlayers[i];
        if (player.cards[0].value > winner.cards[0].value) {
          winner = player;
        }
      }
    }
    return winner;
  }

  bool isCardGuessedRight(Card card, Player targetPlayer) {
    return card.value == targetPlayer.cards.first.value;
  }

  void removePlayer(Player targetPlayer) {
    allActivePlayers.remove(targetPlayer);
  }

  void _cleanPlayers() {
    for (Player player in allActivePlayers) {
      player.reset();
    }
  }

  void discardCard(Player selectedPlayer) {
    selectedPlayer.playCard(selectedPlayer.cards.first);
    if (deck.isNotEmpty) {
      selectedPlayer.cards.add(deck.removeAt(0));
    }
  }
}

enum GameState {
  gameStarted, newTurnToConfirm, newTurnToPlay, gameEnded
}
