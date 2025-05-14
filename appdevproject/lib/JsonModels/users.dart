class Users {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  late final String userPassword;

  Users({
    this.userId,
    this.firstName,
    this.lastName,
    required this.email,
    required this.userPassword,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
    userId: json["userId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    userPassword: json["userPassword"],
  );

  Map<String, dynamic> toMap() => {
    "userId": userId,
    "firstName" : firstName,
    "lastName" : lastName,
    "email" : email,
    "userPassword": userPassword,
  };
}
