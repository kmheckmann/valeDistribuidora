import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Produto.dart';

class ItemPedido{

  String id;
  Produto produto;
  PedidoVenda pedidoVenda;
  String categoria;
  int quantidade;
  double preco;

  Map<String, dynamic> dadosItemPedido = Map();

  ItemPedido(PedidoVenda p){
    pedidoVenda = p;
  }

  ItemPedido.buscarFirebase(DocumentSnapshot document){
    id = document.documentID;
    categoria = document.data["categoria"];
    quantidade = document.data["quantidade"];
    preco = document.data["preco"];
    _obterPedido(pedidoVenda.id);
    _obterProduto(pedidoVenda.id);
  }

  Map<String, dynamic> converterParaMapa() {
    return {
      "categoria": categoria,
      "quantidade": quantidade,
      "preco": preco
    };
  }

  Future<Null> salvarItemPedido(Map<String, dynamic> dadosPedido, String idPedido) async {
    this.dadosItemPedido = dadosPedido;
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .add(dadosPedido)
        .then((doc){
          this.id = doc.documentID;
        });
  }

  Future<Null> editarItemPedido(Map<String, dynamic> dadosPedido, String idPedido, String idItemPedido) async {
    this.dadosItemPedido = dadosPedido;
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens")
        .document(idItemPedido)
        .setData(dadosPedido);
  }

  Future<Null> removerItemPedido(String idPedido, String idItem) async {
    await Firestore.instance.collection("pedidos")
    .document(id)
    .collection("itens")
    .document(idItem)
    .delete();
  }



  Future<PedidoVenda> _obterPedido(String idPedido) async {
    CollectionReference ref = Firestore.instance.collection('pedidos');
    QuerySnapshot obterPedido = await ref.getDocuments();

  obterPedido.documents.forEach((document) {
      if(idPedido == document.documentID){
        pedidoVenda = PedidoVenda.buscarFirebase(document);
      }
  });
  return pedidoVenda;
}

Future<Produto> _obterProduto(String idPedido) async {
CollectionReference ref = Firestore.instance.collection('pedidos').document(idPedido).collection('itens');
QuerySnapshot obterProdutoPedido = await ref.getDocuments();

CollectionReference refCliente = Firestore.instance.collection('produtos').document(categoria).collection('itens');
QuerySnapshot obterDadosProduto = await refCliente.getDocuments();

  obterProdutoPedido.documents.forEach((document) {
    produto.id = document.data["id"];

      obterDadosProduto.documents.forEach((document1){
        if(produto.id == document1.documentID){
        produto = Produto.buscarFirebase(document1);
        }
      });
  });
  return produto;
}



}