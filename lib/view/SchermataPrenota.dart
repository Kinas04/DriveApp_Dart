import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview()
Widget previewSchermataAccount() {
  return const MaterialApp(
    home: SchermataPrenota(),
  );
}


class SchermataPrenota extends StatelessWidget {
  const SchermataPrenota({super.key});

  @override
  Widget build(BuildContext context) {
    //metto il TabController che racchiude lo scaffold così tutto varia in base al tab selezionato
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Prenota"),
          titleSpacing: 10,
          //Inseriamo i due TAB previsti con i titoli
          bottom: const TabBar(
            tabs: [
              Tab(text: "Esami"),
              Tab(text: "Guide"),
            ],
            indicatorColor: Color(0xFFDEE1F3),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        //In base al tab selezionato, viene visualizzata la pagina di riferimento
        body: const TabBarView(
          children: [
            Center(child: Text("Esami disponibili per la prenotazione:")),
            Center(child: Text("Guide disponibili per la prenotazione:")),





          ],
        ),
      ),
    );
  }
}
