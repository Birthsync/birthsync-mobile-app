import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonCardPage extends StatefulWidget {
  const PersonCardPage({super.key});

  @override
  State<PersonCardPage> createState() => _PersonCardPageState();
}

class _PersonCardPageState extends State<PersonCardPage> {
  // State for editable fields
  String name = "Вашен";
  String age = "21 год";
  String birthDate = "18.05.2004";

  // Parameters
  String chainSize = "42 (В)";
  String height = "10 (см)";
  String type = "Тип менее сумма";

  // Service
  String servicePlace = "";
  String servicePrice = "";
  String servicePart = "";
  String serviceQuantity = "";
  String serviceAdditional = "";

  // Dislikes
  List<String> dislikes = ["Помощь", "Белый шоколад"];

  // Facts
  String facts = """
Эта работа - это негативная схема.
Произведет который вопрос в его романе ожидаемой перегрузки до меня. Но для вашего удобства скажу то, что эта история объясняет вам множество событий, которые произошли в первой части ремонта.
Постоянно собирается использовать округлые планеты Короса узнать о передаче посты его командования. Однако, только ли ему стоит быть правду?
**ОКАЗЬ ЕЕ**
Возьмет не понимаюсь!
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка человека'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeaderSection(),
            const SizedBox(height: 20),

            // Parameters section
            _buildSection(
              title: "Параметры",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParameterItem("Размер цепи:", chainSize),
                  _buildParameterItem("Рост:", height),
                  _buildParameterItem("Тип:", type),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Service section
            _buildSection(
              title: "Служба",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceItem("Место:", servicePlace),
                  _buildServiceItem("Цена:", servicePrice),
                  _buildServiceItem("Часть:", servicePart),
                  _buildServiceItem("Количество:", serviceQuantity),
                  _buildServiceItem("Дополнительно:", serviceAdditional),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Dislikes section
            _buildSection(
              title: "Не любит",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var dislike in dislikes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.close, size: 16),
                          const SizedBox(width: 8),
                          Text("_${dislike}_"),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Facts section
            _buildSection(
              title: "Факты",
              child: Text(facts),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWidgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "# $name",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(age),
        Text(birthDate),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "## $title",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildParameterItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "- $label",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? "Не указано" : value)),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController ageController = TextEditingController(text: age);
    TextEditingController birthDateController = TextEditingController(text: birthDate);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать информацию'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Имя'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Возраст'),
                ),
                TextField(
                  controller: birthDateController,
                  decoration: const InputDecoration(labelText: 'Дата рождения'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  name = nameController.text;
                  age = ageController.text;
                  birthDate = birthDateController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddWidgetDialog(BuildContext context) async {
    final widgetTypes = [
      'Текстовый виджет',
      'Виджет-изображение',
      'Цветовой виджет',
      'Виджет-страница',
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить виджет'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widgetTypes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widgetTypes[index]),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Добавлен ${widgetTypes[index]}')),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}