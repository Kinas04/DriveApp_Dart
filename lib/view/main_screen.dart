import 'package:flutter/material.dart';
import 'schermata_calendario.dart';
import 'schermata_account.dart';
import 'schermata_esiti.dart';
import 'schermata_prenota.dart';

//Schermata principale che funge da contenitore e gestisce la navigazione tra le varie sezioni
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //Indice della pagina attualmente visualizzata nella barra di navigazione
  int _selectedIndex = 0;

  //Lista dei widget che rappresentano le singole pagine dell'applicazione
  static final List<Widget> _pages = <Widget>[
    const SchermataCalendario(),
    const SchermataEsiti(),
    const SchermataPrenota(),
    const SchermataAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    //Determiniamo se il dispositivo è ruotato in orizzontale per adattare il layout
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      //Drawer laterale accessibile tramite swipe o icona menu
      drawer: _buildDrawer(),
      //Il corpo varia: in orizzontale mostriamo un tasto menu fisso, in verticale la navbar in basso
      body: isLandscape
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Icona menu visibile solo in modalità landscape
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
                //Area principale che ospita la pagina selezionata
                Expanded(child: _pages[_selectedIndex]),
              ],
            )
          : _pages[_selectedIndex],
      //Mostriamo la barra di navigazione inferiore solo se il cellulare è in verticale
      bottomNavigationBar: isLandscape ? null : _buildBottomNav(),
    );
  }

  //costruisce il menu laterale rendendolo scrollabile per evitare overflow (problema con i pixel)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 40),
          _buildDrawerItem(Icons.calendar_today, "Calendario", 0),
          _buildDrawerItem(Icons.assignment, "Esiti", 1),
          _buildDrawerItem(Icons.add, "Prenota", 2),
          _buildDrawerItem(Icons.account_circle, "Account", 3),
        ],
      ),
    );
  }

  //crea un elemento cliccabile all'interno del drawer
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
      selectedColor: Colors.blue,
      onTap: () {
        //Aggiorno l'indice e chiudo automaticamente il menu laterale
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  //costruisce la barra di navigazione inferiore con effetti grafici di selezione
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
            _buildDestination(Icons.calendar_today_outlined,
                Icons.calendar_today, 'Calendario', 0),
            _buildDestination(
                Icons.assignment_outlined, Icons.assignment, 'Esiti', 1),
            _buildDestination(Icons.add, Icons.add, 'Prenota', 2),
            _buildDestination(Icons.account_circle_outlined,
                Icons.account_circle, 'Account', 3),
          ],
        ),
      ),
    );
  }

  //funzione per creare una destinazione della navbar con animazione fluida
  NavigationDestination _buildDestination(
      IconData icon, IconData selectedIcon, String label, int index) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Icon(selectedIcon),
      ),
      label: label,
    );
  }
}
