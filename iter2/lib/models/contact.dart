class Contact {
  final String id;

  String name;
  String email;
  String phone;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  updateContact(String? name,
                String? email,
                String? phone) {
    this.name = name ?? this.name;
    this.email = email ?? this.email;
    this.phone = phone ?? this.phone;
  }
}