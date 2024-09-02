class CardModel {
  final int value;
  final String name;
  final String _imagePath;
  bool isSelected = false;

  CardModel(this.value, this.name, this._imagePath);

  CardModel.ofCardEnum(CardEnum cardEnum)
      : this(cardEnum.value, cardEnum.name, cardEnum.imagePath);

  String getImagePath() {
    return _imagePath;
  }
}

enum CardEnum {
  spy(0, "Espionne", "assets/images/cards/espionne.jpg"),
  guard(1, "Garde", "assets/images/cards/garde.jpg"),
  priest(2, "Pretre", "assets/images/cards/pretre.jpg"),
  baron(3, "Baron", "assets/images/cards/baron.jpg"),
  handmaid(4, "Servante", "assets/images/cards/servante.jpg"),
  prince(5, "Prince", "assets/images/cards/prince.jpg"),
  chanceller(6, "Chancelier", "assets/images/cards/chancelier.jpg"),
  king(7, "Roi", "assets/images/cards/roi.jpg"),
  comtess(8, "Comtesse", "assets/images/cards/comtesse.jpg"),
  princess(9, "Princesse", "assets/images/cards/princesse.jpg");

  final int value;
  final String name;
  final String imagePath;

  const CardEnum(this.value, this.name, this.imagePath);
}
