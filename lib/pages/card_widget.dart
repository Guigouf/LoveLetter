import 'package:flutter/material.dart';
import 'package:love_letter_flutter/model/card.dart';

import '../model/game.dart';
import '../orchestrator/orchestrator.dart';

class CardWidget extends Container {

  final CardModel card;
  final double cardWidth;
  final Game game;
  final Orchestrator orchestrator;
  final Function onTap;

  CardWidget(this.card, this.cardWidth, this.game, this.orchestrator, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    Image imageCard = Image(image: AssetImage(card.getImagePath()), width: cardWidth);

    return Container(
      child: InkWell(
        child: imageCard,
        onTap: () => onTap(),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: card.isSelected ? Colors.green : Colors.transparent, width: 5)
      ),
    );

  }


}
