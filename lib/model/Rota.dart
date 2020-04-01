import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rota{
  //ID do documento no firebase
  String idFirebase;

  Usuario vendedor = Usuario();
  Empresa cliente = Empresa();
  String diaSemana;
  String frequencia;
  String tituloRota;
  bool ativa;

  Map<String, dynamic> dadosRota = Map();
  Map<String, dynamic> dadosVendedor = Map();
  Map<String, dynamic> dadosCliente = Map();

  Rota();

  Rota.buscarFirebase(DocumentSnapshot snapshot){
    idFirebase = snapshot.documentID;
    frequencia = snapshot.data["frequencia"];
    diaSemana = snapshot.data["diaSemana"];
    ativa = snapshot.data["ativa"];
    tituloRota = snapshot.data["tituloRota"];
    _obterCliente(snapshot.documentID);
    _obterVendedor(snapshot.documentID);
  }

    Map<String, dynamic> converterParaMapa() {
    return {
      "diaSemana": diaSemana,
      "frequencia": frequencia,
      "ativa": ativa,
      "tituloRota": tituloRota     
    };
  }

    Future<Null> salvarRota(Map<String, dynamic> dadosRota, Map<String, dynamic> dadosCliente, Map<String, dynamic> dadosVendedor, String id) async {
    this.dadosRota = dadosRota;
    this.dadosCliente = dadosCliente;
    this.dadosVendedor = dadosVendedor;
    await Firestore.instance
        .collection("rotas")
        .document(id)
        .setData(dadosRota);

    await Firestore.instance
    .collection("rotas")
    .document(id)
    .collection("cliente")
    .document("IDcliente")
    .setData(dadosCliente);

    await Firestore.instance
    .collection("rotas")
    .document(id)
    .collection("vendedor")
    .document("IDvendedor")
    .setData(dadosVendedor);
  }

  Future<Null> editarRota(
      Map<String, dynamic> dadosRota, Map<String, dynamic> dadosCliente, Map<String, dynamic> dadosVendedor, 
      String idFirebase) async {
    this.dadosRota = dadosRota;
    this.dadosCliente = dadosCliente;
    this.dadosVendedor = dadosVendedor;
    await Firestore.instance
        .collection("rotas")
        .document(idFirebase)
        .setData(dadosRota);

    await Firestore.instance
        .collection("rotas")
        .document(idFirebase)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosCliente);

    await Firestore.instance
        .collection("rotas")
        .document(idFirebase)
        .collection("vendedor")
        .document("IDvendedor")
        .setData(dadosVendedor);
  }

Future<Empresa> _obterCliente(String idRota) async {
CollectionReference ref = Firestore.instance.collection('rotas').document(idRota).collection('cliente');
QuerySnapshot obterClienteRota = await ref.getDocuments();

CollectionReference refCliente = Firestore.instance.collection('empresas');
QuerySnapshot obterDadosEmpresa = await refCliente.getDocuments();

obterClienteRota.documents.forEach((document) {
  cliente.id = document.data["id"];

  obterDadosEmpresa.documents.forEach((document1){
  if(cliente.id == document1.documentID){
    cliente = Empresa.buscarFirebase(document1);

  }
});
});
return cliente;
 }

Future<Usuario> _obterVendedor(String idRota) async {
CollectionReference ref = Firestore.instance.collection('rotas').document(idRota).collection('vendedor');
QuerySnapshot obterVendedorRota = await ref.getDocuments();
 
CollectionReference refCliente = Firestore.instance.collection('usuarios');
QuerySnapshot obterDadosVendedor = await refCliente.getDocuments();

obterVendedorRota.documents.forEach((document) {
  vendedor.id = document.data["id"];

  obterDadosVendedor.documents.forEach((document1){
  if(vendedor.id == document1.documentID){
    vendedor.nome = document1.data["nome"];
    vendedor.cpf = document1.data["cpf"];
    vendedor.email = document1.data["email"];
    vendedor.ehAdministrador = document1.data["ehAdm"];
    vendedor.ativo = document1.data["ativo"];
  }
});
});
return vendedor;
 }
}
