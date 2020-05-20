import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/Usuario.dart';

abstract class Pedido extends Model{

  String id;
  //A empresa será o cliente em pedidos de venda e o fornecedor em pedidos de compra
  Empresa empresa = Empresa();
  Usuario user = Usuario();
  double valorTotal;
  double percentualDesconto;
  String tipoPagamento;
  bool ehPedidoVenda;
  DateTime dataPedido;
  bool pedidoFinalizado;
  List<ItemPedido> itens = [];

}