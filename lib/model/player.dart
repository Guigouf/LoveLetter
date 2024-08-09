import 'card.dart';

class Player {

  static Player nobody = Player(-1, "NOBODY");

  int id = -1;
  String name ="";
  bool spyPlayed = false;
  bool handmaidPlayed = false;
  List<Card> cards = [];
  List<Card> playedCards = [];
  bool isSelected = false;

  Player(this.id, this.name);

  void addCard(Card card) {
    cards.add(card);
  }

  void playCard(Card card) {
    cards.remove(card);
    playedCards.add(card);
  }

  void selectCard(Card card) {
    for (Card card in cards) {
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