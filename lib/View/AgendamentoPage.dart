import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Model/Doador.dart';
import '../Model/Horario.dart';
import '../Model/Usuario.dart';
import '../Service/AgendamentoRest.dart';
import '../Service/DoadorRest.dart';
import '../Service/HorarioRest.dart';
import '../Utils/FormatadorData.dart';
import '../Utils/Validators.dart';
import '../Model/Agendamento.dart';
import 'AgendamentoMapaPage.dart';
import 'HorarioPage.dart';

class AgendamentoPage extends StatefulWidget {
  bool Requisitos;
  Agendamento agendamento;

 AgendamentoPage(this.Requisitos, this.agendamento);

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  Usuario _usuario = Usuario();
  Doador _doador = Doador();
  Horario _horario = Horario();
  Agendamento _agendamento = Agendamento();
  AgendamentoRest helperAgendamento = AgendamentoRest();
  DoadorRest helperdoador = DoadorRest();
  HorarioRest helperHorario = HorarioRest();

  int _idAgendamento = 0;
  String _dataNasc = "";


  final _formKey = GlobalKey<FormState>();
  bool checkboxValue = false;
  String _dropdownSitValue = 'Bem';
  List<String> _sitSaude = ['Bem', 'Ruim'];

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _idadeController = TextEditingController();
  TextEditingController _localController = TextEditingController();
  TextEditingController _dataController = TextEditingController();
  TextEditingController _horaController = TextEditingController();
  TextEditingController _statusController = TextEditingController();

