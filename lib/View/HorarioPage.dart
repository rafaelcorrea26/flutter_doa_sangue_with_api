import 'dart:async';

import 'package:doa_sangue/Model/Horario.dart';
import 'package:doa_sangue/Service/HorarioRest.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Utils/FormatadorData.dart';

class HorarioPage extends StatefulWidget {
  String dataAgendamento;

  HorarioPage(this.dataAgendamento);

  @override
  State<HorarioPage> createState() => _HorarioPageState();
}
List<String> lista_horarios = [];
HorarioRest _HorarioRest = HorarioRest();

class _HorarioPageState extends State<HorarioPage> {
  var _dataString;


  Future _listarTodosHorarios() async {
    List<String> lista = [];
    await Future.delayed(const Duration(milliseconds: 100));

    _dataString = ConverteDataParaDataAPI(widget.dataAgendamento);
     lista = await _HorarioRest.get_dias_disponiveis(_dataString);

    widget.dataAgendamento = ConverteDataParaDataAPI(widget.dataAgendamento)!;

    lista_horarios = lista;
  }

  //Constroi a lista apenas apos a leitura dos dados
  _listagemFutura() {
    return FutureBuilder(
        future: _listarTodosHorarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return _listaDosHorarios();
          }
        });
  }

  _listaDosHorarios() {
    return
      ListView.builder(
        padding: const EdgeInsets.all(40.0),
        itemCount: lista_horarios.length,
        itemBuilder: (context, index) {
          return GestureDetector(
             child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, lista_horarios[index]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red[400],
                      alignment: Alignment.center,
                      child: Text(lista_horarios[index].toString(),
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  _barraSuperior() {
    return AppBar(
      title: Text("Selecione um Horário Disponível"),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _barraSuperior(),
      body: _listagemFutura(),
    );
  }}

