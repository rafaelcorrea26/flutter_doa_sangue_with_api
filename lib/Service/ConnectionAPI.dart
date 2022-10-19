import 'package:doa_sangue/Utils/UserSecureStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Model/Usuario.dart';

class ConnectionAPI{
  static const urlAPI = "https://doa-sangue-api.online/api/";

  static Future<bool> Login(email , senha) async {

    var url = Uri.parse(urlAPI + 'login');
    url = url.replace(queryParameters: {'email': email, 'senha': senha});

    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      Usuario usuario = Usuario();
      UserSecureStorage.setToken(json.decode(response.body)["token"]) ;
      usuario =  Usuario.fromMap(json.decode(response.body)["usuario"]);
      UserSecureStorage.setUsuario(usuario.toString()) ;
      return true;
    } else {
      return false;
    }
  }

}