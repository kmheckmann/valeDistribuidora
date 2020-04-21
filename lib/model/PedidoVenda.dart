import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Pedido.dart';

class PedidoVenda extends Pedido{
  String tipoPedido;

  PedidoVenda();

  PedidoVenda.buscarFirebase(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    valorTotal = snapshot.data["vlTotal"]+ 0.0;
    percentualDesconto = snapshot.data["percentDesc"]+ 0.0;
    tipoPagamento = snapshot.data["tipoPgto"];
    ehPedidoVenda = snapshot.data["ehPedidoVenda"];
    dataPedido = snapshot.data["dataPedido"];
    pedidoFinalizado = snapshot.data["pedidoFinalizado"];
    obterEmpresa(snapshot.documentID);
    obterUsuario(snapshot.documentID);
  }

  @override
  Map<String, dynamic> converterParaMapa() {
    return {
      "valorTotal": valorTotal,
      "percentualDesconto": percentualDesconto,
      "tipoPagamento": tipoPagamento,
      "ehPedidoVenda": ehPedidoVenda,
      "tipoPedido": tipoPedido,
    };
  }

}