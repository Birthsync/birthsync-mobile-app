import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'contact_detail.dart';
import 'contact_edit.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> contacts = [
    Contact(
      id: '1',
      name: 'Иван Иванов',
      email: 'ivan@example.com',
      phone: '+7 999 123-45-67',
      birthDate: '21.01.2002',
    ),
    Contact(
      id: '2',
      name: 'Пётр Петров',
      email: 'petr@example.com',
      phone: '+7 999 765-43-21',
      birthDate: '10.05.1998',
    ),
  ];

  void _addContact() {
    setState(() {
      contacts.add(
        Contact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Новый контакт',
          email: 'new@example.com',
          phone: '+7 000 000-00-00',
          birthDate: '01.01.2000',
        ),
      );
    });
  }

  void _removeContact(String id) {
    setState(() {
      contacts.removeWhere((contact) => contact.id == id);
    });
  }

  void _editContact(Contact contact) async {
    final updatedContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactEditPage(contact: contact)),
    );
    if (updatedContact != null && updatedContact is Contact) {
      setState(() {
        int index = contacts.indexWhere((c) => c.id == updatedContact.id);
        if (index != -1) {
          contacts[index] = updatedContact;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Контакты'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(contact.name.isNotEmpty ? contact.name[0] : '?'),
            ),
            title: Text(contact.name),
            subtitle: Text(contact.email),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeContact(contact.id),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailPage(contact: contact),
                ),
              );
            },
            onLongPress: () {
              // Редактирование контакта по долгому нажатию
              _editContact(contact);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: Icon(Icons.add),
      ),
    );
  }
}
