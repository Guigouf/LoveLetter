import 'package:flutter/material.dart';

import '../model/card.dart' as model;
import '../model/card.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../orchestrator/orchestrator.dart';
import '../pages/app_style.dart';

class SelectCardDialog extends StatefulWidget {

  final Orchestrator orchestrator;
  final Player targetPlayer;
  final Game game;
  final List<model.Card> cards = [];

  SelectCardDialog(this.orchestrator, this.targetPlayer, this.game, {super.key}) {
    cards.add(model.Card.ofCardEnum(CardEnum.spy));
    cards.add(model.Card.ofCardEnum(CardEnum.priest));
    cards.add(model.Card.ofCardEnum(CardEnum.baron));
    cards.add(model.Card.ofCardEnum(CardEnum.handmaid));
    cards.add(model.Card.ofCardEnum(CardEnum.prince));
    cards.add(model.Card.ofCardEnum(CardEnum.chanceller));
    cards.add(model.Card.ofCardEnum(CardEnum.king));
    cards.add(model.Card.ofCardEnum(CardEnum.comtess));
    cards.add(model.Card.ofCardEnum(CardEnum.princess));
  }



  @override
  State<StatefulWidget> createState() => SelectCardDialogState();
}

class SelectCardDialogState extends State<SelectCardDialog> {

  String selectedCard = "";

  @override
  Widget build(BuildContext context) {
    Size currentSize = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.amber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 20,
        children: [
          const Text("Selectionner une carte", style: TextStyle(color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold)),
          Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.vertical,
              spacing: 10,
              children: buildCardWidgets(currentSize.width)
          ),
          Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.vertical,
            spacing: 5,
            children: buildTextSelection()
          )
        ],
      ),
    );
  }

  List<Widget> buildCardWidgets(double currentWidth) {
    List<Widget> cardRows = [];

    for(int i = 0 ; i <= 6; i+=3) {
      List<Widget> rowWidgets = [];
      // Add space on the left
      rowWidgets.add(const SizedBox(width: 5));

      for(int j = 0; j <= 2; j++) {
        model.Card card = widget.cards[i + j];
        double cardWidth = card.isSelected ? currentWidth / 4.9 : currentWidth / 5;
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
                selectedCard = card.name;
              } else {
                Navigator.pop(context);
                bool isCardGuessRight = widget.game.isCardGuessedRight(
                    card, widget.targetPlayer);
                String title = "";
                String content = "";

                if (isCardGuessRight) {
                  title = "Bon choix !";
                  content =
                  "Le joueur ${widget.targetPlayer.name} a bien la carte ${card
                      .name} ! \n${widget.targetPlayer.name} est éliminé(e) !";
                } else {
                  title = "Mauvais choix !";
                  content =
                  "Le joueur ${widget.targetPlayer.name} n'a pas la carte ${card
                      .name} ! \n${widget.targetPlayer.name} reste en jeu !";
                }

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: Text(title, style: const TextStyle(
                            color: Colors.white)),
                        backgroundColor: Colors.deepPurple,
                        actionsAlignment: MainAxisAlignment.center,
                        content: Text(content, style: const TextStyle(
                            color: Colors.white)),
                        actions: [
                          AppStyle.createOkButton(() {
                          Navigator.pop(context, "OK");
                          widget.orchestrator.cardGuessed(widget.targetPlayer, isCardGuessRight);
                          })
                        ],
                      )
                );
              }
            });
          },
        );
        rowWidgets.add(cardWidget);
      }
      // Add space on the right
      rowWidgets.add(const SizedBox(width: 5));

      cardRows.add(Wrap(
        alignment: WrapAlignment.center,
        spacing: 5,
        children: rowWidgets));
    }
    // Add space on the bottum
    cardRows.add(const SizedBox(height: 5));
    return cardRows;
  }

  List<Widget> buildTextSelection() {
    List<Widget> texts = [];
    final String selectedCardName = selectedCard != "" ? selectedCard : "----";

    texts.add(Text("Carte sélectionnée : \n$selectedCardName",
        style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
        textAlign: TextAlign.center
    ));
    if (selectedCard != "") {
      texts.add(const Text("Touchez à nouveau pour confirmer",
          style: TextStyle(color: Colors.deepPurple,
              fontSize: 12,
              fontStyle: FontStyle.italic),
          textAlign: TextAlign.center
      ));
    } else {
      texts.add(const Text("",
          style: TextStyle(color: Colors.deepPurple,
              fontSize: 12,
              fontStyle: FontStyle.italic),
          textAlign: TextAlign.center
      ));
    }

    return texts;
  }
}
