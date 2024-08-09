import 'dart:ui';

import 'package:flutter/material.dart';

import '../model/card.dart' as model;
import '../model/game.dart';
import '../orchestrator/orchestrator.dart';

class ChancellerDialog extends StatefulWidget {
  final Orchestrator orchestrator;
  final Game game;
  final List<model.Card> cards = [];

  ChancellerDialog(this.orchestrator, this.game, {super.key}) {
    // Retrieve the player cards
    cards.add(game.currentPlayer.cards.removeAt(0));
    // Retrieve the last 2 cards of the deck
    game.deck.isNotEmpty ? cards.add(game.deck.removeLast()) : null;
    game.deck.isNotEmpty ? cards.add(game.deck.removeLast()) : null;
  }

  @override
  State<StatefulWidget> createState() => ChancellerDialogState();
}

class ChancellerDialogState extends State<ChancellerDialog> {

  ChancellerActionState state = ChancellerActionState.keepCard;

  @override
  Widget build(BuildContext context) {
    Size currentSize = MediaQuery.of(context).size;
    String title = "";
    switch (state) {
      case ChancellerActionState.keepCard:
        title = "Sélectionner la carte à garder";
        break;
      case ChancellerActionState.endDeckCard:
        title = "Sélectionner la carte à mettre au bas du paquet";
        break;
    }
    return Dialog(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: currentSize.height / 30,
          children: [
            SizedBox(height: currentSize.height / 100),
            Text(title,
                style: const TextStyle(color: Colors.deepPurple, fontSize: 15, fontWeight: FontWeight.bold)),
            Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                spacing: currentSize.height / 50,
                children: _buildCardWidgets(currentSize)
            ),
            SizedBox(height: currentSize.height / 100)
          ],
        ));
  }

  List<Widget> _buildCardWidgets(Size currentSize) {
    double currentWidth = currentSize.width;
    List<Widget> cardWidgets = [];
    // Space at the left of the cards
    cardWidgets.add(SizedBox(width: currentSize.height / 60));
    double sizeFactor = 3 / widget.cards.length;
    for (model.Card card in widget.cards) {
      double cardWidth = sizeFactor * (card.isSelected ? currentWidth / 4.9 : currentWidth / 5);
      Widget cardWidget = InkWell(
        child: Image(
            image: AssetImage(card.getImagePath()),
            width: cardWidth
        ),
        onTap: () {
          setState(() {
            if (!card.isSelected) {
              for (model.Card card in widget.cards) {
                card.isSelected = false;
              }
              card.isSelected = true;

            } else {
              _cardSelected(card);
            }
          });
        },
      );
      cardWidgets.add(cardWidget);
    }
    // Space at the right of the cards
    cardWidgets.add(SizedBox(width: currentSize.height / 60));
    return cardWidgets;
  }

  void _cardSelected(model.Card card) {
    // Unselect the card
    card.isSelected = false;
    switch (state) {
      case ChancellerActionState.keepCard:
        widget.cards.remove(card);
        widget.game.currentPlayer.cards.add(card);

        if (widget.cards.isNotEmpty) {
          state = ChancellerActionState.endDeckCard;
        } else { // if there was no card on the deck
          Navigator.pop(context, "OK");
          widget.orchestrator.endTurnOnState();
        }
        break;

      case ChancellerActionState.endDeckCard:
        // The card selected is the one to put last
        widget.cards.remove(card);
        if (widget.cards.isNotEmpty) { // 1 card remains
          final model.Card otherCard = widget.cards.first;
          widget.game.deck.add(otherCard);
        }
        // Add the selected card at last position
        widget.game.deck.add(card);
        Navigator.pop(context, "OK");
        widget.orchestrator.endTurnOnState();
        break;
    }

  }
}



enum ChancellerActionState {
  keepCard, endDeckCard;
}
