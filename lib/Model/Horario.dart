import 'dart:convert';

class Horario {
  int id = 0;
  String data_marcada = "";
  String horario_marcado = "";
  int id_agendamento = 0;

  Horario();

  Map<String, Object> toMap() {
    Map<String, Object> map = {
      'id_agendamento': id_agendamento,
      'data_marcada': data_marcada,
      'horario_marcado': horario_marcado,
    };
    if (id > 0) {
      map["id"] = id;
    }
    return map;
  }

  Horario.fromMap(Map map) {
    id = map['id'];
    id_agendamento = map['id_agendamento'];
    data_marcada = map['data_marcada'];
    horario_marcado = map['horario_marcado'];
  }

  Horario.fromJson(Map <String, dynamic> json) {
    id = json['id'];
    id_agendamento = json['id_agendamento'];
    data_marcada = json['data_marcada'];
    horario_marcado = json['horario_marcado'];
  }

  @override
  String toString() {
    return '"horario"{"id": $id, '
        '"id_agendamento" : $id_agendamento, '
        '"data_marcada": "$data_marcada", '
        '"horario_marcado": "$horario_marcado"}}';
  }

  String toJson() {
    return
          '{"id_agendamento" : $id_agendamento, '
          '"data_marcada": "$data_marcada", '
          '"horario_marcado": "$horario_marcado"}';
  }
}
