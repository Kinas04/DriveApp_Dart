import 'package:flutter/material.dart';
import 'SchermataCalendario.dart';
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

  //lista delle schermate collegate alla barra di navigazione
  static final List<Widget> _pages = <Widget>[
    const SchermataCalendario(),
    const SchermataEsiti(),
    const SchermataPrenota(),
    const SchermataAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    //determiniamo l'orientamento del dispositivo
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      //aggiungiamo il drawer (pannello laterale) richiamabile menu a tre linee
      drawer: _buildDrawer(),
      //il corpo dello Scaffold varia in base all'orientamento
      body: isLandscape 
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //colonna fissa per il menu in orizzontale
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, size: 32),
                      //alla pressione del menù a tre linee, si apre il pannello con tutte le schermate
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
              //la pagina occupa il resto dello spazio
              Expanded(child: _pages[_selectedIndex]),
            ],
          )
        : _pages[_selectedIndex],
      //mostriamo la navbar solo se il cellulare e' in verticale
      bottomNavigationBar: isLandscape ? null : _buildBottomNav(),
    );
  }

  //costruisce il menu laterale rendendolo scrollabile per evitare overflow (problema con i pixel)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 40), //spazio sopra il menù
          _buildDrawerItem(Icons.calendar_today, "Calendario", 0),
          _buildDrawerItem(Icons.assignment, "Esiti", 1),
          _buildDrawerItem(Icons.add, "Prenota", 2),
          _buildDrawerItem(Icons.account_circle, "Account", 3),
        ],
      ),
    );
  }

  //crea il singolo elemento del drawer
  Widget _buildDrawerItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.blue, // colore quando selezionati
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); //chiude il drawer dopo la selezione
      },
    );
  }

  //costruisce la barra di navigazione sul fondo dello schermo
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            //Assegno le varie icone per ogni schermata
            _buildDestination(Icons.calendar_today_outlined, Icons.calendar_today, 'Calendario', 0),
            _buildDestination(Icons.assignment_outlined, Icons.assignment, 'Esiti', 1),
            _buildDestination(Icons.add, Icons.add, 'Prenota', 2),
            _buildDestination(Icons.account_circle_outlined, Icons.account_circle, 'Account', 3),
          ],
        ),
      ),
    );
  }

  /*funzione per costruire la destinazione con l'effetto di sollevamento e ingrandimento
  Utile per dare l'effetto simil - Kotlin*/
  NavigationDestination _buildDestination(IconData icon, IconData selectedIcon, String label, int index) {
    return NavigationDestination(
      icon: Icon(icon),
      //In base all'icona selezionata, chiamo al funzione AnimatedContainer
      //Setto la durata dell'animazione, il tipo di effetto e di quanto deve spostarsi
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Icon(selectedIcon),
      ),
      label: label,
    );
  }
}
