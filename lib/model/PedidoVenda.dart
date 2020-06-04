import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Pedido.dart';

class PedidoVenda extends Pedido{
  String tipoPedido;

  PedidoVenda();

  PedidoVenda.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    valorTotal = snapshot.data["valorTotal"];
    percentualDesconto = snapshot.data["percentualDesconto"];
    tipoPagamento = snapshot.data["tipoPagamento"];
    tipoPedido = snapshot.data["tipoPedido"];
    ehPedidoVenda = snapshot.data["ehPedidoVenda"];
    dataPedido = snapshot.data["dataPedido"];
    pedidoFinalizado = snapshot.data["pedidoFinalizado"];
    labelTelaPedidos = snapshot.data["label"];
    valorComDesconto = snapshot.data["valorComDesconto"];
  }

  @override
  Map<String, dynamic> converterParaMapa() {
    return {
      "valorTotal": valorTotal,
      "percentualDesconto": percentualDesconto,
      "tipoPagamento": tipoPagamento,
      "ehPedidoVenda": ehPedidoVenda,
      "tipoPedido": tipoPedido,
      "dataPedido": dataPedido,
      "pedidoFinalizado": pedidoFinalizado
    };
  }

}