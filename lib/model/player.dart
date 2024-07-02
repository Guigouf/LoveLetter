import 'card.dart';

class Player {

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
    for (Card card in cards) {card.isSelected = false;}
    card.isSelected = true;
  }

}