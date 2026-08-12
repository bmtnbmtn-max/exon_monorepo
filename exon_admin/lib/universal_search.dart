import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UniversalSearchDelegate extends SearchDelegate {
  final String tableName;
  final String searchField;
  final Function(Map<String, dynamic>) onSelected;

  UniversalSearchDelegate({
    required this.tableName,
    required this.searchField,
    required this.onSelected,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _showResults();

  @override
  Widget buildSuggestions(BuildContext context) => _showResults();

  Widget _showResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Type something to find ...'));
    }

    return FutureBuilder(
      future: Supabase.instance.client
          .from(tableName)
          .select()
          .ilike(searchField, '%$query%'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Center(child: Text('No results'));
        }

        final results = snapshot.data as List<dynamic>;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(item[searchField] ?? 'No name'),
              subtitle: Text(item['address'] ?? ''),
              onTap: () => onSelected(item),
            );
          },
        );
      },
    );
  }
}
