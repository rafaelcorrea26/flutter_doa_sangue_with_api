import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Model/Doador.dart';
import '../Model/Usuario.dart';
import '../Service/DoadorRest.dart';
import '../Utils/FormatadorData.dart';
import '../Utils/ImagemHelper.dart';
import '../Utils/Validators.dart';

class CadastroDoadorPage extends StatefulWidget {
  @override
  _CadastroDoadorPage createState() => _CadastroDoadorPage();
  Usuario usuario = Usuario();
  Doador doador = Doador();

  CadastroDoadorPage(this.usuario,this.doador);
}

class _CadastroDoadorPage extends State<CadastroDoadorPage> {
  // Combos
  String _dropdownTipoValue = 'Doador';
  String _dropdownGenValue = 'Outro';
  String _dropdownSangValue = 'A+';
  String _dropdownUFValue = 'RS';
  String _Titulo= 'Cadastro Doador/Solicitante';

  List<String> _genero = ['Masculino', 'Feminino', 'Outro'];
  List<String> _tipo_Doador = ['Doador', 'Solicitante', 'Ambos'];
  List<String> _tipo_Sangue = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _estado = [
    'AC',
    'AL',
    'AM',
    'AP',
    'BA',
    'CE',
    'DF',
    'ES',
    'FN',
    'GO',
    'MA',
    'MG',
    'MS',
    'MT',
    'PA',
    'PB',
    'PE',
    'PI',
    'PR',
    'RJ',
    'RN',
    'RO',
    'RR',
    'RS',
    'SC',
    'SE',
    'SP',
    'TO'
  ];

  // Variaveis globais
  var CaminhoImagem = "assets/pictures/profile-picture.jpg";
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  Doador _doador = Doador();
  Usuario _usuario = Usuario();
  DoadorRest _doadorRest = DoadorRest();
  bool _tipoDoador = false;
  bool _doadorExiste = false;
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _nome_maeController = TextEditingController();
  TextEditingController _nome_paiController = TextEditingController();
  TextEditingController _data_nascController = TextEditingController();
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _rgController = TextEditingController();
  TextEditingController _celularController = TextEditingController();
  TextEditingController _id_carteiraController = TextEditingController();
  TextEditingController _email_doadorController = TextEditingController();
  TextEditingController _email_solicitanteController = TextEditingController();
  TextEditingController _local_internacaoController = TextEditingController();
  TextEditingController _motivoController = TextEditingController();
  TextEditingController _qtd_bolsasController = TextEditingController();


  // Functions
  Future<Null> _selectcDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        locale: Locale("pt"),
        context: context,
        initialDate: _date,
        firstDate: DateTime(1900),
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
        _data_nascController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future _carregaCamposDoador() async {
    arquivo = null;
    imageTemp = null;
   _usuario = widget.usuario;
   _doador = widget.doador;//await _doadorRest.getDoadorpeloIdUsuario(_usuario.id);
   _doadorExiste = _doador.id >0;
    _Titulo= 'Cadastro Doador/Solicitante';

    if (_doadorExiste) {
      _Titulo= 'Edição Doador/Solicitante';
      _nomeController.text = _doador.nome_completo;
      _nome_maeController.text = _doador.nome_mae;
      _nome_paiController.text = _doador.nome_pai;
      _data_nascController.text = DateFormat("dd/MM/yyyy").format(DateTime.parse(_doador.data_nasc));
      _cpfController.text = _doador.cpf;
      _rgController.text = _doador.rg;
      _celularController.text = _doador.celular;
      _dropdownSangValue = _doador.tipo_sangue;
      _dropdownGenValue = _doador.genero;
      _dropdownUFValue = _doador.uf;
      _dropdownTipoValue = _doador.tipo_usuario;
      _id_carteiraController.text = _doador.id_carteira_doador;
      _email_doadorController.text = _doador.email_doador;
      _email_solicitanteController.text = _doador.email_solicitante;
      _local_internacaoController.text = _doador.local_internacao;
      _motivoController.text = _doador.motivo;
      _qtd_bolsasController.text = _doador.qtd_bolsas.toString();

      if ((_doador.imagem != '') && (_doador.imagem != 'assets/pictures/profile-picture.jpg') &&(_doador.imagem != null)) {
        imageTemp = File(_doador.imagem);
        setState(() => arquivo = imageTemp);
      }
    }
  }

  _CadastroDoadorPage();

  @override
  void initState() {
    super.initState();
    _carregaCamposDoador();
  }

  Future _cadastrarDoador() async {
    _doador.nome_completo = _nomeController.text;
    _doador.nome_mae = _nome_maeController.text;
    _doador.nome_pai = _nome_paiController.text;
    _doador.genero = _dropdownGenValue;
    _doador.data_nasc = ConverteDataParaDataAPI(_data_nascController.text)!;
    _doador.cpf = _cpfController.text;
    _doador.rg = _rgController.text;
    _doador.celular = _celularController.text;
    _doador.tipo_sangue = _dropdownSangValue;
    _doador.tipo_usuario = _dropdownTipoValue;
    _doador.uf = _dropdownUFValue;
    _doador.id_carteira_doador = _id_carteiraController.text;
    _doador.email_doador = _email_doadorController.text;
    _doador.imagem = verificarCaminhoImagem()!;
    _doador.id_usuario = _usuario.id;

    if (_tipoDoador) {
      _doador.email_solicitante = _email_solicitanteController.text;
      _doador.local_internacao = _local_internacaoController.text;
      _doador.motivo = _motivoController.text;

      if (_qtd_bolsasController.text != "") {
        _doador.qtd_bolsas = int.parse(_qtd_bolsasController.text);
      }
    }

    if (_doadorExiste) {
      _doadorRest.putDoador(_doador);
    } else {
      _doadorRest.postDoador(_doador);
    }

    widget.doador =_doador ;
    Navigator.pop(context, false);
  }

