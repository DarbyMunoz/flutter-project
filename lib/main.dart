import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_recipe_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'recipe_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CookingScreen(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/editProfile': (context) => EditProfileScreen(),
      },
    );
  }
}

class CookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '100K+ Premium Recipe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Get Cooking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Simple way to find Tasty Recipe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signin');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Cooking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  void _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userDocId', docId);

        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text(
              'Email',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Enter Password',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _signIn,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            new GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: new Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  void _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;

    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      await _dbHelper.registerUser(email, password, name);
      Navigator.pushNamed(context, '/signin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Retype Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (bool? value) {},
                  ),
                  Text('Accept terms & Condition'),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showCategoryFilter = false;

  final List<String> _cookingTimeCategories = ['Quick', 'Long'];
  final List<String> _ingredientCategories = [
    'Egg',
    'Chicken',
    'Potato',
    'Bread',
    'Rice',
    'Lettuce'
  ];
  final List<String> _savedCategory = ['Saved'];
  String _base64Image = '';
  String _userId = '';
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userDocId') ?? '';
    });

    if (_userId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _base64Image = userDoc['imageBase64'] ?? '';
          _name = userDoc['name'] ?? '';
        });
      }
    }
  }

  Future<List<DocumentSnapshot>> _fetchSavedRecipes() async {
    if (_userId.isEmpty) return [];
    final savedRecipes = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('savedRecipes')
        .get();

    return savedRecipes.docs;
  }

  bool _isRecipeMatchingSearch(DocumentSnapshot recipe) {
    final searchTerms = _searchQuery
        .toLowerCase()
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();

    final name = recipe['name']?.toString().toLowerCase() ?? '';
    final ingredients = recipe['ingredients']?.toString().toLowerCase() ?? '';

    final allTermsMatch = searchTerms.isEmpty ||
        searchTerms
            .every((term) => name.contains(term) || ingredients.contains(term));

    if (_selectedCategory == 'Saved') {
      return true;
    }

    bool categoryMatch = false;
    switch (_selectedCategory) {
      case 'Quick':
        categoryMatch = _parseCookingTime(recipe['cookingTime']) < 30;
        break;
      case 'Long':
        categoryMatch = _parseCookingTime(recipe['cookingTime']) >= 30;
        break;
      case 'All':
        categoryMatch = true;
        break;
      default:
        categoryMatch = ingredients.contains(_selectedCategory.toLowerCase());
    }

    return allTermsMatch && categoryMatch;
  }

  int _parseCookingTime(String timeStr) {
    if (timeStr.isEmpty) return 0;
    final matches = RegExp(r'\d+').allMatches(timeStr);
    if (matches.isEmpty) return 0;
    int minutes = int.parse(matches.first.group(0)!);
    if (timeStr.contains('hour') || timeStr.contains('hr')) {
      minutes *= 60;
    }
    return minutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'What are you cooking today?',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/editProfile');
              },
              child: CircleAvatar(
                backgroundImage: _base64Image.isNotEmpty
                    ? MemoryImage(base64Decode(_base64Image))
                    : AssetImage('assets/profile.png') as ImageProvider,
                radius: 20,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search recipe',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    setState(() {
                      _showCategoryFilter = !_showCategoryFilter;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            if (_showCategoryFilter)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '-All-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        CategoryButton(
                          label: 'All',
                          isSelected: _selectedCategory == 'All',
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '-Cooking time-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _cookingTimeCategories.map((category) {
                        return CategoryButton(
                          label: category,
                          isSelected: _selectedCategory == category,
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '-Ingredients-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _ingredientCategories.map((category) {
                        return CategoryButton(
                          label: category,
                          isSelected: _selectedCategory == category,
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '-Saved-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _savedCategory.map((category) {
                        return CategoryButton(
                          label: category,
                          isSelected: _selectedCategory == category,
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _selectedCategory == 'Saved'
                  ? FutureBuilder<List<DocumentSnapshot>>(
                      future: _fetchSavedRecipes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No saved recipes found'));
                        }

                        final savedRecipes = snapshot.data!;

                        return ListView.builder(
                          itemCount: savedRecipes.length,
                          itemBuilder: (context, index) {
                            final recipeData = savedRecipes[index];
                            final String name =
                                recipeData['name'] ?? 'Untitled Recipe';
                            final String time =
                                recipeData['cookingTime'] ?? '15 Mins';
                            final String ingredients =
                                recipeData['ingredients'] ??
                                    'No ingredients listed';
                            final String instructions =
                                recipeData['instructions'] ??
                                    'No instructions available';
                            final String? imageBase64 =
                                recipeData['imageBase64'];

                            Widget recipeImage;
                            if (imageBase64 != null && imageBase64.isNotEmpty) {
                              try {
                                recipeImage = Image.memory(
                                  base64Decode(imageBase64),
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              } catch (e) {
                                recipeImage = Image.asset(
                                  'assets/default_recipe.png',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }
                            } else {
                              recipeImage = Image.asset(
                                'assets/default_recipe.png',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }

                            return RecipeCard(
                              imageWidget: recipeImage,
                              title: name,
                              time: time,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailScreen(
                                        name: name,
                                        ingredients: ingredients,
                                        instructions: instructions,
                                        imageWidget: recipeImage,
                                        imageBase64: recipeData['imageBase64'],
                                        time: time,
                                        userId: _userId),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    )
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('recipes')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No recipes found'));
                        }

                        final filteredRecipes = snapshot.data!.docs
                            .where(_isRecipeMatchingSearch)
                            .toList();

                        if (filteredRecipes.isEmpty) {
                          return Center(child: Text('No recipes found'));
                        }

                        return ListView.builder(
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipeData = filteredRecipes[index];
                            final String name =
                                recipeData['name'] ?? 'Untitled Recipe';
                            final String time =
                                recipeData['cookingTime'] ?? '15 Mins';
                            final String ingredients =
                                recipeData['ingredients'] ??
                                    'No ingredients listed';
                            final String instructions =
                                recipeData['instructions'] ??
                                    'No instructions available';
                            final String? imageBase64 =
                                recipeData['imageBase64'];

                            Widget recipeImage;
                            if (imageBase64 != null && imageBase64.isNotEmpty) {
                              try {
                                recipeImage = Image.memory(
                                  base64Decode(imageBase64),
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              } catch (e) {
                                recipeImage = Image.asset(
                                  'assets/default_recipe.png',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }
                            } else {
                              recipeImage = Image.asset(
                                'assets/default_recipe.png',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }

                            return RecipeCard(
                              imageWidget: recipeImage,
                              title: name,
                              time: time,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailScreen(
                                        name: name,
                                        ingredients: ingredients,
                                        instructions: instructions,
                                        imageWidget: recipeImage,
                                        imageBase64: recipeData['imageBase64'],
                                        time: time,
                                        userId: _userId),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: IconButton(
          icon: Icon(
            Icons.add_circle,
            size: 40,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecipeScreen()),
            );
          },
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Widget imageWidget;
  final String title;
  final String time;
  final VoidCallback onTap;

  const RecipeCard({
    required this.imageWidget,
    required this.title,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: imageWidget,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Time: $time',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryButton({
    required this.label,
    this.isSelected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userId = '';
  String _base64Image = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userDocId') ?? '';
    });

    if (_userId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _passwordController.text = userDoc['password'] ?? '';
          _base64Image = userDoc['imageBase64'] ?? '';
        });
      }
    }
  }

  void _saveProfile() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({
          'name': name,
          'email': email,
          'password': password,
          'imageBase64': _base64Image,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = File(pickedFile.path).readAsBytesSync();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _base64Image.isNotEmpty
                    ? MemoryImage(base64Decode(_base64Image))
                    : AssetImage('assets/profile.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
