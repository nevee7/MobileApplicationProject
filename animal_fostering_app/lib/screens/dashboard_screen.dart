import 'package:flutter/material.dart';
import 'animal_list_screen.dart';
import 'add_animal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardHome(),
    AnimalListScreen(),
    AddAnimalScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Fostering'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Animals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Animal',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animal Fostering Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          // Add dashboard statistics here
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.pets, color: Colors.blue),
                    title: Text('Total Animals'),
                    trailing: Text('12', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.green),
                    title: Text('Available for Adoption'),
                    trailing: Text('8', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.orange),
                    title: Text('In Foster Care'),
                    trailing: Text('3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.red),
                    title: Text('Adopted'),
                    trailing: Text('1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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