import 'package:cloud_firestore/cloud_firestore.dart';

class Cidade{

  //ID do documento no firebase
  String id;

  String nome;
  bool ativa;

  Map<String, dynamic> dadosCidade = Map();

  Cidade();

  Cidade.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    nome = snapshot.data["nome"];
    ativa = snapshot.data["ativa"];
  }

  Map<String, dynamic> converterParaMapa() {
    return {
      "nome": nome,
      "ativa": ativa,
    };
  }

  Future<Null> salvarCidade(Map<String, dynamic> dadosCidade) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document()
        .setData(dadosCidade);
  }

  Future<Null> editarCidade(Map<String, dynamic> dadosCidade, String idFirebase) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document(idFirebase)
        .setData(dadosCidade);
  }
}