
import 'package:flutter/material.dart';
import 'package:love_letter_flutter/pages/app_style.dart';
import 'package:love_letter_flutter/pages/card_widget.dart';

import '../model/card.dart' as model;
import '../model/game.dart';
import '../orchestrator/orchestrator.dart';

class ChancellerDialog extends StatefulWidget {
  final Orchestrator orchestrator;
  final Game game;
  final List<model.CardModel> cards = [];

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
      case ChancellerActionState.keepCardToConfirm:
        title = "Sélectionner la carte \nà garder";
        break;
      case ChancellerActionState.endDeckCard:
      case ChancellerActionState.endDeckCardToConfirm:
        title = "Sélectionner la carte \nà mettre au bas du paquet";
        break;
    }
    return Dialog(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column (
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(height: currentSize.height / 50), // Apply the spacing on top
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: currentSize.height / 30),
            Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                spacing: currentSize.height / 50,
                children: _buildCardWidgets(currentSize)
            ),
            AppStyle.createConfirmText(_isStateConfirm())
          ],
        ));
  }

  List<Widget> _buildCardWidgets(Size currentSize) {
    double currentWidth = currentSize.width;
    List<Widget> cardWidgets = [];
    // Space at the left of the cards
    cardWidgets.add(SizedBox());
    double sizeFactor = 3 / widget.cards.length;
    for (model.CardModel card in widget.cards) {
      double cardWidth = sizeFactor * (card.isSelected ? currentWidth / 4.9 : currentWidth / 5);
      CardWidget cardWidget = CardWidget(card, cardWidth, widget.game, widget.orchestrator, () {
        setState(() {
          if (!card.isSelected) {
            for (model.CardModel card in widget.cards) {
              card.isSelected = false;
            }
            card.isSelected = true;
            _confirmState();

          } else {
            _cardSelected(card);
          }
        });
      });
      cardWidgets.add(cardWidget);
    }
    // Space at the right of the cards
    cardWidgets.add(SizedBox());
    return cardWidgets;
  }

  void _cardSelected(model.CardModel card) {
    // Unselect the card
    card.isSelected = false;
    switch (state) {
      case ChancellerActionState.keepCardToConfirm:
        widget.cards.remove(card);
        widget.game.currentPlayer.cards.add(card);

        if (widget.cards.isNotEmpty) {
          state = ChancellerActionState.endDeckCard;
        } else { // if there was no card on the deck
          Navigator.pop(context, "OK");
          widget.orchestrator.endTurnOnState();
        }
        break;

      case ChancellerActionState.endDeckCardToConfirm:
        // The card selected is the one to put last
        widget.cards.remove(card);
        if (widget.cards.isNotEmpty) { // 1 card remains
          final model.CardModel otherCard = widget.cards.first;
          widget.game.deck.add(otherCard);
        }
        // Add the selected card at last position
        widget.game.deck.add(card);
        Navigator.pop(context, "OK");
        widget.orchestrator.endTurnOnState();
        break;
      default: // keepCard and endDeckCard are not processed here
        break;
    }

  }

  void _confirmState() {
    if (state == ChancellerActionState.keepCard) {
      state = ChancellerActionState.keepCardToConfirm;
    } else if (state == ChancellerActionState.endDeckCard) {
      state = ChancellerActionState.endDeckCardToConfirm;
    }
  }

  bool _isStateConfirm() {
    return state == ChancellerActionState.keepCardToConfirm || state == ChancellerActionState.endDeckCardToConfirm;
  }
}



enum ChancellerActionState {
  keepCard, keepCardToConfirm, endDeckCard, endDeckCardToConfirm;
}
