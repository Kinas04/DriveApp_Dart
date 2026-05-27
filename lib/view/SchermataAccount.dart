import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

// --- SEZIONE PREVIEW ---
@Preview()
Widget previewSchermataAccount() {
  return const MaterialApp(
    home: SchermataAccount(),
  );
}

class SchermataAccount extends StatelessWidget {
  const SchermataAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        titleSpacing: 10,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Nome Cognome",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            //il Widget ListTile è utile in questo caso poichè ci permette di avere tutti e 3 gli oggetti che occorrono per il pulsante
            ListTile(
              title: const Text("Sicurezza ed accesso", style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text("Modifica password, elimina account"),
              trailing: const Icon(Icons.arrow_right, color: Colors.black54),
              onTap: () {/*Da implementare*/},
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text("Informazioni sull'app", style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text("Contatti, supporto, info legali"),
              trailing: const Icon(Icons.arrow_right, color: Colors.black54),
              onTap: () {/*Da implementare*/},
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text("Esci dall'account", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent)),
              subtitle: const Text("Disconnessione dall'app"),
              trailing: const Icon(Icons.arrow_right, color: Colors.black54),
              onTap: () {/*Da implementare*/},
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}