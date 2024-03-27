import 'package:flutter/material.dart';

import '../../services/map/place_service.dart';


class AddressSearch extends SearchDelegate<Suggestion> {

  final String sessionToken;

  AddressSearch(this.sessionToken);



  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Suggestion('', ''));
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.0),
        // child: Text('Enter your address'),
      );
    } else {
      // Create an instance of PlaceApiProvider
      final placeApiProvider = PlaceApiProvider(sessionToken);

      return FutureBuilder(
        future: placeApiProvider.fetchSuggestions(query, 'en'), // Pass query and language
        builder: (context, AsyncSnapshot<List<Suggestion>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint("SNAPPPP ERROOOOR: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final suggestion = snapshot.data?[index];
                return ListTile(
                  title: Text(suggestion != null ? suggestion.description : "nope"),
                  onTap: () {
                    close(context, suggestion!);
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No suggestions found'));
          }
        },
      );
    }
  }


  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }
}