  bool? _montaTelaDeAcordoComTipoCadastro(String? Tipo) {
    switch (Tipo) {
      case 'Doador':
        _email_solicitanteController.clear();
        _local_internacaoController.clear();
        _motivoController.clear();
        _qtd_bolsasController.clear();
        return false;
      case 'Solicitante':
        return true;
      case 'Ambos':
        return true;
      default:
        return false;
    }
  }

  _barraSuperior() {
    return AppBar(
      title: Text(_Titulo),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  _montaComboBoxTipoSangue() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        filled: true,
        labelText: 'Tipo Sangue',
        labelStyle: TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      value: _dropdownSangValue,
      // icon: const Icon(Icons.),
      elevation: 16,
      style: const TextStyle(color: Colors.black38),
      onChanged: (String? newValue) {
        setState(() {
          _dropdownSangValue = newValue!;
        });
      },
      items: _tipo_Sangue.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  _montaComboBoxGenero() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        filled: true,
        labelText: 'Gênero',
        labelStyle: TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      value: _dropdownGenValue,
      // icon: const Icon(Icons.),
      elevation: 16,
      style: const TextStyle(color: Colors.black38),
      onChanged: (String? newValue) {
        setState(() {
          _dropdownGenValue = newValue!;
        });
      },
      items: _genero.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  _montaComboBoxUF() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        filled: true,
        labelText: 'UF',
        labelStyle: TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      value: _dropdownUFValue,
      // icon: const Icon(Icons.),
      elevation: 16,
      style: const TextStyle(color: Colors.black38),
      onChanged: (String? newValue) {
        setState(() {
          _dropdownUFValue = newValue!;
        });
      },
      items: _estado.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  _montaComboBoxTipoDoador() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        filled: true,
        labelText: 'Tipo Usuario',
        labelStyle: TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      value: _dropdownTipoValue,
      // icon: const Icon(Icons.),
      elevation: 16,
      style: const TextStyle(color: Colors.black38),
      onChanged: (String? newValue) {
        setState(() {
          _dropdownTipoValue = newValue!;
          _tipoDoador = _montaTelaDeAcordoComTipoCadastro(_dropdownTipoValue)!;
        });
      },
      items: _tipo_Doador.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _corpo(context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        color: Colors.white,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                alignment: Alignment(0.0, 1.15),
                child: Column(
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      child: FittedBox(
                          fit: BoxFit.fill, // otherwise the logo will be tiny
                          child: arquivo != null ? Image.file(arquivo!) : Image.asset(CaminhoImagem)),
                    ),
                    Container(
                      height: 56,
                      width: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0XFFEF5350),
                        border: Border.all(
                          width: 1.0,
                          color: const Color(0xFFFFFFFF),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(56),
                        ),
                      ),
                      child: SizedBox.expand(
                        child: TextButton(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await mostraDialogoEscolha(context);
                            setState(() => arquivo = imageTemp);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: Validators.required('Nome Completo não pode ficar em branco.'),
                enabled: true,
                controller: _nomeController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome Completo",
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validators.required('Nome Mãe não pode ficar em branco.'),
                enabled: true,
                controller: _nome_maeController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome Mãe",
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validators.required('Nome Pai não pode ficar em branco.'),
                enabled: true,
                controller: _nome_paiController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome Pai",
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
              const SizedBox(
                height: 10,
              ),
              _montaComboBoxTipoDoador(),
              _montaComboBoxGenero(),
              _montaComboBoxTipoSangue(),
              _montaComboBoxUF(),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validators.required('CPF não pode ficar em branco.'),
                enabled: true,
                controller: _cpfController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  CpfInputFormatter(),
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "CPF",
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validators.required('Data Nascimento não pode ficar em branco.'),
                controller: _data_nascController,
                decoration: InputDecoration(
                  labelText: "Data Nascimento",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectcDate(context);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validators.required('RG não pode ficar em branco.'),
                enabled: true,
                controller: _rgController,
                inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "RG",
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                enabled: true,
                controller: _id_carteiraController,
                inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "ID Carteira Doador",
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _celularController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Celular",
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validators.required('Email não pode ficar em branco.'),
                enabled: true,
                controller: _email_doadorController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
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
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _tipoDoador, // condition here
                child: Container(
                  child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      TextFormField(
                        validator: Validators.required('Email Solicitante não pode ficar em branco.'),
                        enabled: _tipoDoador,
                        controller: _email_solicitanteController,
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Solicitante",
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
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: Validators.required('Local Internação não pode ficar em branco.'),
                        enabled: _tipoDoador,
                        controller: _local_internacaoController,
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Local Internação",
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
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: Validators.required('Motivo não pode ficar em branco.'),
                        enabled: _tipoDoador,
                        controller: _motivoController,
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Motivo",
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
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: Validators.required('Quantidade Bolsas não pode ficar em branco.'),
                        enabled: _tipoDoador,
                        controller: _qtd_bolsasController,
                        inputFormatters: [LengthLimitingTextInputFormatter(4), FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Quantidade Bolsas",
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
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  width: double.infinity,
                  height: 300.0,
                ),
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
                        _cadastrarDoador();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _corpo(context), appBar: _barraSuperior());
  }
}
