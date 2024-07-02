import 'package:love_letter_flutter/dialog/select_card_dialog.dart';
import 'package:love_letter_flutter/model/card.dart' as model;

import 'package:flutter/material.dart';
import 'package:love_letter_flutter/pages/app_bar.dart';

import '../dialog/select_player_dialog.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../orchestrator/orchestrator.dart';

class GamePage extends StatelessWidget {
  final List<Player> players;

  const GamePage(this.players, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "LoveLetter",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 35),
          ),
        ),
        home: Scaffold(
          appBar: const MyAppBar(),
          backgroundColor: Colors.amber,
          body: GameWidget(players),
        ));
  }
}

class GameWidget extends StatefulWidget {
  final List<Player> players;

  const GameWidget(this.players, {super.key});

  @override
  State<StatefulWidget> createState() => GameWidgetState(players);
}

class GameWidgetState extends State<GameWidget> {
  late Game game;
  late Orchestrator orchestrator;

  GameWidgetState(List<Player> players) {
    game = Game(players);
    orchestrator = Orchestrator(game, this);
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Column(
        children: [
          Column(children: buildPlayersWidget(currentWidth)),
          Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: buildCardsToPlay(currentWidth),
              )
          ),
          const SizedBox(height: 20)
        ],

      ),
    );
  }

  List<Widget> buildPlayersWidget(double currentWidth) {
    List<Widget> rowsToAdd = [];
    List<Widget> allPlayersWidgets = [];
    List<Widget> selectedPlayerCards = [];
    for (Player player in game.allActivePlayers) {
      MaterialColor color = player.isSelected ? Colors.green : Colors
          .deepPurple;
      Column playerColumn = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: color, size: currentWidth / 15),
          Text(player.name,
              style: TextStyle(color: color, fontSize: 10))
        ],
      );

      allPlayersWidgets.add(InkWell(
          onTap: () {
            setState(() {
              game.selectPlayer(player);
            });
          },
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.deepPurple.withAlpha(100),
          child: playerColumn
      ));

      // Create the row for to display the selected play cards
      if (player.isSelected) {
        for (model.Card card in player.playedCards) {
          selectedPlayerCards.add(Image(image: AssetImage(card.getImagePath()),
              width: currentWidth / 8));
          selectedPlayerCards.add(SizedBox(width: currentWidth / 20));
        }
      }
    }

    // Some space on top
    rowsToAdd.add(const SizedBox(height: 10));
    // Players
    rowsToAdd.add(Wrap(
        alignment: WrapAlignment.center,
        spacing: currentWidth / 25,
        children: allPlayersWidgets
    ));
    // Some space between the rows
    rowsToAdd.add(const SizedBox(height: 10));
    // Cards from selected player
    rowsToAdd.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: selectedPlayerCards
    ));
    return rowsToAdd;
  }

  Widget buildCardsToPlay(double currentWidth) {
    Wrap wrapRow = const Wrap();
    if (!game.gameEnded) {
      List<Widget> cardsToPlay = [];
      for (model.Card card in game
          .getCurrentPlayer()
          .cards) {
        Image imageCard = Image(
            image: AssetImage(card.getImagePath()),
            width: currentWidth / 3);
        cardsToPlay.add(InkWell(
          child: imageCard,
          onTap: () {
            setState(() {
              if (!card.isSelected) {
                game.getCurrentPlayer().selectCard(card);
              } else {
                orchestrator.playCard(card);
              }
            });
          },
        ));
      }

      wrapRow = Wrap(
        spacing: currentWidth / 7,
        alignment: WrapAlignment.center,
        children: cardsToPlay,
      );
    }
    return wrapRow;
  }

  void showImpossibleDialog(String errText) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              alignment: Alignment.center,
              title: const Text("Action Impossible !", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.deepPurple,
              actionsAlignment: MainAxisAlignment.center,
              content: Text(errText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, "OK"),
                    child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 20)))
              ],
            )
    );
  }

  void endGame() {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              alignment: Alignment.center,
              title: const Text("Fin de la partie !", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.deepPurple,
              actionsAlignment: MainAxisAlignment.center,
              content: Text("Vainqueur : ${game.getWinner().name}", style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, "OK"),
                    child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 20)))
              ],
            )
    );
  }

  void selectPlayerForCard(model.Card card) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => SelectPlayerWidget(game, card, orchestrator));
  }

  void playGuard(Player player) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SelectCardDialog(orchestrator, player, game));
  }

  void playPriest(Player player) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      title: Text("Cartes de ${player.name}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.deepPurple)),
      backgroundColor: Colors.amber,
      actionsAlignment: MainAxisAlignment.center,
      content: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        children: [Image(image: AssetImage(player.cards.first.getImagePath()))]
      ),
      alignment: Alignment.center,
      actions: [
        TextButton(
            onPressed: () {
              setState(() {
                Navigator.pop(context, "OK");
                orchestrator.endTurn();
              });
            },
            child: const Text("OK", style: TextStyle(color: Colors.deepPurple, fontSize: 20)))
      ],
    ));
  }
}

