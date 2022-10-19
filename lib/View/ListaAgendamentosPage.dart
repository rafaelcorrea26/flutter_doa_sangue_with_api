import 'package:flutter/material.dart';
import '../Model/Agendamento.dart';
import '../Model/Doador.dart';
import '../Service/AgendamentoRest.dart';
import '../Service/DoadorRest.dart';
import 'AgendamentoPage.dart';
import 'package:intl/intl.dart';

class ListaAgendamentoPage extends StatefulWidget {
  int idUsuario;
  String NomeUsuario;

  ListaAgendamentoPage(this.idUsuario, this.NomeUsuario);

  @override
  _ListaAgendamentoPageState createState() => _ListaAgendamentoPageState();
}

class _ListaAgendamentoPageState extends State<ListaAgendamentoPage> {
  List<Agendamento> agendamentos = [];
  AgendamentoRest _agendamentoRest = AgendamentoRest();
  Doador _doador = Doador();
  DoadorRest _doadorRest = DoadorRest();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _barraSuperior(),
      body: _listagemFutura(),
      floatingActionButton: _botaoInserir(),
    );
  }

  _barraSuperior() {
    return AppBar(
      title: Text("Cadastro de Agendamento"),
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  //Botao flutuante para adicionar contatos
  _botaoInserir() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () {

        if(_doador.id > 0){
          _navCriarAlterar(Agendamento());

          _agendamentoRest.getAllAgendamento(_doador.id).then((lista) {
            setState(() {
              agendamentos = lista;
            });
          });
        } else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro! É necessário um doador cadastrado para agendar.')),);
        }

      },
      child: const Icon(Icons.add),
    );
  }


  //Constroi a lista apenas apos a leitura dos dados
  _listagemFutura() {
    return FutureBuilder(
        future: _listarTodosAgendamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return _listaDosAgendamentos();
          }
        });
  }

  //Consulta ao banco de dados
  Future _listarTodosAgendamentos() async {
   _doador = await _doadorRest.getDoadorpeloIdUsuario(widget.idUsuario);
    await Future.delayed(const Duration(milliseconds: 100));
    List<Agendamento> lista = await _agendamentoRest.getAllAgendamento(_doador.id);

    agendamentos = lista;
  }

  //Componente com a listagem dos contatos
  _listaDosAgendamentos() {
    return ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: agendamentos.length,
        itemBuilder: (context, index) {
          return Dismissible(
              key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                child: Align(
                  alignment: AlignmentDirectional(0.9, 0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ),
              onDismissed: (DismissDirection direction) {
                Agendamento agendamentoDesfazer;
                agendamentoDesfazer = agendamentos[index];
                _agendamentoRest.deleteAgendamento(agendamentos[index].id);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tarefa ${agendamentoDesfazer.id} foi removido com sucesso!',
                      style: const TextStyle(color: Color(0xff060708)),
                    ),
                    backgroundColor: Colors.white,
                    action: SnackBarAction(
                      label: 'Desfazer',
                      textColor: const Color(0xff00d7f3),
                      onPressed: () {
                        setState(() {
                          print(agendamentoDesfazer);
                          _agendamentoRest.postAgendamento(agendamentoDesfazer);
                        });
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
                setState(() {});
              },
              child: _ItemAgendamento(context, index));
        });
  }

  //Componente para criacao do card com as informações do contato
  _ItemAgendamento(BuildContext context, int index) {
        return GestureDetector(
      onTap: () {
        _mostrarOpcoes(context, index);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("Agend. " + DateFormat("dd/MM/yyyy").format(DateTime.parse(agendamentos[index].data_marcada)) + " às "
                        +agendamentos[index].horario_marcado+ " - " + agendamentos[index].status,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //Navegacao para pagina de atualizacao ou insercao
  _navCriarAlterar(Agendamento agendamento) async {
    final retorno;
    if (agendamento.id > 0) {
      retorno = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => AgendamentoPage(false, agendamento)));
    } else {
      retorno = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => AgendamentoPage(true, agendamento)));
    }
    if (retorno != null) {
      setState(() {
        _listaDosAgendamentos();
      });
    }
  }

  //Componente que exibe as opcoes a serem executadas com o contato
  _mostrarOpcoes(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextButton(
                      child: Text("Editar Agendamento do dia " +
                          DateFormat("dd/MM/yyyy").format(DateTime.parse(agendamentos[index].data_marcada))+"?"),
                      onPressed: () {
                        Navigator.pop(context);
                        _navCriarAlterar(agendamentos[index]);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      child: const Text(
                        "Remover",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _agendamentoRest.deleteAgendamento(agendamentos[index].id);
                        _listarTodosAgendamentos();
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              );
            },
          );
        });
  }
}
