class Agendamento {
  int id = 0;
  String local_doacao = "";
  String idade = "";
  String sit_saude = "";
  String status = "";
  int id_usuario = 0;
  int id_doador = 0;

  String data_marcada = ""; // Campo para mostrar data hora na lista
  String horario_marcado = ""; // Campo para mostrar data hora na lista
  Agendamento();

  Map<String, Object> toMap() {
    Map<String, Object> map = {
      'local_doacao': local_doacao,
      'idade': idade,
      'sit_saude': sit_saude,
      'status': status,
      'id_usuario': id_usuario,
      'id_doador': id_doador,
    };
    if (id > 0) {
      map["id"] = id;
    }
    return map;
  }

  Agendamento.fromMap(Map map) {
    id = map['id'];
    local_doacao = map['local_doacao'];
    idade = map['idade'];
    sit_saude = map['sit_saude'];
    status = map['status'];
    id_usuario = map['id_usuario'];
    id_doador = map['id_doador'];
  }

  Agendamento.fromJson(Map <String, dynamic> json) {
    id = json['id'];
    local_doacao = json['local_doacao'];
    idade = json['idade'];
    sit_saude = json['sit_saude'];
    status = json['status'];
    id_usuario = json['id_usuario'];
    id_doador = json['id_doador'];
    data_marcada = json['data_marcada'];
    horario_marcado = json['horario_marcado'];
  }


  @override
  String toString() {
    return
        '{"Agendamento"{"id": $id, '
        '"local_doacao": $local_doacao,'
        '"idade": $idade,'
        '"sit_saude": $sit_saude,'
        '"status": $status,'
        '"id_usuario": $id_usuario,'
        '"id_doador": $id_doador}}';
  }

  String toJson() {
      return
          '{"local_doacao": "$local_doacao",'
          '"idade": "$idade",'
          '"sit_saude": "$sit_saude",'
          '"status": "$status",'
          '"id_usuario": $id_usuario,'
          '"id_doador": $id_doador}';
  }
}
