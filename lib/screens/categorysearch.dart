import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  final List<String> allCategories;
  final List<String> selectedCategories;

  const CategorySelectionScreen({
    required this.allCategories,
    required this.selectedCategories,
    Key? key,
  }) : super(key: key);

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late List<String> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selectedCategories);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카테고리 선택'),
      ),
      body: ListView.builder(
        itemCount: widget.allCategories.length,
        itemBuilder: (context, index) {
          final category = widget.allCategories[index];
          final isSelected = selectedCategories.contains(category);
          return ListTile(
            title: Text(category),
            trailing: isSelected
                ? Icon(Icons.check, color: Colors.blue)
                : Icon(Icons.add),
            onTap: () => _toggleCategory(category),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, selectedCategories);
          },
          child: Text('추가'),
        ),
      ),
    );
  }
}
