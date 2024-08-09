class Card {
  final int value;
  final String name;
  final String _imagePath;
  final String _selectedImagePath;
  bool isSelected = false;

  Card(this.value, this.name, this._imagePath, this._selectedImagePath);

  Card.ofCardEnum(CardEnum cardEnum)
      : this(cardEnum.value, cardEnum.name, cardEnum.imagePath,
            cardEnum.selectedImagePath);

  String getImagePath() {
    return isSelected ? _selectedImagePath : _imagePath;
  }
}

enum CardEnum {
  spy(0, "Espionne", "images/cards/espionne.jpg",
      "images/cards/espionne_selected.jpg"),
  guard(
      1, "Garde", "images/cards/garde.jpg", "images/cards/garde_selected.jpg"),
  priest(2, "Pretre", "images/cards/pretre.jpg",
      "images/cards/pretre_selected.jpg"),
  baron(
      3, "Baron", "images/cards/baron.jpg", "images/cards/baron_selected.jpg"),
  handmaid(4, "Servante", "images/cards/servante.jpg",
      "images/cards/servante_selected.jpg"),
  prince(5, "Prince", "images/cards/prince.jpg",
      "images/cards/prince_selected.jpg"),
  chanceller(6, "Chancelier", "images/cards/chancelier.jpg",
      "images/cards/chancelier_selected.jpg"),
  king(7, "Roi", "images/cards/roi.jpg", "images/cards/roi_selected.jpg"),
  comtess(8, "Comtesse", "images/cards/comtesse.jpg",
      "images/cards/comtesse_selected.jpg"),
  princess(9, "Princesse", "images/cards/princesse.jpg",
      "images/cards/princesse_selected.jpg");

  final int value;
  final String name;
  final String imagePath;
  final String selectedImagePath;

  const CardEnum(this.value, this.name, this.imagePath, this.selectedImagePath);
}
