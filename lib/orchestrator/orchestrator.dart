import 'package:flutter/cupertino.dart';
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
          // TODO
          widgetState.selectPlayerForCard(card);
          break;
        case 6:
          // TODO
          endTurn();
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
      // TODO
      widgetState.endGame();
    }
  }

  void playerSelected(Player player, Card playedCard) {
    switch(playedCard.value) {
      case 1:
        widgetState.playGuard(player);
        break;
      case 2:
        // TODO
        widgetState.playPriest(player);
        break;
      case 3:
        // TODO
        widgetState.setState(() {
          endTurn();
        });
        break;
      case 5:
        // TODO
        widgetState.setState(() {
          endTurn();
        });
        break;
      case 7:
        // TODO
        widgetState.setState(() {
          endTurn();
        });
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
}