import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactEditPage extends StatefulWidget {
  final Contact contact;

  const ContactEditPage({Key? key, required this.contact}) : super(key: key);

  @override
  _ContactEditPageState createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _emailController = TextEditingController(text: widget.contact.email);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _birthDateController = TextEditingController(text: widget.contact.birthDate);
    _avatarUrlController = TextEditingController(text: widget.contact.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _saveContact() {
    final updatedContact = Contact(
      id: widget.contact.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      birthDate: _birthDateController.text,
      avatarUrl: _avatarUrlController.text.isNotEmpty ? _avatarUrlController.text : null,
    );
    Navigator.pop(context, updatedContact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать контакт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Имя')),
              SizedBox(height: 16),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 16),
              TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Телефон')),
              SizedBox(height: 16),
              TextField(controller: _birthDateController, decoration: InputDecoration(labelText: 'Дата рождения')),
              SizedBox(height: 16),
              TextField(controller: _avatarUrlController, decoration: InputDecoration(labelText: 'URL аватара')),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _saveContact, child: Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }
}
