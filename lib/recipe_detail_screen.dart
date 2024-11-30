import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String name;
  final String ingredients;
  final String instructions;
  final Widget imageWidget;
  final String imageBase64;
  final String time;
  final String userId;

  const RecipeDetailScreen({
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.imageWidget,
    required this.imageBase64,
    required this.time,
    required this.userId,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isSaved = false;
  String? _savedRecipeId;

  @override
  void initState() {
    super.initState();
    _checkIfRecipeIsSaved();
  }

  Future<void> _checkIfRecipeIsSaved() async {
    if (widget.userId == null) return;

    try {
      final recipesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('savedRecipes');

      final querySnapshot = await recipesCollection
          .where('name', isEqualTo: widget.name)
          .where('cookingTime', isEqualTo: widget.time)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isSaved = true;
          _savedRecipeId = querySnapshot.docs.first.id;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking recipe: $e')),
      );
    }
  }

  Future<void> _toggleSaveRecipe() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to save or unsave recipes.')),
      );
      return;
    }

    try {
      final recipesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('savedRecipes');

      if (_isSaved && _savedRecipeId != null) {
        await recipesCollection.doc(_savedRecipeId).delete();
        setState(() {
          _isSaved = false;
          _savedRecipeId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe unsaved successfully!')),
        );
      } else {
        final newDoc = await recipesCollection.add({
          'name': widget.name,
          'ingredients': widget.ingredients,
          'instructions': widget.instructions,
          'cookingTime': widget.time,
          'imageBase64': widget.imageBase64,
          'savedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isSaved = true;
          _savedRecipeId = newDoc.id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe saved successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle recipe save state: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.imageWidget,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        widget.time,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.ingredients,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.instructions,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSaveRecipe,
        backgroundColor: _isSaved ? Colors.red : Colors.green,
        child: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
      ),
    );
  }
}
