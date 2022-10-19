import 'dart:io';
import 'dart:convert';
import 'ConnectionAPI.dart';
import '../Model/Usuario.dart';
import 'package:http/http.dart' as http;
import 'package:doa_sangue/Utils/UserSecureStorage.dart';

class UsuarioRest {
  String? _token;
  var _url = Uri.parse(ConnectionAPI.urlAPI + 'usuario');

// GET
  Future<String> getUsuario(email, senha) async {
    _token = await UserSecureStorage.getToken();

    if ((_token == '') | (_token == null)) { // Faz login na api e salva o token e usuario na memoria
      await ConnectionAPI.Login(email, senha);
      _token = await UserSecureStorage.getToken();
    }

    final _resposta = await http.get(_url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if (_resposta.statusCode == 200) {
      return "Usuário carregado!";
    } else {
      return "Usuário não carregado!";
    }
  }

// POST
  Future<bool> postUsuario(Usuario usuario) async {
    try {
      var _response = await http.post(_url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      } , body: usuario.toJson());

      if ((_response.statusCode == 201) & (json.decode(_response.body)["usuario"] != '[]')) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      return false;
    }
  }

// PUT
  Future<String> putUsuario(Usuario usuario) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'usuario/' +usuario.id.toString());
    try {
      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }

      var _resposta = await http.put(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: usuario.toJson());

      if (_resposta.statusCode == 200) {
        UserSecureStorage.setUsuario(usuario.toString());
        return "Usuário Alterado!";
      } else {
        return "Usuário não Alterado!";
      }

    } catch (ex) {
      return "Usuário não Alterado!";
    }

  }

  Future<String> putSenhaUsuario(id,senha) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'usuario/' +id.toString());
    try {
      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }

      var _resposta = await http.put(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: '{"senha":"$senha"}');

      if (_resposta.statusCode == 200) {
        return "Senha do Usuário Alterada com sucesso!";
      } else {
        return "Senha do Usuário não Alterada!";
      }

    } catch (ex) {
      return "Usuário não Alterado!";
    }
  }

//DELETE
  Future<String> deleteUsuario(int id) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + '/usuario/' +id.toString());
    try {

      if ((_token == '') | (_token == null)) {
        // fecha o app
      }
      var _resposta = await http.delete(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      if (_resposta.statusCode == 200) {
        return "Usuário Deletado!";
      } else {
        return "Usuário não Deletado!";
      }

    } catch (ex) {
      return "Usuário não Deletado!";
    }

  }
}