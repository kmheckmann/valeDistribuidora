import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Usuario extends Model {
  //declarado so para nao escrever FirebaseAuth.instance toda hora
  FirebaseAuth _autenticar = FirebaseAuth.instance;

  //armazena o usuario que esta logado, se nao tiver usuario fica null, se tiver, contem o id e infos basicas
  FirebaseUser usuarioFirebase;
  //armazena o novo usuario criado

  //ira armazenar os dados importantes do usuario
  Map<String, dynamic> dadosUsuarioAtual = Map();
  Map<String, dynamic> dadosNovoUsuario = Map();

  //ID do documento no firebase
  String id;

  String nome;
  String cpf;
  String email;
  String senha;
  bool ehAdministrador;
  bool ativo;

  //indica quando algo esta sendo processado dentro da classe usuario
  bool carregando = false;

  Usuario();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  Usuario.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    nome = snapshot.data["nome"];
    cpf = snapshot.data["cpf"];
    email = snapshot.data["email"];
    ehAdministrador = snapshot.data["ehAdm"];
    ativo = snapshot.data["ativo"];
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _carregarDadosUsuario();
  }

  //VoidCallBack uma funcao passada que sera chamado de dentro do metodo
  void cadastrarUsuario(
      {@required Map<String, dynamic> dadosUser,
      @required String senha,
      @required VoidCallback cadastradoSucesso,
      @required VoidCallback cadastroFalhou}) {
    carregando = true;
    _autenticar
        .createUserWithEmailAndPassword(
            email: dadosUser["email"], password: senha)
        .then((user) async {
      //se der certo a criacao do usuario, pego os dados e salvo no firebase
      await _salvarUsuario(dadosUser, user);
      cadastradoSucesso();
      carregando = false;
    }).catchError((erro) {
      cadastroFalhou();
      carregando = false;
    });
  }

//Faz com que o login do usuario seja efetuado no sistema
  void efetuarLogin(
      {@required String email,
      @required String senha,
      @required VoidCallback sucessoLogin,
      @required VoidCallback falhaLogin}) async {
    carregando = true;
    //"avisar" todas as classes coonfiguradas para receber notificação sobre as mudancas que ocorreram no usuario
    notifyListeners();

//Usa uma propriedade nativa do firebase para fazer a autenticação
    _autenticar
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((usuario) async {
      usuarioFirebase = usuario;
      //Carrega os dados do usuario
      await _carregarDadosUsuario();
      sucessoLogin();
      carregando = false;
      notifyListeners();
    }).catchError((e) {
      falhaLogin();
      carregando = false;
      notifyListeners();
    });
  }

  Future<Null> _salvarUsuario(
      Map<String, dynamic> dadosUsuario, FirebaseUser user) async {
    this.dadosNovoUsuario = dadosUsuario;
    await Firestore.instance
        .collection("usuarios")
        .document(user.uid)
        .setData(dadosUsuario);
  }

//Verifica se existe algum usuario logado
  bool usuarioLogado() {
    return usuarioFirebase != null;
  }

//Efetua o logou to usuário no sistema
  void sair() async {
    await _autenticar.signOut();
    dadosUsuarioAtual = Map();
    usuarioFirebase = null;
    notifyListeners();
  }

//utiliza uma propriedade nativa do firebase que dispara um email para redefinir a senha
  void recuperarSenha(String email) {
    _autenticar.sendPasswordResetEmail(email: email);
  }

//Carrega todos os dados do usuário que efetuou o login
//Notifica todas as classes que estão configurada para receber qualquer alteração do usuario
  Future<Null> _carregarDadosUsuario() async {
    if (usuarioFirebase == null)
      usuarioFirebase = await _autenticar.currentUser();

    if (usuarioFirebase != null) {
      if (dadosUsuarioAtual["name"] == null) {
        DocumentSnapshot docUsuario = await Firestore.instance
            .collection("usuarios")
            .document(usuarioFirebase.uid)
            .get();
        dadosUsuarioAtual = docUsuario.data;
        dadosNovoUsuario = docUsuario.data;
      }
      notifyListeners();
    }
  }
}
