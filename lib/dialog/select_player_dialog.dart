import 'package:flutter/material.dart';
import 'package:love_letter_flutter/orchestrator/orchestrator.dart';

import '../model/card.dart' as model;
import '../model/game.dart';
import '../model/player.dart';
import '../pages/app_style.dart';

class SelectPlayerWidget extends StatefulWidget {
  final model.Card playedCard;
  final Orchestrator orchestrator;
  final List<PlayerToSelect> selectablePlayers = [];

  SelectPlayerWidget(Game game, this.playedCard, this.orchestrator, {super.key}) {
    for (Player player in game.getSelectablePlayers()) {
      selectablePlayers.add(PlayerToSelect(player));
    }
  }

  @override
  State<StatefulWidget> createState() => SelectPlayerWidgetState();
}

class SelectPlayerWidgetState extends State<SelectPlayerWidget> {
  bool playerSelected = false;

  @override
  Widget build(BuildContext context) {
    Size currentSize = MediaQuery.of(context).size;

    // Only display a message if there is no selectable player
    if (widget.selectablePlayers.isNotEmpty) {
      return Dialog(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 10,
          children: [
            const Text("Selectionner un joueur",
                style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
            Wrap(
                alignment: WrapAlignment.center,
                spacing: currentSize.width / 25,
                children: buildPlayersSelection(currentSize.width)),
            AppStyle.createConfirmText(playerSelected)
          ],
        ),
      );
    } else {
      return AlertDialog(
        alignment: Alignment.center,
        title: const Text("Aucun joueur à sélectionner !", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actionsAlignment: MainAxisAlignment.center,
        content: const Text("Cette carte est donc défaussée sans effet...",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        actions: [
          AppStyle.createOkButton(() {
            Navigator.pop(context, "OK");
            widget.orchestrator.endTurnOnState();
          })
        ],
      );
    }
  }

  List<Widget> buildPlayersSelection(final double currentWidth) {
    List<Widget> allPlayersWidgets = [];
    for (PlayerToSelect playerToSelect in widget.selectablePlayers) {
      MaterialColor color = playerToSelect.isSelected ? Colors.green : Colors.deepPurple;
      Column playerColumn = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: color, size: currentWidth / 15),
          Text(playerToSelect.player.name, style: TextStyle(color: color, fontSize: 10)),
          const SizedBox(height: 10)
        ],
      );

      allPlayersWidgets.add(InkWell(
          onTap: () {
            setState(() {
              if (!playerToSelect.isSelected) {
                for (PlayerToSelect player in widget.selectablePlayers) {
                  player.isSelected = false;
                }
                playerToSelect.isSelected = true;
                playerSelected = true;
              } else {
                playerSelected = false;
                Navigator.pop(context);
                widget.orchestrator.playerSelected(playerToSelect.player, widget.playedCard);
              }
            });
          },
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.deepPurple.withAlpha(100),
          child: playerColumn));
    }
    return allPlayersWidgets;
  }
}

class PlayerToSelect {
  final Player player;
  bool isSelected = false;

  PlayerToSelect(this.player);
}
