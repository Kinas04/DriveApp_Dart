import 'package:flutter/material.dart';
import 'SchermataAccount.dart';
import 'SchermataEsiti.dart';
import 'SchermataPrenota.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista delle schermate collegate alla barra di navigazione
  static final List<Widget> _pages = <Widget>[
    //Per ora metto del testo giusto per "chiudere i buchi" nel frattempo che implemento le altre
    const Center(child: Text('Calendario')),
    const SchermataEsiti(),
    const SchermataPrenota(),
    const Center(child: Text('Quiz')),
    const SchermataAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Il corpo dello Scaffold varai in base all'"indice selezionato"
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFFDEE1F3),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            //Settiamo le destinazioni per ogni bottone della navbar
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: 'Calendario',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Esiti esami',
              ),
              NavigationDestination(
                icon: Icon(Icons.add),
                label: 'Prenota',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_car_outlined),
                selectedIcon: Icon(Icons.directions_car),
                label: 'Quiz',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(Icons.account_circle),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
