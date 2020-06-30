import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Pedido.dart';

class PedidoCompra extends Pedido{

  PedidoCompra();

    PedidoCompra.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    valorTotal = snapshot.data["valorTotal"];
    percentualDesconto = snapshot.data["percentualDesconto"];
    tipoPagamento = snapshot.data["tipoPagamento"];
    ehPedidoVenda = snapshot.data["ehPedidoVenda"];
    dataPedido = snapshot.data["dataPedido"];
    pedidoFinalizado = snapshot.data["pedidoFinalizado"];
    labelTelaPedidos = snapshot.data["label"];
    valorComDesconto = snapshot.data["valorComDesconto"];
    dataFinalPedido = snapshot.data["dataFinalPedido"];
  }
}