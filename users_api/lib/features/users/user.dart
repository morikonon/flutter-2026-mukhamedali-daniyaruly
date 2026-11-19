// Модель пользователя jsonplaceholder. Каждый `as` в fromJson — это
// утверждение о JSON, которое я проверил в Postman (см. NOTES.md).
// Если сервер нарушит утверждение, каст упадёт и назовёт поле,
// а репозиторий превратит это в BadResponseException.
//
// Правила: const-конструкторы, только final-поля, без late и без `!`.

class Geo {
  const Geo({required this.lat, required this.lng});

  // Сервер шлёт координаты строками ("-37.3159"), а храним double:
  // поэтому сначала `as String`, потом double.parse.
  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: double.parse(json['lat'] as String),
    lng: double.parse(json['lng'] as String),
  );

  final double lat;
  final double lng;

  // Обратно отдаём строками — та же форма, что прислал сервер.
  Map<String, dynamic> toJson() => {'lat': '$lat', 'lng': '$lng'};
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    // Вложенный объект: свой fromJson, свой каст к Map.
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

// company — не отдельный класс, а record: два поля без поведения.
typedef Company = ({String name, String catchPhrase});

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
    this.website,
  });

  // Черновик для формы «New user»: id = 0, настоящий id назначит сервер.
  const User.draft({
    required this.name,
    required this.username,
    required this.email,
  }) : id = 0,
       phone = '',
       website = null,
       address = const Address(
         street: '',
         suite: '',
         city: '',
         zipcode: '',
         geo: Geo(lat: 0, lng: 0),
       ),
       company = (name: '', catchPhrase: '');

  factory User.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      // Единственное поле, которое я считаю необязательным: `as String?`
      // пропускает и null, и отсутствующий ключ.
      website: json['website'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: company['name'] as String,
        catchPhrase: company['catchPhrase'] as String,
      ),
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone; // сырая строка как пришла: "1-770-736-8031 x56442"
  final String? website;
  final Address address;
  final Company company;

  // Только цифры и '+': пригодится для tel: в Practice 12.
  String get phoneDigits => phone.replaceAll(RegExp(r'[^\d+]'), '');

  // Та же форма, что прислал сервер, с вложенными Map —
  // поэтому User.fromJson(user.toJson()) == user.
  // (Поле company.bs сервера модель сознательно не хранит.)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address.toJson(),
    'company': {'name': company.name, 'catchPhrase': company.catchPhrase},
  };

  // Равенство по id: у сервера id — это и есть идентичность пользователя.
  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name, ${address.city})';
}
