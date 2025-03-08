# Integrating MongoDB with Flutter

This guide will help you update your TAssist Flutter application to use MongoDB instead of Firebase.

## Approach

We'll use a two-part approach:
1. Create a backend API service using Node.js/Express to interact with MongoDB
2. Update the Flutter app to communicate with this API instead of Firebase

## Part 1: Create a MongoDB Backend API

### 1. Set up a Node.js/Express server

Create a new directory for your backend:

```bash
mkdir tassist-backend
cd tassist-backend
npm init -y
npm install express mongoose cors dotenv bcrypt jsonwebtoken
```

### 2. Create the server structure

```
tassist-backend/
├── config/
│   └── db.js
├── controllers/
│   ├── authController.js
│   ├── studentController.js
│   └── teacherController.js
├── models/
│   ├── Chat.js
│   ├── Class.js
│   ├── Student.js
│   ├── Teacher.js
│   └── Topic.js
├── routes/
│   ├── auth.js
│   ├── students.js
│   └── teachers.js
├── middleware/
│   └── auth.js
├── .env
└── server.js
```

### 3. Connect to MongoDB

In `config/db.js`:

```javascript
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
```

### 4. Set up environment variables

In `.env`:

```
MONGO_URI=mongodb+srv://sahme29:Gzt2AZw6NJqj95Dn@cluster0.k1x8c.mongodb.net/tassist?retryWrites=true&w=majority&appName=Cluster0
JWT_SECRET=your_jwt_secret_key
PORT=5000
```

### 5. Create models

Example for `models/Teacher.js`:

```javascript
const mongoose = require('mongoose');

const TeacherSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  isAdmin: {
    type: Boolean,
    default: false
  },
  // Add other fields as needed
}, { timestamps: true });

module.exports = mongoose.model('Teacher', TeacherSchema);
```

### 6. Create API routes and controllers

Example for authentication in `controllers/authController.js`:

```javascript
const Teacher = require('../models/Teacher');
const Student = require('../models/Student');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
  try {
    const { email, password, isTeacher } = req.body;
    
    let user;
    
    if (isTeacher) {
      user = await Teacher.findOne({ email });
    } else {
      user = await Student.findOne({ email });
    }
    
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    
    const isMatch = await bcrypt.compare(password, user.password);
    
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    
    const payload = {
      user: {
        id: user.id,
        isTeacher: isTeacher,
        isAdmin: isTeacher ? user.isAdmin : false
      }
    };
    
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '24h' },
      (err, token) => {
        if (err) throw err;
        res.json({ token, user: {
          id: user.id,
          name: user.name,
          email: user.email,
          isTeacher: isTeacher,
          isAdmin: isTeacher ? user.isAdmin : false
        }});
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};
```

### 7. Set up the main server file

In `server.js`:

```javascript
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
require('dotenv').config();

// Connect to MongoDB
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/students', require('./routes/students'));
app.use('/api/teachers', require('./routes/teachers'));
// Add more routes as needed

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
```

## Part 2: Update Flutter App to Use MongoDB API

### 1. Add HTTP package to your Flutter app

In `pubspec.yaml`, ensure you have:

```yaml
dependencies:
  http: ^1.3.0
  shared_preferences: ^2.5.2  # For storing JWT token
```

### 2. Create API service

Create a new file `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://your-api-server:5000/api';
  
  // Get stored JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Store JWT token
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  // Clear token on logout
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  // Headers with authorization
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password, bool isTeacher) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'isTeacher': isTeacher,
      }),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      await setToken(data['token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user profile');
    }
  }
  
  // Add more API methods as needed for your app
  // For example:
  // - getStudents()
  // - getClasses()
  // - sendMessage()
  // etc.
}
```

### 3. Replace Firebase Authentication with API Service

Update your login screen (`lib/screens/auth/login_screen.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
// Other imports...

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  // Other variables...
  
  void handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email and Password cannot be empty.';
        isLoading = false;
      });
      return;
    }

    try {
      // Call the API service instead of Firebase
      final response = await _apiService.login(email, password, isAdminSelected);
      
      // Store user data in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', response['user']['id']);
      await prefs.setString('email', email);
      await prefs.setString('name', response['user']['name']);
      
      if (response['user']['isAdmin']) {
        await prefs.setString('type', 'admin');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanel()),
        );
      } else if (response['user']['isTeacher']) {
        await prefs.setString('type', 'teacher');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        // Student
        await prefs.setString('type', 'student');
        await prefs.setString('studentId', response['user']['id']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => studentDashboard(studentId: response['user']['id']),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  // Rest of the class...
}
```

### 4. Replace Firestore Queries with API Calls

For each Firestore query in your app, create a corresponding API method and update your code.

Example for fetching student data:

```dart
// Before (Firestore)
DocumentSnapshot<Map<String, dynamic>> studentDoc = 
    await FirebaseFirestore.instance.collection('students').doc(studentId).get();

// After (MongoDB API)
final ApiService _apiService = ApiService();
final studentData = await _apiService.getStudent(studentId);
```

## Deployment

1. Deploy your Node.js backend to a hosting service like Heroku, Render, or DigitalOcean
2. Update the `baseUrl` in your Flutter app to point to your deployed backend
3. Build and deploy your updated Flutter app

## Security Considerations

1. Always use HTTPS for your API endpoints
2. Implement rate limiting to prevent abuse
3. Validate all inputs on the server side
4. Keep your JWT secret secure and rotate it periodically
5. Consider implementing refresh tokens for better security
