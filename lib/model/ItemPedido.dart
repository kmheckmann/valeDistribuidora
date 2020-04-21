import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Produto.dart';

class ItemPedido{

  String id;
  String idProduto;
  String categoria;
  int quantidade;
  double preco;

  Produto dadosProduto;

  ItemPedido();

  ItemPedido.buscarFirebase(DocumentSnapshot document){
    id = document.documentID;
    categoria = document.data["categoria"];
    idProduto = document.data["idProduto"];
    quantidade = document.data["quantidade"];
    preco = document.data["preco"];
  }

  Map<String, dynamic> converterParaMapa() {
    return {
      "categoria": categoria,
      "idProduto": idProduto,
      "quantidade": quantidade,
      "preco": preco
    };
  }




}