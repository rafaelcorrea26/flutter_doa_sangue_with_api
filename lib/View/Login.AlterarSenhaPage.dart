import 'package:flutter/material.dart';
import '../Model/Usuario.dart';
import '../Service/ConnectionAPI.dart';
import '../Service/UsuarioRest.dart';
import '../Utils/Validators.dart';

class AlterarSenhaPage extends StatefulWidget {

  @override
  _AlterarSenhaPage createState() => _AlterarSenhaPage();
}

class _AlterarSenhaPage extends State<AlterarSenhaPage> {

  UsuarioRest _usuarioRest = UsuarioRest();
  Usuario _usuario = Usuario();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _senhaAntigaControler = TextEditingController();
  TextEditingController _senhaNovaControler = TextEditingController();
  _AlterarSenhaPage();

  @override
  void initState() {
    super.initState();
    }

  barraSuperior() {
    return AppBar(
      title: Text("Alterar senha do Usuário"),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  Future AlteraSenhaUsuario(BuildContext context) async {
    bool LoginOk = false;
    _usuario =  await Usuario.getLocal();
    LoginOk = await ConnectionAPI.Login(_usuario.email, _senhaAntigaControler.text);
    if (LoginOk){
     String mensagem = await _usuarioRest.putSenhaUsuario(_usuario.id, _senhaNovaControler.text);
     if (mensagem == 'Senha do Usuário Alterada com sucesso!') {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),);
        Navigator.pop(context, false);

     } else{
       ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Erro! Sua senha de usuário não  corresponde com a digitada no campo.')),);
     }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro! Sua senha de usuário não  corresponde com a digitada no campo.')),
      );
    }
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
              validator: Validators.required('Senha antiga é necessária para Validação.'),
              controller: _senhaAntigaControler,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 15), // add padding to adjust icon
                  child: Icon(
                    Icons.password,
                    color: Colors.red[400],
                  ),
                ),
                labelText: "Senha antiga",
                labelStyle: const TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2,
                    )),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            TextFormField(
              validator: Validators.required('Senha nova é necessária para Alteração.'),
              controller: _senhaNovaControler,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 15), // add padding to adjust icon
                  child: Icon(
                    Icons.password,
                    color: Colors.red[400],
                  ),
                ),
                labelText: "Senha Nova",
                labelStyle: const TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2,
                    )),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
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
                      "Salvar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AlteraSenhaUsuario(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro! Existem campos em branco ou preenchidos incorretamente.')),
                        );
                      }
                    }),
              ),
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











