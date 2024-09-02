import 'card.dart';

class Player {

  static Player nobody = Player("NOBODY");

  String name ="";
  bool spyPlayed = false;
  bool handmaidPlayed = false;
  List<CardModel> cards = [];
  List<CardModel> playedCards = [];
  bool isSelected = false;

  Player(this.name);

  void addCard(CardModel card) {
    cards.add(card);
  }

  void playCard(CardModel card) {
    cards.remove(card);
    playedCards.add(card);
  }

  void selectCard(CardModel card) {
    for (CardModel card in cards) {
      card.isSelected = false;
    }
    card.isSelected = true;
  }

  void reset() {
    spyPlayed = false;
    handmaidPlayed = false;
    cards.clear();
    playedCards.clear();
    isSelected = false;
  }

}