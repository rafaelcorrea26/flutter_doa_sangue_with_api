import 'dart:io';
import 'dart:convert';
import 'ConnectionAPI.dart';
import '../Model/Doador.dart';
import 'package:http/http.dart' as http;
import 'package:doa_sangue/Utils/UserSecureStorage.dart';

class DoadorRest {
  String? _token;
  var _url = Uri.parse(ConnectionAPI.urlAPI + 'doador');

// GET
  Future<Doador> getDoador(id) async {
    Doador doador  = Doador();
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'doador/' +id.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) {// Valida se nao existe o token na memoria
      exit(0); // fecha o app
    }

    final _response = await http.get(_urlID, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (json.decode(_response.body)["doador"] != '[]')) {
      doador =  Doador.fromMap(json.decode(_response.body)["doador"]);
    }
    return doador;
  }

  Future<Doador> getDoadorpeloIdUsuario(idUsu) async {
    Doador doador  = Doador();
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'doador/usuario/' +idUsu.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) {// Valida se nao existe o token na memoria
      exit(0); // fecha o app
    }

    final _response = await http.get(_urlID, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });
    if ((_response.statusCode == 200) & (json.decode(_response.body)["doador"] != '[]')) {
      doador =  Doador.fromMap(json.decode(_response.body)["doador"]);
    }
    return doador;
  }

// POST
  Future<int> postDoador(Doador doador) async {
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }
      var _response = await http.post(_url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: doador.toJson());

      if ((_response.statusCode == 200) & (json.decode(_response.body)["doador"] != '[]')) {
        doador =  Doador.fromMap(json.decode(_response.body)["doador"]);
        return doador.id;
      } else {
        return 0;
      }
    } catch (ex) {
      return 0;
    }
  }

// PUT
  Future<String> putDoador(Doador doador) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'doador/' +doador.id.toString());
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }

      var _resposta = await http.put(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: doador.toJson());

      if (_resposta.statusCode == 200) {
        return "Doador Alterado!";
      } else {
        return "Doador não Alterado!";
      }

    } catch (ex) {
      return "Doador não Alterado!";
    }
  }

//DELETE
  Future<String> deleteDoador(int id) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'doador/' +id.toString());
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);
      }
      var _resposta = await http.delete(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      if (_resposta.statusCode == 200) {
        return "Doador Deletado!";
      } else {
        return "Doador não Deletado!";
      }

    } catch (ex) {
      return "Doador não Deletado!";
    }

  }
}