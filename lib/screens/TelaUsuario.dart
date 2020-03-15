import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_2/model/Usuario.dart';

class TelaUsuario extends StatefulWidget {
  final Usuario usuario;

  final DocumentSnapshot snapshot;

  TelaUsuario({this.usuario, this.snapshot});

  @override
  _TelaUsuarioState createState() =>
      _TelaUsuarioState(usuario: usuario, snapshot: snapshot);
}

class _TelaUsuarioState extends State<TelaUsuario> {
  //variavel que permite o onPressed do botao entrar acionar o validador dos campos
  final _validadorCampos = GlobalKey<FormState>();

  Usuario usuario;
  final DocumentSnapshot snapshot;

  _TelaUsuarioState({this.usuario, this.snapshot});

  Usuario _usuarioEditado = Usuario();

  String _nomeTela;
  final _controllerNome = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerSenha = TextEditingController();
  bool _existeCadastro;

  @override
  void initState() {
    super.initState();
    bool _existeCadastro = false;
    if (usuario != null) {
      print(usuario.id);
      _nomeTela = "Editar Usuário";
      _controllerNome.text = usuario.nome;
      _controllerCPF.text = usuario.cpf;
      _controllerEmail.text = usuario.email;
      _controllerSenha.text = usuario.senha;
    } else {
      _nomeTela = "Cadastrar Usuário";
      usuario = Usuario();
      usuario.ativo = true;
      usuario.ehAdministrador = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usuario>(
      builder: (context, child, model) {
        if(model.carregando) return Center(child: CircularProgressIndicator(),);
        return Scaffold(
            appBar: AppBar(
              title: Text(_nomeTela),
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.save),
                backgroundColor: Colors.blue,
                onPressed: () {
                  if (_validadorCampos.currentState.validate()) {
                    Map<String, dynamic> dadosUsuario = {
                      "nome": _controllerNome.text,
                      "cpf": _controllerCPF.text,
                      "email": _controllerEmail.text,
                      "ehAdm": usuario.ehAdministrador,
                      "ativo": usuario.ativo
                    };

                    model.cadastrarUsuario(
                        dadosUser: dadosUsuario,
                        senha: _controllerSenha.text,
                        cadastradoSucesso: _sucesso,
                        cadastroFalhou: _falha);
                  }
                }),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              child: Container(
                child: Form(
                    key: _validadorCampos,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _controllerNome,
                          decoration: InputDecoration(
                            hintText: "Nome Completo",
                          ),
                          //faz uma verificao simples do texto informado no campo
                          validator: (text) {
                            if (text.isEmpty) return "Nome inválido!";
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: _controllerCPF,
                          decoration: InputDecoration(
                            hintText: "CPF",
                          ),
                          keyboardType: TextInputType.number,
                          //faz uma verificao simples do texto informado no campo
                          validator: (text) {
                            if (text.isEmpty) return "CPF inválido!";
                            if (text.isNotEmpty && _existeCadastro == true) return "Já existe outro usuário com o mesmo CPF, verifique!";
                          },
                          onChanged: (text){
                            usuario.cpf = text;
                            _verificarExistenciaUsuario();
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: _controllerEmail,
                          decoration: InputDecoration(
                            hintText: "E-mail",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          //faz uma verificao simples do texto informado no campo
                          validator: (text) {
                            if (text.isEmpty || !text.contains("@"))
                              return "E-mail inválido!";
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: _controllerSenha,
                          decoration: InputDecoration(hintText: "Senha"),
                          obscureText: true,
                          validator: (text) {
                            if (text.isEmpty || text.length < 6)
                              return "Senha inválida!";
                          },
                        ),
                        _criarCampoCheckBoxAdm(),
                        _criarCampoCheckBoxAtivo()
                      ],
                    )),
              ),
            ));
      },
    );
  }

  Widget _criarCampoCheckBoxAdm() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: usuario.ehAdministrador == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  usuario.ehAdministrador = true;
                } else {
                  usuario.ehAdministrador = false;
                }
              });
            },
          ),
          Text(
            "Administrador?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarCampoCheckBoxAtivo() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: usuario.ativo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  usuario.ativo = true;
                } else {
                  usuario.ativo = false;
                }
              });
            },
          ),
          Text(
            "Ativo?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  void _sucesso() {
    Navigator.of(context).pop();
  }

  void _falha() {
    print("erro");
  }
  void _verificarExistenciaUsuario() async {
    //Busca todas usuarios
    CollectionReference ref = Firestore.instance.collection("usuarios");
  //Nos users cadastrados verifica se existe algum com o mesmo cpf informado no cadastro atual
  //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery = await ref
    .where("cpf", isEqualTo: usuario.cpf)
    .getDocuments();
    print(eventsQuery.documents.length);
    if(eventsQuery.documents.length > 0){
      _existeCadastro = true;
    }else{
      _existeCadastro = false;
    }
  }
}
