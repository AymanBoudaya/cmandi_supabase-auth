import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            toolbarTextStyle: TextStyle(color: Colors.white)));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text("Résultats pour '$query'"));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: ["Produit A", "Produit B", "Produit C"]
          .where((p) => p.toLowerCase().contains(query.toLowerCase()))
          .map((suggestion) => ListTile(
                title: Text(suggestion),
                onTap: () => query = suggestion,
              ))
          .toList(),
    );
  }
}
