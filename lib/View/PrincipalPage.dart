import 'package:doa_sangue/Service/DoadorRest.dart';
import 'package:flutter/material.dart';
import '../Model/Doador.dart';
import 'ListaAgendamentosPage.dart';
import 'Login.CadastrarPage.dart';
import '../Model/Usuario.dart';
import 'DoadorPage.dart';
import 'dart:io';


class PrincipalPage extends StatefulWidget {

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  var CaminhoImagem = "assets/pictures/profile-picture-menu.jpg";
  File? _arquivo;
  Usuario _usuario = Usuario();
  Doador _doador = Doador();
  DoadorRest _DoadorRest = DoadorRest();

  @override
  void initState() {
    super.initState();
    _CarregaUsuario();
  }

  @override
  void onResume() {
    _CarregaUsuario();
    setState(() {
    });
    super.context;
  }

  _CarregaUsuario() async {
    _usuario = await Usuario.getLocal();
    _verificaExistenciaDoador();

    if ((_usuario.imagem != '') && (_usuario.imagem != null) &&
        (_usuario.imagem != 'assets/pictures/profile-picture.jpg')) {
      final imageTemp = File(_usuario.imagem);
      setState(() => _arquivo = imageTemp);
    } else {
      setState(() {
    });}
  }

  _verificaExistenciaDoador() async {
    _doador = await _DoadorRest.getDoadorpeloIdUsuario(_usuario.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: corpo(context),
    );
  }

  Widget corpo(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Principal"),
        centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(_usuario.email),
              accountName: Text(_usuario.nome),
              decoration: BoxDecoration(
                color: const Color(0XFFEF5350),
              ),
              currentAccountPicture: _arquivo != null
                  ? Image.file(_arquivo!)
                  : Image.asset(CaminhoImagem),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Editar dados Usuário"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CadastroUsuarioPage(true),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Cadastro Doador/Solicitante"),
              onTap: () async {
             await _verificaExistenciaDoador();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                         CadastroDoadorPage(_usuario,_doador),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Agendamento doação sangue"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaAgendamentoPage(
                        _usuario.id, _usuario.nome),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Sair"),
              onTap: () async {
                exit(0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
