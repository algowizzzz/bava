import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatbot/admin/Admin_dashboard.dart';
import 'package:chatbot/admin/students.dart';
import 'package:chatbot/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_brodcast.dart';
import 'banner_edit.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({Key? key}) : super(key: key);

  void _showEditDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $type'),
          content: SingleChildScrollView(
            child: type == 'School Details'
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'School Name'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Contact'),
                ),
              ],
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog without any further action
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Clear session data stored in SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clears all preferences

                // Close the dialog
                Navigator.pop(context);

                // Navigate to the login screen or the desired page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [IconButton(
          icon: const Icon(Icons.logout, color: Colors.black, size: 28),
          onPressed: () => _showLogoutDialog(context),
        ),],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.width >= 600
                        ? MediaQuery.of(context).size.height * 0.45
                        : MediaQuery.of(context).size.height * 0.2,
                    aspectRatio: 16/9,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage('assets/banner.jpg'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage('assets/banner.jpg'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.02,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.01,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.blue[50],
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.school, size: 24),
                                  SizedBox(width: 8),
                                  Text('School Details',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, 'School Details'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('School Name: ABC School', style: TextStyle(color: Colors.black)),
                          Text('Address: 123 Education Street', style: TextStyle(color: Colors.black)),
                          Text('Contact: +1234567890', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.blue[50],
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, size: 24),
                                  SizedBox(width: 8),
                                  Text('Profile Details',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, 'Profile Details'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Name: John Doe', style: TextStyle(color: Colors.black)),
                          Text('Role: Administrator', style: TextStyle(color: Colors.black)),
                          Text('Email: admin@abcschool.com', style: TextStyle(color: Colors.black)),
                          Text('Phone: +1234567890', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.blue[50],
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_city,size: 24),
                                  SizedBox(width: 8),
                                  Text('Location',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, 'Profile Details'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Current Location: Not fetched', style: TextStyle(color: Colors.black)),
                          Text('Last Updated: Never', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.02,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Options",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.01,
                ),


                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 600 ? 4 : 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.blue[50],
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          if (_getTitle(index + 1) == 'Teacher List') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminDashboard()),
                            );
                          }
                          if ( _getTitle(index + 1) == 'Students List') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Students()),
                            );
                          }

                          if (_getTitle(index + 1) == 'General Broadcast') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminBoardcast()),
                            );
                          }

                          if (_getTitle(index + 1) == 'Edit Banners') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BannerEditScreen()),
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIcon(index + 1),
                              size: 32,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTitle(index + 1),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.account_circle;
      case 1:
        return Icons.image;
      case 2:
        return Icons.people;
      case 3:
        return Icons.group;
      case 4:
        return Icons.campaign;
      default:
        return Icons.logout;
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'My Account';
      case 1:
        return 'Edit Banners';
      case 2:
        return 'Teacher List';
      case 3:
        return 'Students List';
      case 4:
        return 'General Broadcast';
      default:
        return 'Logout';
    }
  }
}