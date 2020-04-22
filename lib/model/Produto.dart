import 'package:cloud_firestore/cloud_firestore.dart';

class Produto{

  //ID do documento no firebase
  String id;

  Map<String, dynamic> dadosProduto = Map();

  int codigo;
  int codBarra;
  String descricao;
  double precoCompra;
  double precoVenda;
  int qtdEstoque;
  bool ativo;

  Produto();

  Produto.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    descricao = snapshot.data["descricao"];
    codigo = snapshot.data["codigo"];
    codBarra = snapshot.data["codBarra"];
    //somar o 0.0 no final eh uma alternativa para corrigir um bug quando busca um valor sem casas decimais do firebase
    precoCompra = snapshot.data["precoCompra"] + 0.0;
    precoVenda = snapshot.data["precoVenda"] + 0.0;
    qtdEstoque = snapshot.data["qtdEstoque"];
    ativo = snapshot.data["ativo"];
  }

  Map<String, dynamic> converterParaMapa(){
    return{
     "codigo": codigo,
     "codBarra": codBarra,
     "descricao": descricao,
     "precoCompra": precoCompra,
     "precoVenda": precoVenda,
     "qtdEstoque": qtdEstoque,
     "ativo": ativo
    };
  }

  Future<Null> salvarProduto(Map<String, dynamic> dadosProduto) async {
    this.dadosProduto = dadosProduto;
    await Firestore.instance
        .collection("produtos")
        .document()
        .setData(dadosProduto);
  }

  Future<Null> editarProduto(Map<String, dynamic> dadosProduto, String idFirebase) async {
    this.dadosProduto = dadosProduto;
    await Firestore.instance
        .collection("produtos")
        .document(idFirebase)
        .setData(dadosProduto);
  }

}