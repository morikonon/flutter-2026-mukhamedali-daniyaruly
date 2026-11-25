// ЗАЩИТА: модель пользователя.
// - fromJson: каждый `as` — это утверждение о JSON (проверено в Postman на Practice 11).
//   `as num` → потом toInt(), `as String?` для полей, которых может не быть.
// - toJson повторяет форму сервера (address.city вложен), чтобы кэш делал
//   честный round trip: toJson → файл → fromJson даёт тот же объект.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.website,
    this.city,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? website;
  final String? city;

  // "1-770-736-8031 x56442" → "17707368031": только цифры до расширения для tel:
  String? get phoneDigits =>
      phone?.split(' x').first.replaceAll(RegExp(r'\D'), '');

  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      city: address?['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'website': website,
    'address': {'city': city},
  };
}
