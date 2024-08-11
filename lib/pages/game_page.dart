import 'package:flutter/material.dart';
import 'package:love_letter_flutter/dialog/select_card_dialog.dart';
import 'package:love_letter_flutter/model/card.dart' as model;
import 'package:love_letter_flutter/pages/app_bar.dart';
import 'package:love_letter_flutter/pages/app_style.dart';

import '../dialog/chanceller_dialog.dart';
import '../dialog/select_player_dialog.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../orchestrator/orchestrator.dart';

class GamePage extends StatelessWidget {
  final List<Player> players = [];

  GamePage(List<Player> newPlayers, {super.key}) {
    // Copy the players list
    for (final Player player in newPlayers) {
      players.add(Player(player.name));
    }
  }

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
    // Display the new turn to confirm dialog if the new turn has just been announced
    if (game.state == GameState.newTurnToConfirm) {
      return Dialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Nouveau tour",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text(game.currentPlayer.name,
                  style: const TextStyle(fontSize: 30, color: Colors.white)),
              const SizedBox(height: 30),
              AppStyle.createOkButton(() => orchestrator.startTurn()),
              const SizedBox(height: 20)
            ],
          ));
    } else {
      return Scaffold(
        backgroundColor: Colors.amber,
        body: Column(
          children: [
            Column(children: buildPlayersWidget(currentWidth)),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: buildCardsToPlay(currentWidth),
            )),
            const SizedBox(height: 20)
          ],
        ),
      );
    }
  }

  List<Widget> buildPlayersWidget(double currentWidth) {
    List<Widget> rowsToAdd = [];
    List<Widget> allPlayersWidgets = [];
    List<Widget> selectedPlayerCards = [];
    for (Player player in game.allActivePlayers) {
      MaterialColor color = player.isSelected ? Colors.green : Colors.deepPurple;
      Column playerColumn = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: color, size: currentWidth / 15),
          Text(player.name, style: TextStyle(color: color, fontSize: 10))
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
          child: playerColumn));

      // Create the row for to display the selected play cards
      if (player.isSelected) {
        for (model.Card card in player.playedCards) {
          selectedPlayerCards
              .add(Image(image: AssetImage(card.getImagePath()), width: currentWidth / 8));
          selectedPlayerCards.add(SizedBox(width: currentWidth / 20));
        }
      }
    }

    // Some space on top
    rowsToAdd.add(const SizedBox(height: 10));
    // Players
    rowsToAdd.add(Wrap(
        alignment: WrapAlignment.center, spacing: currentWidth / 25, children: allPlayersWidgets));
    // Some space between the rows
    rowsToAdd.add(const SizedBox(height: 10));
    // Cards from selected player
    rowsToAdd.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: selectedPlayerCards));
    return rowsToAdd;
  }

  Widget buildCardsToPlay(double currentWidth) {
    Wrap wrapRow = const Wrap();
    if (!game.gameEnded) {
      List<Widget> cardsToPlay = [];
      for (model.Card card in game.getCurrentPlayer().cards) {
        double cardWidth = card.isSelected ? currentWidth / 2.9 : currentWidth / 3;
        Image imageCard = Image(image: AssetImage(card.getImagePath()), width: cardWidth);
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
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              alignment: Alignment.center,
              title: const Text("Action Impossible !", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.deepPurple,
              actionsAlignment: MainAxisAlignment.center,
              content: Text(errText,
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              actions: [AppStyle.createOkButton(() => Navigator.pop(context, "OK"))],
            ));
  }

  void endGame() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              alignment: Alignment.center,
              title: const Text("Fin de la partie !", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.deepPurple,
              actionsAlignment: MainAxisAlignment.center,
              content: Text("Vainqueur : ${game.getWinner().name}",
                  style: const TextStyle(color: Colors.white)),
              actions: [
                AppStyle.createOkButton(() {
                  // Close the AlertDialog
                  Navigator.pop(context, "OK");
                  // Close the game and go back to the home page
                  Navigator.pop(context);
                })
              ],
            ));
  }

  void selectPlayerForCard(model.Card card) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SelectPlayerWidget(game, card, orchestrator));
  }

  void playGuard(Player player) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SelectCardDialog(orchestrator, player, game));
  }

  void playPriest(Player player) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text("Carte de ${player.name}",
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.deepPurple)),
              backgroundColor: Colors.amber,
              actionsAlignment: MainAxisAlignment.center,
              content: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: [Image(image: AssetImage(player.cards.first.getImagePath()))]),
              alignment: Alignment.center,
              actions: [
                AppStyle.createOkButton(() {
                  setState(() {
                    Navigator.pop(context, "OK");
                    orchestrator.endTurn();
                  });
                })
              ],
            ));
  }

  void playBaron(Player selectedPlayer) {
    final model.Card currentPlayerCard = game.currentPlayer.cards.first;
    final model.Card selectedPlayerCard = selectedPlayer.cards.first;
    String title = "";
    String description = "";
    Player loser = Player.nobody;
    if (currentPlayerCard.value > selectedPlayerCard.value) {
      title = "VICTOIRE";
      loser = selectedPlayer;
      description = "${selectedPlayer.name} est éliminé !";
    } else if (currentPlayerCard.value < selectedPlayerCard.value) {
      title = "DEFAITE";
      loser = game.currentPlayer;
      description = "${game.currentPlayer.name} est éliminé !";
    } else {
      title = "EGALITE";
      description = "Personne n'est éliminé !";
    }
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: size.height / 30,
                // Vertical spacing
                children: [
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.deepPurple, fontSize: 30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ColumnPlayerCard(game.currentPlayer, size),
                      SizedBox(width: size.width / 10),
                      _ColumnPlayerCard(selectedPlayer, size)
                    ],
                  ),
                  Column(children: [
                    Text(description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.deepPurple, fontSize: 20)),
                    AppStyle.createOkButton(() {
                      Navigator.pop(context, "OK");
                      setState(() {
                        // Remove the player only if no draw
                        if (loser != Player.nobody) {
                          orchestrator.removePlayer(loser);
                        } else {
                          orchestrator.endTurn();
                        }
                      });
                    })
                  ])
                ])));
  }

  void playPrince(Player selectedPlayer) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text("Carte défaussée par ${selectedPlayer.name}",
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.deepPurple)),
              backgroundColor: Colors.amber,
              actionsAlignment: MainAxisAlignment.center,
              content: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: [Image(image: AssetImage(selectedPlayer.cards.first.getImagePath()))]),
              alignment: Alignment.center,
              actions: [
                AppStyle.createOkButton(() {
                  setState(() {
                    Navigator.pop(context, "OK");
                    game.discardCard(selectedPlayer);
                    orchestrator.endTurn();
                  });
                })
              ],
            ));
  }

  void playKing(Player selectedPlayer) {
    // Switch the cards
    final model.Card currentPlayerCard = game.currentPlayer.cards.removeAt(0);
    final model.Card selectedPlayerCard = selectedPlayer.cards.removeAt(0);

    game.currentPlayer.cards.add(selectedPlayerCard);
    selectedPlayer.cards.add(currentPlayerCard);
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: size.height / 30,
                // Vertical spacing
                children: [
                  const Text("Nouvelles cartes",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.deepPurple, fontSize: 30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ColumnPlayerCard(game.currentPlayer, size),
                      SizedBox(width: size.width / 10),
                      _ColumnPlayerCard(selectedPlayer, size)
                    ],
                  ),
                  AppStyle.createOkButton(() {
                    Navigator.pop(context, "OK");
                    setState(() {
                      orchestrator.endTurn();
                    });
                  })
                ])));
  }

  void playChanceller() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChancellerDialog(orchestrator, game)
    );
  }
}

class _ColumnPlayerCard extends StatelessWidget {

  final Player player;
  final Size screenSize;

  const _ColumnPlayerCard(this.player, this.screenSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(player.name,
            style: const TextStyle(color: Colors.deepPurple, fontSize: 15)),
        SizedBox(height: screenSize.height / 50),
        Image(
            image: AssetImage(player.cards.first.getImagePath()),
            width: screenSize.width / 3)
      ],
    );
  }


}
