import 'package:flutter/material.dart';
import 'package:love_letter_flutter/pages/game_page.dart';

import 'app_bar.dart';
import '../model/player.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        home: const Scaffold(
          appBar: MyAppBar(),
          body: HomePlayersAddition(),
          backgroundColor: Colors.amber,
        ));
  }
}

class HomePlayersAddition extends StatefulWidget {

  const HomePlayersAddition({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePlayersAddition> {
  // Initialization with 2 players
  List<Player> players = [Player( "Joueur 1"), Player("Joueur 2")];
  int lastUsedId = 2;

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child :Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => addPlayer(),
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple)),
                child:
                const Text(
                    " Ajouter un joueur ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12
                    )
                ),
              ),
              const SizedBox(width: 40),
              TextButton(
                onPressed: () => startNewGame(),
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple)),
                child:
                const Text(
                    " Lancer la partie ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                    )
                ),
              )

            ],
          ),
          const SizedBox(height: 20),
          Column(children:createPlayersBoxes(currentWidth)),
          const SizedBox(height: 20)
        ],
      )
    );
  }

  List<Widget> createPlayersBoxes(double currentScreenWidth) {
    List<Widget> allBoxes = [];
    for (Player player in players) {
      allBoxes.add(Center(
        child : Card(
          color: Colors.white,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: double.infinity,
            height: 70,
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: currentScreenWidth / 15),
                  Icon(Icons.person, color: Colors.deepPurple, size: currentScreenWidth / 10),
                  SizedBox(width: currentScreenWidth / 15),
                  SizedBox(
                    width: currentScreenWidth / 2,
                    child: TextField(
                      textAlign: TextAlign.left,
                      controller: TextEditingController(
                        text: player.name
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,

                      ),
                      onChanged: (newName) {
                        player.name = newName;
                      },
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(width: currentScreenWidth / 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.deepPurple, size: currentScreenWidth / 10),
                      onPressed: () => removePlayer(player),
                      tooltip: "Supprimer le joueur",

                    )
                  )
                ],
              )
              )
          )
        )
      ));
    }
    return allBoxes;
  }

  addPlayer() {
    if (players.length < 6) {
      setState(() {
        players.add(Player("Joueur ${++lastUsedId}"));
      });
    }
  }

  void removePlayer(Player player) {
    if (players.length > 2) {
      setState(() {
        players.remove(player);
      });
    }
  }

  void startNewGame() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(players)));
  }
}

