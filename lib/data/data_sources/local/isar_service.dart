import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokedex_app/data/models/pokemon_model.dart';

class IsarService{
  late Future<Isar> db;

  IsarService(){
    db = openDB();
}
  Future<void> savePokemon(Pokemon newPokemon) async{
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.pokemons.putSync(newPokemon));
  }

  Future<List<Pokemon>> getAllPokemon() async {
    final isar = await db;
    return await isar.pokemons.where().findAll();
  }

  Future<Isar> openDB() async {
    if(Isar.instanceNames.isEmpty){
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open([PokemonSchema], inspector: true,directory: dir.path);
    }
    return  Future.value(Isar.getInstance());
  }

  Future<void> cleanDB() async{
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }


}