import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/EstoqueProduto.dart';

class EstoqueProdutoController{

  EstoqueProdutoController();

  Map<String, dynamic> dadosEstoqueProduto = Map();

    Map<String, dynamic> converterParaMapa(EstoqueProduto estoqueProduto){
    return{
     "dtAquisicao": estoqueProduto.dataAquisicao,
     "quantidade": estoqueProduto.quantidade,
     "precoCompra": estoqueProduto.precoCompra,
    };
  }

    Future<Null> salvarProduto(Map<String, dynamic> dadosEstoqueProduto, String idProduto, String idEstoque) async {
    this.dadosEstoqueProduto = dadosEstoqueProduto;
    await Firestore.instance
        .collection("produtos")
        .document(idProduto)
        .collection("estoque")
        .document(idEstoque)
        .setData(dadosEstoqueProduto);
  }
}