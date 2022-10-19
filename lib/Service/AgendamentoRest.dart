import 'dart:io';
import 'dart:convert';
import 'ConnectionAPI.dart';
import '../Model/Agendamento.dart';
import 'package:http/http.dart' as http;
import 'package:doa_sangue/Utils/UserSecureStorage.dart';

class AgendamentoRest {
  String? _token;
  Agendamento _agendamento = Agendamento();
  var _url = Uri.parse(ConnectionAPI.urlAPI + 'agendamento');

// GET
  Future<Agendamento> getAgendamento(int id) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'agendamento/' +id.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) { // Valida se nao existe o token na memoria
      exit(0);// fecha o app
    }

    final _response = await http.get(_urlID, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (json.decode(_response.body)["agendamento"] != '[]')) {
      _agendamento =  Agendamento.fromMap(json.decode(_response.body)["agendamento"]);
    }
    return _agendamento;
  }


  Future<List<Agendamento>> getAllAgendamento(idDoador) async {
    List<Agendamento> agendamento = [];
    var _urlDoador = Uri.parse(ConnectionAPI.urlAPI + 'agendamento/doador/' +idDoador.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) { // Valida se nao existe o token na memoria
      exit(0);// fecha o app
    }


    final _response = await http.get(_urlDoador, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (json.decode(_response.body)["agendamento"] != '[]')) {
     List<dynamic> _list = jsonDecode(_response.body)["agendamento"] ;
     agendamento = _list.map((json) => Agendamento.fromJson(json)).toList();
  }
      return agendamento;
    }

  Future<int> getDataUltimoAgendamento(String novaDataAgendamento,int idDoador) async {
    String _ultima_data = '2022-01-01';
    var _urlDoador = Uri.parse(ConnectionAPI.urlAPI + 'agendamento/ultimo_doacao/' +idDoador.toString());

    _token = await UserSecureStorage.getToken();
    if ((_token == '') | (_token == null)) { // Valida se nao existe o token na memoria
      exit(0);// fecha o app
    }


    final _response = await http.get(_urlDoador, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });

    if ((_response.statusCode == 200) & (json.decode(_response.body)["agendamento"] != '[]')) {
      _ultima_data= jsonDecode(_response.body)["agendamento"][0]["ultimo_data"];
    }
    DateTime dtUltima = DateTime.parse(_ultima_data);
    DateTime dtNova = DateTime.parse(novaDataAgendamento);
    Duration _diasDesdeUltimoAgendamento = dtNova.difference(dtUltima);

  return  _diasDesdeUltimoAgendamento.inDays;
  }

// POST
  Future<int> postAgendamento(Agendamento agendamento) async {
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0); // fecha o app
      }
      var _resposta = await http.post(_url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: agendamento.toJson());

      if (_resposta.statusCode == 201) {
        return  json.decode(_resposta.body)["agendamento"]["id"];
      } else {
        return 0;
      }

    } catch (ex) {
      print(ex);
      return 0;
    }
  }

// PUT
  Future<String> putAgendamento(Agendamento agendamento) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'agendamento/' +agendamento.id.toString());
    try {

      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0); // fecha o app
      }
      var _resposta = await http.put(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } , body: agendamento.toJson());

      if (_resposta.statusCode == 200) {
        return "Agendamento Alterado!";
      } else {
        return "Agendamento não Alterado!";
      }
    } catch (ex) {
      print(ex);
      return "Agendamento não Alterado!";
    }
  }

//DELETE
  Future<String> deleteAgendamento(int id) async {
    var _urlID =  Uri.parse(ConnectionAPI.urlAPI + 'agendamento/' +id.toString());
    try {
      _token = await UserSecureStorage.getToken();
      if ((_token == '') | (_token == null)) {
        exit(0); // fecha o app
      }
      var _resposta = await http.delete(_urlID, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      } );

      if (_resposta.statusCode == 200) {
        return "Agendamento Deletado!";
      } else {
        return "Agendamento não Deletado!";
      }
    } catch (ex) {
      print(ex);
      return "Agendamento não Deletado!";
    }
  }
}