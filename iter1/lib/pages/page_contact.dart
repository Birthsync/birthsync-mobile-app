import 'package:birthsync/views/collision_grid.dart';
import 'package:birthsync/views/swap_grid.dart';
import 'package:flutter/material.dart';

import '../modals/contact_create.dart';
import '../models/contact.dart';

class ListContactsPage extends StatefulWidget {
  const ListContactsPage({super.key});

  @override
  State<ListContactsPage> createState() => _ListContactsPageState();
}

class _ListContactsPageState extends State<ListContactsPage> {
  List<Contact> contacts = [];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addContact() async {
    final result = await showDialog<Contact>(
      context: context,
      builder: (context) => const ContactDialog(
        contact: null,
      ),
    );

    if (result != null) {
      setState(() {
        contacts.add(result);
      });
    }
  }

  void _editContact(Contact contact) async {
    final result = await showDialog<Contact>(
      context: context,
      builder: (context) => ContactDialog(
        contact: contact,
      ),
    );

    if (result != null) {
      setState(() {
        final index = contacts.indexWhere((c) => c.id == result.id);
        contacts[index] = result;
      });
    }
  }

  void _deleteContact(String id) {
    setState(() {
      contacts.removeWhere((contact) => contact.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Реализация перезагрузки данных
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(contact.name),
            subtitle: Text(contact.email),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteContact(contact.id),
            ),
            onTap: () => SwapGrid(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}