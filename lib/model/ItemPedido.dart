import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/PedidoCompra.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Produto.dart';

class ItemPedido {
  String id;
  Produto produto;
  PedidoVenda pedidoVenda;
  PedidoCompra pedidoCompra;
  String categoria;
  int quantidade;
  double preco;
  String labelListaProdutos;

  Map<String, dynamic> dadosItemPedido = Map();

  ItemPedido(Pedido p) {
    pedidoCompra = p;
    pedidoVenda = p;
  }

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  ItemPedido.buscarFirebase(DocumentSnapshot document) {
    id = document.documentID;
    labelListaProdutos = document.data["label"];
    quantidade = document.data["quantidade"];
    preco = document.data["preco"];
  }

//Realiza a conversão das informações para mapa para salvar no firebase
//Utilizado na classe PedidoController
  Map<String, dynamic> converterParaMapa(String idProduto) {
    return {
      "id": idProduto,
      "quantidade": quantidade,
      "preco": preco,
      "label": labelListaProdutos
    };
  }
}
