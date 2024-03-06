import 'package:flutter/material.dart';
import 'dart:io';
import 'data/models/pokemon_model.dart';
import 'data/repositories/pokedex_service.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String query = '';
  PokeAPI pokeAPI = PokeAPI();
  final controller = TextEditingController();
  List<Pokemon> suggestions = [];
  List<Pokemon> pokemons = [];

  List<String> names = [];
  Set<String> types = {'Select Type'};
  bool isLoading = true;

  String selectedType = '';

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
  }

  Future<void> _fetchPokemons() async {
    try {
      var result = await pokeAPI.getPokemonList();
      print('Pokemon API Response: $result');
      pokemons = result;
      suggestions = result.take(20).toList();
      for (int i = 0; i < result.length; i++) {
        names.add(result[i].name);
        types.add(result[i].type);
      }
      print(suggestions);
      print(suggestions.length);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error in getting pokemon list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in getting pokemon list: $e'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void onQueryChanged(String? query) {
    if (query == '' || query == null) {
      setState(() {
        suggestions = pokemons.where((pokemon) {
          final matchesType =
              (selectedType == '' || pokemon.type == selectedType);
          return matchesType;
        }).toList();
      });
    } else {
      setState(() {
        suggestions = pokemons.where((pokemon) {
          final lowerCasePokemonName = pokemon.name.toLowerCase();
          final lowerCasePokemonId = pokemon.id.toString();
          final lowerCaseQuery = query.toLowerCase();
          final matchesQuery = lowerCasePokemonName.contains(lowerCaseQuery) ||
              lowerCasePokemonId.contains(lowerCaseQuery);
          final matchesType =
              (selectedType == '' || pokemon.type == selectedType);
          return matchesQuery && matchesType;
        }).toList();
      });
      print(suggestions);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(0, 31, 63, 1),
        body: Stack(
          children: [
            Positioned(
              bottom: size.height / 3,
              right: 0.0,
              left: 0.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 50,
                        width: 59,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(25, 25, 112, 1.0),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(91.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              offset: Offset(0, 4),
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 109,
                      ),
                    ],
                  ),
                  Container(
                    height: 62,
                    width: 28,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(25, 25, 112, 1.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(91.5),
                        bottomLeft: Radius.circular(91.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          offset: Offset(0, 4),
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: size.height / 3 - 132,
              right: 0.0,
              left: 0.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 119,
                        width: 149,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(25, 25, 112, 1.0),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(91.5),
                            bottomRight: Radius.circular(91.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              offset: Offset(0, 4),
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 132,
                      ),
                    ],
                  ),
                  Container(
                    height: 148,
                    width: 114,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(25, 25, 112, 1.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(91.5),
                        bottomLeft: Radius.circular(91.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          offset: Offset(0, 4),
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 31, 63, 1),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(25, 25, 112, 1),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 5.0, 10.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'PokeDex',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 0.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13.0, 14.0, 19.0, 8.0),
                    child: Container(
                      height: size.height / 16, //TODO: Fix this dynamic shit
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.72),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 15.92,
                            spreadRadius: 0.96,
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        onChanged: onQueryChanged,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(65, 105, 225, 1),
                          isDense: true,
                          hintText: 'Search ...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13.0, 3.0, 19.0, 9.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: size.height / 23,
                            //TODO: Fix this dynamic shit
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(65, 105, 225, 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(7.72),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                  blurRadius: 15.92,
                                  spreadRadius: 0.96,
                                ),
                              ],
                            ),
                            child: Center(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: const SizedBox(
                                  height: 0,
                                ),
                                isDense: true,
                                dropdownColor:
                                    const Color.fromRGBO(65, 105, 225, 1),
                                hint: Text(
                                  " Select Type",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                value: selectedType,
                                onChanged: (value) {
                                  print('$value');
                                  setState(() {
                                    selectedType = value!;
                                  });
                                  onQueryChanged(query);
                                },
                                items: types.map((types) {
                                  return DropdownMenuItem<String>(
                                    value: types == 'Select Type' ? '' : types,
                                    child: Center(
                                      child: Text(
                                        '   $types',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        /*Expanded(
                          child: Container(
                            height: size.height / 23,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(65, 105, 225, 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(7.72),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                  blurRadius: 15.92,
                                  spreadRadius: 0.96,
                                ),
                              ],
                            ),
                            child: Center(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: const SizedBox(
                                  height: 0,
                                ),
                                isDense: true,
                                dropdownColor:
                                const Color.fromRGBO(65, 105, 225, 1),
                                hint: const Text(
                                  " Select Year",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                value: selectedYear,
                                onChanged: (value) {
                                  print('$value');
                                  setState(() {
                                    selectedYear = value!;
                                  });
                                  onQueryChanged(query);
                                },
                                items: years.map((years) {
                                  return DropdownMenuItem<String>(
                                    value: years == 'Select Year' ? '' : years,
                                    child: Center(
                                      child: Text(
                                        '   $years',
                                        style:
                                        const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  isLoading
                      ? Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            color: Colors.transparent,
                            padding:
                                const EdgeInsets.fromLTRB(13.0, 0.0, 13.0, 0.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                final pokemon = suggestions[index];
                                if (suggestions.contains(pokemon)) {
                                  return Column(
                                    children: [
                                      Opacity(
                                        opacity: 1.0,
                                        //Supposed to be 0.60 acc to figma file but didnt look right
                                        child: Container(
                                          margin: const EdgeInsets.all(8.0),
                                          height: 105,
                                          padding: const EdgeInsets.fromLTRB(
                                              23, 18, 8, 18),
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                52, 152, 219, 0.8),
                                            borderRadius:
                                                BorderRadius.circular(17.36),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 4,
                                                color:
                                                    Color.fromRGBO(0, 0, 0, 1),
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${pokemon.name}',
                                                style: const TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Id: ${pokemon.id}',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    'Type: ${pokemon.type}',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(
                                                    width: 12.0,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${pokemon.description}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox(
                                    height: 0.0,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
