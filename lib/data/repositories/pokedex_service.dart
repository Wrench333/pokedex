import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/pokemon_model.dart';

class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;

  UserAgentClient(this.userAgent, this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}

class PokeAPI {
  String baseUrl = 'https://pokeapi.co/api/v2/';
  final client = UserAgentClient("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36",http.Client());

  Future<List<Pokemon>> getPokemonList() async {
    try {
      final response = await client
          .get(Uri.parse(baseUrl + "pokemon/?offset=0&limit=20"),);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('$data');
        List<Pokemon> pokemonList = [];
        for (int i =0; i<data['results'].length;i++){
          pokemonList.add(await getPokemon(data['results'][i]['name']));
        }
        return pokemonList;
      } else {
        throw Exception(
            'Failed to load pokemon list, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon list: $e');
    }
  }

  Future<Pokemon> getPokemon(String request) async {
    try {
      final response = await client
          .get(Uri.parse(baseUrl + "pokemon/$request/"),);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('$data');
        Pokemon pokemon = Pokemon.fromJson(data);
        pokemon.description = await getPokemonDesc(pokemon.id);
        return pokemon;
      } else {
        throw Exception(
            'Failed to load pokemon details, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon details: $e');
    }
  }

  Future<String> getPokemonDesc(int id) async {
    try {
      final response = await client
          .get(Uri.parse(baseUrl + "characteristic/$id/"),);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('$data');

        return data['descriptions'][7]['description'];
      } else {
        throw Exception(
            'Failed to load pokemon description, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load pokemon description: $e , $id');
    }
  }
}

//json['descriptions'][0]['description']