import 'dart:convert' as convert;
import '../Utils/UserSecureStorage.dart';

class Usuario {
  int id = 0;
  String nome = "";
  String login = "";
  String email = "";
  String senha = "";
  String imagem = "";
  // Constructor
  Usuario();

  Map<String, Object> toMap() {
    Map<String, Object> map = {
      'nome': nome,
      'login': login,
      'email': email,
      'senha': senha,
      'imagem': imagem,
    };
    if (id > 0) {
      map["id"] = id;
    }
    return map;
  }

  Usuario.fromMap(Map map) {
    id = map['id'];
    nome = map['nome'];
    login = map['login'];
    email = map['email'];
    senha = map['senha'];
    imagem = map['imagem'];
  }

  @override
  String toString() {
    return '{"usuario":{"id":$id,"nome":"$nome","login":"$login","email":"$email","imagem":"$imagem","senha":"$senha"}}';
  }

  String toJson() {
    if  (senha == ''){
      return '{"nome":"$nome","login":"$login","email":"$email","imagem":"$imagem"}';
    } else{
      return '{"nome":"$nome","login":"$login","email":"$email","senha":"$senha","imagem":"$imagem"}';
    }
  }

// Parte onde trabalho com os dados salvando localmente ao logar
  void saveLocal() async{
    Map map = toMap();
    String json = convert.json.encode(map);
    UserSecureStorage.setUsuario(json);
  }

  static Future<Usuario> getLocal() async{
    String? json = await UserSecureStorage.getUsuario();
    return Usuario.fromMap(convert.json.decode(json!)["usuario"]);
  }
}
