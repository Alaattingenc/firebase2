import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'etkinlik_modeli.dart';

class KategoriSeridi extends StatefulWidget {
  final Category selectedCategory;
  final Function(Category) onCategorySelected;
  final List<Category> categories = Category.values;

  KategoriSeridi(
      {super.key,
      required this.selectedCategory,
      required this.onCategorySelected});

  @override
  _KategoriSeridiState createState() => _KategoriSeridiState();
}

class _KategoriSeridiState extends State<KategoriSeridi> {
  String selectedCategory = 'Tümü';
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    var collection = FirebaseFirestore.instance.collection('categories');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      categories.add(data['name']);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          bool isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                widget.onCategorySelected(category as Category);
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.lightGreenAccent.shade400
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
