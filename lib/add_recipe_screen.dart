import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _addRecipe() async {
    final String name = _nameController.text;
    final String ingredients = _ingredientsController.text;
    final String instructions = _instructionsController.text;
    final String time = _timeController.text;

    if (name.isNotEmpty &&
        ingredients.isNotEmpty &&
        instructions.isNotEmpty &&
        _imageFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String base64Image = await _convertImageToBase64();

        await FirebaseFirestore.instance.collection('recipes').add({
          'name': name,
          'ingredients': ingredients,
          'instructions': instructions,
          'imageBase64': base64Image,
          'cookingTime': time,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe added successfully!')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe: $error')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields and an image are required')),
      );
    }
  }

  Future<String> _convertImageToBase64() async {
    final bytes = await _imageFile!.readAsBytes();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.add_a_photo, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: 'Ingredients'),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _instructionsController,
                decoration: InputDecoration(labelText: 'Instructions'),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Cooking Time'),
              ),
              SizedBox(height: 24),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addRecipe,
                      child: Text('Add Recipe'),
                    ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
