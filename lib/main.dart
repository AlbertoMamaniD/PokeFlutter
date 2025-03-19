import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  List pokemonList = [];
  bool cargar = true;
  bool cargarMas = false;
  int offset = 0;
  final int limit = 25;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPokemon();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent &&
          !cargarMas) {
        loadMorePokemon();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void fetchPokemon() {
    String url = 'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset';

    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        Map data = json.decode(response.body);
        List results = data['results'];

        for (var result in results) {
          fetchPokemonDetails(result['url']);
        }

        setState(() {
          offset += limit;
          cargar = false;
        });
      }
    });
  }

  void fetchPokemonDetails(String url) {
    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        Map data = json.decode(response.body);

        var pokemon = {
          'name': data['name'] ?? 'Unknown',
          'height': data['height'] ?? 0,
          'weight': data['weight'] ?? 0,
          'imageUrl': data['sprites']['front_default'] ?? 'https://via.placeholder.com/150',
        };

        setState(() {
          pokemonList.add(pokemon);
        });
      }
    });
  }

  void loadMorePokemon() {
    setState(() {
      cargarMas = true;
    });

    fetchPokemon();

    setState(() {
      cargarMas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
      ),
      body: cargar
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: pokemonList.map((pokemon) {
                        return Card(
                          color: Colors.green[100],
                          child: SizedBox(
                            width: 150,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(pokemon['imageUrl'], width: 100, height: 100),
                                  Text(pokemon['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Peso: ${pokemon['weight']}'),
                                  Text('Altura: ${pokemon['height']}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (cargarMas)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}