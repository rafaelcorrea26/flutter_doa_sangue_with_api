import 'dart:io';
import 'dart:convert';
import 'ConnectionAPI.dart';
import '../Model/Horario.dart';
import 'package:http/http.dart' as http;
import 'package:doa_sangue/Utils/UserSecureStorage.dart';

class HorarioRest {
  String? _token;
  var _url = Uri.parse(ConnectionAPI.urlAPI + 'horario');

// GET
  Future<Horario> getHorario(id) async {
    Horario _horario  = Horario();
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'horario/' +id.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) { // Valida se nao existe o token na memoria
      exit(0);// fecha o app
    }

    final _response = await http.get(_urlID, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (_response.body != '[]')) {
      _horario =  Horario.fromMap(json.decode(_response.body)["horario"]);
    }
    return _horario;
  }

  Future<Horario> get_pelo_agendamento(idAge) async {
    Horario _horario  = Horario();
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'horario/agendamento/' +idAge.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) {// Valida se nao existe o token na memoria
      exit(0); // fecha o app
    }

    final _response = await http.get(_urlID, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (_response.body != '[]')) {
      _horario =  Horario.fromJson(json.decode(_response.body)["horario"]);
    }
    return _horario;
  }


  Future<List<String>> get_dias_disponiveis(String dia) async {
    List<String> lista = [];
    List<DateTime> dataList = [];
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'horario/horarios_disponiveis/' + dia);

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) {// Valida se nao existe o token na memoria
      exit(0); // fecha o app
    }

    final _response = await http.get(_urlID, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (_response.body != '[]')) {
      List<dynamic> _list = jsonDecode(_response.body);
      print(_list);
      lista = _list.cast<String>();
      print(lista);


      //print(json.decode(_response.body));
      // List<Timer> hour = json.decode(_response.body);
      //lista = json.decode(_response.body);
    }
    return lista;
  }

// POST
  Future<int> postHorario(Horario _horario) async {
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }
      var _response = await http.post(_url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: _horario.toJson());

      if ((_response.statusCode == 201) & (json.decode(_response.body)["horario"] != '[]')) {
        _horario =  Horario.fromMap(json.decode(_response.body)["horario"]);
        return _horario.id;
      } else {
        return 0;
      }
    } catch (ex) {
      print(ex);
      return 0;
    }
  }

// PUT
  Future<String> putHorario(Horario horario) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'horario/' +horario.id.toString());
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }
      var _resposta = await http.put(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: horario.toJson());

      if (_resposta.statusCode == 200) {
        return "Horário Alterado!";
      } else {
        return "Horário não Alterado!";
      }
    } catch (ex) {
      print(ex);
      return "Horário não Alterado!";
    }
  }

//delete
  Future<String> deleteHorario(int id) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'horario/' +id.toString());
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0);// fecha o app
      }
      var _resposta = await http.delete(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      if (_resposta.statusCode == 200) {
        return "Horário deletado!";
      } else {
        return "Horário não deletado!";
      }

    } catch (ex) {
      print(ex);
      return "Horário não deletado!";
    }
  }
}