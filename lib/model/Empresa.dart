import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Cidade.dart';

class Empresa{
  //ID do documento no firebase
  String id;
  String razaoSocial;
  String nomeFantasia;
  String cnpj;
  String inscEstadual;
  String cep;
  Cidade cidade;
  String bairro;
  String logradouro;
  int numero;
  String telefone;
  String email;
  bool ativo;
  bool ehFornecedor;

  Map<String, dynamic> dadosEmpresa = Map();

  Empresa();

  Empresa.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    razaoSocial = snapshot.data["razaoSocial"];
    nomeFantasia = snapshot.data["nomeFantasia"];
    cnpj = snapshot.data["cnpj"];
    inscEstadual = snapshot.data["inscEstadual"];
    cep = snapshot.data["cep"];
    bairro = snapshot.data["bairro"];
    logradouro = snapshot.data["logradouro"];
    numero = snapshot.data["numero"];
    telefone = snapshot.data["telefone"];
    email = snapshot.data["email"];
    ehFornecedor = snapshot.data["ehFornecedor"];
    ativo = snapshot.data["ativo"];
    //Chama o método para atribuir valores da cidade vinculada à empresa.
    cidade = Cidade();
   // _obterCidadeFirebase(snapshot.documentID);
  }

//Método para buscar os valores da cidade na subcoleção dentro da empresa
 /* Future<Cidade> _obterCidadeFirebase(String idEmpresa) async {
CollectionReference ref = Firestore.instance.collection('empresas').document(idEmpresa).collection('cidade');
QuerySnapshot eventsQuery = await ref.getDocuments();

eventsQuery.documents.forEach((document) {
  print("teste");
  print(document.documentID);
  cidade.id = document.documentID;
  cidade.nome = document.data["nome"];
  cidade.ativa = document.data["ativa"];
});

return cidade;
}*/


  Map<String, dynamic> converterParaMapa() {
    return {
      "razaoSocial": razaoSocial,
      "nomeFantasia": nomeFantasia,
      "cnpj": cnpj,
      "inscEstadual": inscEstadual,
      "cep": cep,
      "bairro": bairro,
      "logradouro": logradouro,
      "numero": numero,
      "telefone": telefone,
      "email": email,
      "ativo": ativo,
      "ehFornecedor": ehFornecedor
    };
  }

  Future<Null> salvarEmpresa(Map<String, dynamic> dadosEmpresa, Map<String, dynamic> dadosCidade) async {
    this.dadosEmpresa = dadosEmpresa;
    await Firestore.instance
        .collection("empresas")
        .document(dadosEmpresa["cnpj"])
        .setData(dadosEmpresa);

    await Firestore.instance
    .collection("empresas")
    .document(dadosEmpresa["cnpj"])
    .collection("cidade")
    .document()
    .setData(dadosCidade);
  }

  Future<Null> editarEmpresa(
      Map<String, dynamic> dadosEmpresa, Map<String, dynamic> dadosCidade, 
      String idFirebase, String idCidadeFirebase) async {
    this.dadosEmpresa = dadosEmpresa;
    await Firestore.instance
        .collection("empresas")
        .document(idFirebase)
        .setData(dadosEmpresa);

    await Firestore.instance
        .collection("empresas")
        .document(idFirebase)
        .collection("cidade")
        .document(idCidadeFirebase)
        .setData(dadosCidade);
  }
}
