import 'package:love_letter_flutter/model/player.dart';

import '../pages/game_page.dart';
import '../model/card.dart';
import '../model/game.dart';

class Orchestrator {

  Game game;
  GameWidgetState widgetState;

  Orchestrator(this.game, this.widgetState) {
    game.start();
  }

  // Play card from the current player
  void playCard(Card card) {
    card.isSelected = false;
    // Reset handmaid played if any
    game.currentPlayer.handmaidPlayed = false;

    if (card.value == 9) {
      // Refuse to play the princess
      widgetState.showImpossibleDialog("La princesse ne peut pas être jouée. \n Il faut jouer l'autre carte.");

    } else if (_comtessShallBePlayed() && (card.value != 8)) {
      // Ask to play the comtess
      widgetState.showImpossibleDialog("Cette carte ne peut être jouée : La comtesse doit être jouée !!");
    } else { // Play the card
      game.getCurrentPlayer().playCard(card);
      switch(card.value) {
        case 0:
          game.currentPlayer.spyPlayed = true;
          endTurn();
          break;
        case 4:
          game.currentPlayer.handmaidPlayed = true;
          endTurn();
          break;
        case 8:
          endTurn();
        case 1:
        case 2:
        case 3:
        case 5:
        case 7:
          widgetState.selectPlayerForCard(card);
          break;
        case 6:
          widgetState.playChanceller();
          break;
      }
    }
  }

  bool _comtessShallBePlayed() {
    bool hasComtess = false;
    bool hasPrinceOrKing = false;
    for(Card card in game.currentPlayer.cards) {
      hasComtess |= (card.value == 8);
      hasPrinceOrKing |= ((card.value == 5) || card.value == 7);
    }
    return hasPrinceOrKing && hasComtess;
  }

  void endTurn() {
    if(!game.isOver()) {
      game.newTurn();
    } else {
      widgetState.endGame();
    }
  }

  void playerSelected(Player selectedPlayer, Card playedCard) {
    switch(playedCard.value) {
      case 1:
        widgetState.playGuard(selectedPlayer);
        break;
      case 2:
        widgetState.playPriest(selectedPlayer);
        break;
      case 3:
        widgetState.playBaron(selectedPlayer);
        break;
      case 5:
        widgetState.playPrince(selectedPlayer);
        break;
      case 7:
        widgetState.playKing(selectedPlayer);
        break;
    }
  }

  cardGuessed(Player targetPlayer, bool isCardGuessRight) {
    widgetState.setState(() {
      if (isCardGuessRight) {
        game.removePlayer(targetPlayer);
      }
      endTurn();
    });
  }

  void startTurn() {
    widgetState.setState(() {
      game.startTurn();
    });
  }

  void removePlayer(Player playerToRemove) {
    game.removePlayer(playerToRemove);
    endTurn();
  }

  void endTurnOnState() {
    widgetState.setState(() {
      endTurn();
    });
  }
}