import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:pokedex_app/data/data_sources/local/isar_service.dart';
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
  IsarService isarService = IsarService();

  String selectedType = '';

  @override
  void initState() {
    super.initState();
    _getLocalData();
    _fetchPokemons();
  }

  Future<void> _getLocalData() async {
    pokemons = await isarService.getAllPokemon();
  }

  Future<void> _fetchPokemons() async {
    try {
      var result = await pokeAPI.getPokemonList();
      print('Pokemon API Response: $result');
      isarService.cleanDB();
      pokemons = result;
      suggestions = result.take(20).toList();
      for (int i = 0; i < result.length; i++) {
        isarService.savePokemon(result[i]);
        names.add(result[i].name);
        types.add(result[i].type);
      }
      print(suggestions);
      print(suggestions.length);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      var result = [
        Pokemon(
            id: 1,
            name: 'Bulbasaur',
            type: 'Grass',
            description: ' ',
            url: 'https://via.placeholder.com/60x60'),
      ];
      pokemons = result;
      suggestions = result.take(20).toList();
      for (int i = 0; i < result.length; i++) {
        isarService.savePokemon(result[i]);
        names.add(result[i].name);
        types.add(result[i].type);
      }
      print(suggestions);
      print(suggestions.length);
      setState(() {
        isLoading = false;
      });
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
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Opacity(
              opacity: 1,
              child: Container(
                  height: size.height,
                  width: size.width,
                  child: Image.asset("assets/images/background.png",
                      fit: BoxFit.fitWidth)),
            ),
            /*Positioned(
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
            ),*/
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
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
                      height: size.height / 16,
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
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        controller: controller,
                        onChanged: onQueryChanged,
                        decoration: InputDecoration(
                          prefixIconColor: Colors.white,
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.black,
                          isDense: true,
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
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
                                dropdownColor: Colors.black,
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
                                      Stack(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.0),
                                            child: Image.asset(
                                                "assets/images/card1.png"),
                                          ),
                                          Container(
                                            width: size.width,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: size.height / 17,
                                                    ),
                                                    Opacity(
                                                      opacity: 1.0,
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(8.0),
                                                        width:
                                                            3 * size.width / 4 ,
                                                        height:
                                                            size.height / 3.5,
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                8, 14, 8, 18),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      17.36),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  '#${pokemon.id}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF212121),
                                                                    fontSize:
                                                                        25.20,
                                                                    fontFamily:
                                                                        'Futura BdCn BT',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    height:
                                                                        0.03,
                                                                    letterSpacing:
                                                                        -0.55,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${pokemon.name.toUpperCase()}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF212121),
                                                                    fontSize:
                                                                        35.20,
                                                                    fontFamily:
                                                                        'Futura',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    height:
                                                                        0.02,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${pokemon.type}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF212121),
                                                                    fontSize:
                                                                        25.20,
                                                                    fontFamily:
                                                                        'Futura',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    height:
                                                                        0.02,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${pokemon.description}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF212121),
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Futura',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    height:
                                                                        0.02,
                                                                    letterSpacing:
                                                                        -0.55,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 5.0,),
                                                            Container(
                                                                width:0.35*size.width,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/images/bulbasaur.png",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