  DateTime _date = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        locale: Locale("pt"),
        context: context,
        initialDate: _date,
        firstDate:DateTime.now(),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                    onPrimary: Colors.white, // selected text color
                    onSurface: Colors.red, // default text color
                    primary: Colors.red // circle color
                    ),
                dialogBackgroundColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'Quicksand'),
                        primary: Colors.red, // color of button's letters
                        backgroundColor: Colors.white, // Background color
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.white, width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50))))),
            child: child!,
          );
        });
    if (picked != null && picked != _date) {
      setState(() {
        _dataController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future<Null> _selectLocal(BuildContext context) async {
    final retorno = await Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentoMapaPage()));

    if (retorno != '') {
      _localController.text = retorno;
    } else {
      _localController.clear();
    }
  }

  Future<Null> _selectHour(BuildContext context) async {
    final retorno = await Navigator.push(context, MaterialPageRoute(builder: (context) => HorarioPage(_dataController.text)));

    if (retorno != '') {
      _horaController.text = retorno;
    } else {
      _horaController.clear();
    }
  }

  Future _carregaCamposAgendamento() async {
    _usuario  = await Usuario.getLocal();
    _doador = await helperdoador.getDoadorpeloIdUsuario(_usuario.id);
   _dataNasc = DateFormat("dd/MM/yyyy").format(DateTime.parse(_doador.data_nasc));

    _nomeController.text = _usuario.nome;
    _idadeController.text = RetornaIdadeAtualizada(_dataNasc).toString();
    if (widget.agendamento.id > 0) {
      _agendamento = widget.agendamento;
      _idadeController.text = _agendamento.idade;
      _statusController.text = _agendamento.status;
      _dropdownSitValue = _agendamento.sit_saude;
      _localController.text = _agendamento.local_doacao;

      _horario = await helperHorario.get_pelo_agendamento(_agendamento.id);
      _dataController.text = DateFormat("dd/MM/yyyy").format(DateTime.parse(_horario.data_marcada));
      _horaController.text = _horario.horario_marcado;
    } else {
      _agendamento.id_doador = 0;
      _agendamento.id = 0;
      _dropdownSitValue = "Bem";
      _statusController.text  = "Pendente";
    }
  }

  Future _cadastrarAgendamento() async {
    int? _idade = RetornaIdadeAtualizada(_dataNasc);

    if((_idade > 15) & (_idade <  18)){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menores de 18 anos precisam da autorização dos pais no dia da doação.'),),);
    }

    if ((_idade > 15) & (_idade < 69)){
      _agendamento.idade = _idadeController.text;
      _agendamento.status = _statusController.text ;
      _agendamento.sit_saude = _dropdownSitValue;
      _agendamento.local_doacao = _localController.text;
      _agendamento.id_usuario = _usuario.id;
      _agendamento.id_doador = _doador.id;
      _horario.data_marcada = ConverteDataParaDataAPI(_dataController.text)!;
      _horario.horario_marcado = _horaController.text;
      int _IntervaloDiasGenero = 0;
      int _qtdDiasUltimaDoacao = await helperAgendamento.getDataUltimoAgendamento(_horario.data_marcada, _doador.id);

      if(_doador.genero == 'Masculino') {
        _IntervaloDiasGenero = 60;
      } else {
        _IntervaloDiasGenero = 90;
      }

     if (_qtdDiasUltimaDoacao > _IntervaloDiasGenero){
       if (_agendamento.id > 0) {
         helperAgendamento.putAgendamento(_agendamento);
         helperHorario.putHorario(_horario);
       } else {
         _idAgendamento = await helperAgendamento.postAgendamento(_agendamento);

         if (_idAgendamento > 0 ){
           _horario.id_agendamento = _idAgendamento;
           helperHorario.postHorario(_horario);
         }

       }
       Navigator.pop(context, false);
     }
    else{
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro! Não faz $_IntervaloDiasGenero dias desde a última doação.')),);
    }
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro! Sua idade deve ser entre 16-69 anos para doar sangue.')),);
    }
  }


  barraSuperior() {
    return AppBar(
      title: Text("Cadastro de Agendamento"),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  @override
  void initState() {
    super.initState();
    _carregaCamposAgendamento().then;
    setState(() {});
  }

  Widget corpo(context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 40, right: 40),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            TextFormField(
              enabled: false,
              controller: _nomeController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Nome Usuário/Doador",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            TextFormField(
              validator: Validators.required('Idade não pode ficar em branco.'),
              enabled: false,
              controller: _idadeController,
              inputFormatters: [LengthLimitingTextInputFormatter(50), FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Idade",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            TextFormField(
              validator: Validators.required('Status não pode ficar em branco.'),
              enabled: false,
              controller: _statusController,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Status",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                labelText: 'Situação saúde',
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              value: _dropdownSitValue,
              // icon: const Icon(Icons.),
              elevation: 16,
              style: const TextStyle(color: Colors.black38),
              onChanged: (String? newValue) {
                setState(() {
                  _dropdownSitValue = newValue!;
                });
              },
              items: _sitSaude.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              validator: Validators.required('Local de agendamento não pode ficar em branco.'),
              controller: _localController,
              decoration: InputDecoration(
                labelText: "Local de Agendamento",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
                contentPadding: EdgeInsets.only(top: 20),
                isDense: true,
                hintText: "Local de Agendamento",
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(Icons.location_city),
                ),
              ),
              style: TextStyle(
                fontSize: 18,
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _selectLocal(context);
              },
            ),
            TextFormField(
              validator: Validators.required('Data Agendamento não pode ficar em branco.'),
              controller: _dataController,
              decoration: InputDecoration(
                labelText: "Data Agendamento",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
                contentPadding: EdgeInsets.only(top: 20),
                isDense: true,
                hintText: "Data Agendamento",
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(Icons.calendar_today),
                ),
              ),
              style: TextStyle(
                fontSize: 18,
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (_localController.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Local não pode estar vazia para escolher a data.')));
                } else {
                  _selectDate(context);
                }
              },
            ),
            TextFormField(
              validator: Validators.required('Horário de Agendamento não pode ficar em branco.'),
              controller: _horaController,
              decoration: InputDecoration(
                labelText: "Horário Agendamento",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
                contentPadding: EdgeInsets.only(top: 20),
                isDense: true,
                hintText: "Horário Agendamento",
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(Icons.alarm),
                ),
              ),
              style: TextStyle(
                fontSize: 18,
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (_localController.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Local não pode estar vazia para escolher o horário.')));
                } else
                if (_dataController.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data não pode estar vazia para escolher o horário.')));
                } else
                {
                  _selectHour(context);
                }
              },
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Color(0XFFEF5350),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: SizedBox.expand(
                child: TextButton(
                  child: Text(
                    "Cadastrar/Alterar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _cadastrarAgendamento();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro! Existem campos em branco ou preenchidos incorretamente.')),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              child: TextButton(
                child: Text(
                  "Cancelar",
                  textAlign: TextAlign.center,
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  barraSuperiorRequisitoDoar() {
    return AppBar(
      title: Text("Cadastro de Agendamento"),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  Widget aceitaTermos(context) {
    return FormField<bool>(
      validator: (value) {
        if (!checkboxValue) {
          return 'Você precisa aceitar os termos';
        } else {
          return null;
        }
      },
      builder: (state) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Checkbox(
                      value: checkboxValue,
                      onChanged: (value) {
                        setState(() {
                          checkboxValue = value!;
                          state.didChange(value);
                        });
                      }),
                  Text(
                    'Confirmo que estou apto a fazer a doação.',
                    style: TextStyle(fontSize: 12, height: 0.6, color: Colors.black),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
              Text(
                state.errorText ?? '',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  botaoContinuarRequisitoDoar() {
    return TextButton(
      child: const Text(
        "Continuar",
        textAlign: TextAlign.center,
      ),
      onPressed: () {
        if (checkboxValue) {
          setState(() {
            widget.Requisitos = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro!Doador deve ser criado antes de utilizar a tela de agendamentos.')),
          );
          setState(() {
            widget.Requisitos = true;
          });
        }
      },
    );
  }

  requisitoDoar(requisito) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Center(
          child: Text(
            requisito,
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal, fontFamily: 'Poppins'),
          ),
        ),
      ),
    );
  }

  headerRequisitoDoar(requisito) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            requisito,
            style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.normal, fontFamily: 'Poppins'),
          ),
        ),
      ),
    );
  }

  Widget corpoRequisitoDoar(context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 40, right: 40),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            headerRequisitoDoar("Recomendações:"),
            requisitoDoar("Estar alimentado. Evite alimentos gordurosos nas 3 horas que antecedem a doação de sangue."),
            requisitoDoar("Caso seja após o almoço, aguardar 2 horas."),
            requisitoDoar("Ter dormido pelo menos 6 horas nas últimas 24 horas."),
            requisitoDoar("Pessoas com idade entre 60 e 69 anos só poderão doar sangue se já o tiverem feito antes dos 60 anos."),
            requisitoDoar(
                "A frequência máxima é de quatro doações de sangue anuais para o homem e de três doações de sangue anuais para as mulher."),
            requisitoDoar(
                "O intervalo mínimo entre uma doação de sangue e outra é de dois meses para os homens e de três meses para as mulheres."),
            headerRequisitoDoar("Impedimentos:"),
            requisitoDoar("Resfriado e febre: aguardar 7 dias após o desaparecimento dos sintomas;"),
            requisitoDoar("Período gestacional"),
            requisitoDoar("Período pós-gravidez: 90 dias para parto normal e 180 dias para cesariana"),
            requisitoDoar("Amamentação: até 12 meses após o parto"),
            requisitoDoar("Ingestão de bebida alcoólica nas 12 horas que antecedem a doação"),
            requisitoDoar(
                "Tatuagem e/ou piercing nos últimos 12 meses (piercing em cavidade oral ou região genital impedem a doação);"),
            requisitoDoar("Extração dentária: 72 horas"),
            requisitoDoar("Apendicite, hérnia, amigdalectomia, varizes: 3 meses"),
            requisitoDoar(
                "Colecistectomia, histerectomia, nefrectomia, redução de fraturas, politraumatismos sem seqüelas graves, tireoidectomia, colectomia: 6 meses"),
            requisitoDoar("Transfusão de sangue  a menos de  1 ano da data que deseja doar"),
            requisitoDoar("Exames/procedimentos com utilização de endoscópio nos últimos 6 meses"),
            requisitoDoar(
                "Ter sido exposto a situações de risco acrescido para infecções sexualmente transmissíveis (aguardar 12 meses após a exposição)"),
            headerRequisitoDoar("Quais são os impedimentos definitivos para doar sangue?"),
            requisitoDoar("Ter passado por um quadro de hepatite após os 11 anos de idade"),
            requisitoDoar(
                "Evidencia clinica ou laboratorial das seguintes doenças de sangue: Hepatites B e C, AIDS( virus HIV), doenças associadas aos virus HTLV I e II e doença de chagas"),
            requisitoDoar("Uso de drogas ilícitas injetáveis e malaria. "),
            aceitaTermos(context),
            botaoContinuarRequisitoDoar(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget.Requisitos ? corpoRequisitoDoar(context) : corpo(context),
        appBar: widget.Requisitos ? barraSuperior() : barraSuperiorRequisitoDoar());
  }
}
