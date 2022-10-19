import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Service/UsuarioRest.dart';
import '../Utils/ImagemHelper.dart';
import '../Utils/Validators.dart';
import '../Model/Usuario.dart';
import 'Login.AlterarSenhaPage.dart';
import 'PrincipalPage.dart';
import 'dart:io';

class CadastroUsuarioPage extends StatefulWidget {
  bool edicaoUsuario;

  CadastroUsuarioPage(this.edicaoUsuario);

  @override
  _CadastroUsuarioPage createState() => _CadastroUsuarioPage();
}

class _CadastroUsuarioPage extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  Usuario _usuario = Usuario();
  UsuarioRest _usuarioRest = UsuarioRest();
  String _Titulo = 'Cadastro Usuário';
  var CaminhoImagem = "assets/pictures/profile-picture.jpg";
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  _CadastroUsuarioPage();

  @override
  void initState() {
    super.initState();
    arquivo = null;
    imageTemp = null;
    if (widget.edicaoUsuario) {
     _Titulo= 'Edição Usuário';
    _carregaCampos();
  } else {
      _Titulo= 'Cadastro Usuário';
    }
  }

  void _carregaCampos() async {
      arquivo = null;
      _usuario =  await Usuario.getLocal();
      _nomeController.text = _usuario.nome;
      _loginController.text = _usuario.login;
      _emailController.text = _usuario.email;

      if ((_usuario.imagem != '') && (_usuario.imagem != 'assets/pictures/profile-picture.jpg')) {
        imageTemp = File(_usuario.imagem);
        setState(() => arquivo = imageTemp);
      }
    }

  void CadastrarUsuario() async {
    _usuario.nome = _nomeController.text;
    _usuario.login = _loginController.text;
    _usuario.email = _emailController.text;
    _usuario.senha = '';
    _usuario.imagem = verificarCaminhoImagem()!;

    if (widget.edicaoUsuario){
      await _usuarioRest.putUsuario(_usuario);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrincipalPage(),
          ),
        );
      } else {
        _usuario.id = 0;
        _usuario.senha = _senhaController.text;
        bool _usuarioCriado = await _usuarioRest.postUsuario(_usuario);
        if (_usuarioCriado) {
          Navigator.pop(context, false);
        } else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro! Usuário nao foi criado corretamente, tente novamente mais tarde.')),
          );
        }

      }
   }

  barraSuperior() {
    return AppBar(
      title: Text(_Titulo),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  Widget corpo(context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 40, right: 40),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Container(
              width: 300,
              height: 298,
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
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _nomeController,
              validator: Validators.required('Nome não pode ficar em branco.'),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15), // add padding to adjust icon
                  child: Icon(
                    Icons.person,
                    color: Colors.red[400],
                  ),
                ),
                labelText: "Nome",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _loginController,
              validator: Validators.required('Login não pode ficar em branco.'),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15), // add padding to adjust icon
                  child: Icon(
                    Icons.person,
                    color: Colors.red[400],
                  ),
                ),
                labelText: "Login",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _emailController,
              validator: Validators.compose([
                Validators.required('Email não pode ficar em branco.'),
              ]),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15), // add padding to adjust icon
                  child: Icon(
                    Icons.email,
                    color: Colors.red[400],
                  ),
                ),
                labelText: "E-mail",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Visibility(
              visible: !widget.edicaoUsuario, // condition here
              child: Container(
                child: TextFormField(
                      enabled: !widget.edicaoUsuario,
                      controller: _senhaController,
                      validator: Validators.required('Senha não pode ficar em branco.'),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 15), // add padding to adjust icon
                          child: Icon(
                            Icons.lock,
                            color: Colors.red[400],
                          ),
                        ),
                        labelText: "Senha",
                        labelStyle: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                width: double.infinity,
                  height: !widget.edicaoUsuario  ? 70 : 0,
              ),
            ),
            Visibility(
              visible: widget.edicaoUsuario, // condition here
              child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text(
                          "Deseja alterar para uma nova senha?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                           // color: Colors.black87,
                            fontSize: 18
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  AlterarSenhaPage(),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            SizedBox(
              height: 10,
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
                      "Cadastrar/Salvar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        CadastrarUsuario();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro! Existem campos em branco ou preenchidos incorretamente.')),
                        );
                      }
                    }),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: corpo(context), appBar: barraSuperior());
  }
}
