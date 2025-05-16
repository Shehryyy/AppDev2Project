class Items {
  final int? itemId;
  final String itemName;
  final String quantity;
  final String type;
  final String neededBy;
  final int userId;
  final int isActive;

  Items({
    this.itemId,
    required this.itemName,
    required this.quantity,
    required this.type,
    required this.neededBy,
    required this.userId,
    this.isActive = 1
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'type': type,
      'neededBy': neededBy,
      'userId': userId,
      'isActive' : isActive
    };
  }

  factory Items.fromMap(Map<String, dynamic> map) {
    return Items(
        itemId: map['itemId'],
        itemName: map['itemName'],
        quantity: map['quantity'],
        type: map['type'],
        neededBy: map['neededBy'],
        userId: map['userId'],
        isActive: map['isActive']
    );
  }
}