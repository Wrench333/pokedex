class Pokemon {
  int id;
  String name;
  String type;
  String description;
  String url;

  Pokemon({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.url,
});


  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id:json['id'] ,
      name: json['name'],
      type: json['types'][0]['type']['name'],
      description: '',
      url: json['sprites']['other']['official-artwork']['front_default'],
    );
  }
}
