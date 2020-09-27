import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/controller/PedidoController.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/PedidoVenda.dart';

class PedidoVendaController extends PedidoController {
  PedidoVenda pedidoVenda = PedidoVenda();

  PedidoVendaController();

  Map<String, dynamic> converterParaMapa(Pedido p) {
    return {
      "valorTotal": p.valorTotal,
      "percentualDesconto": p.percentualDesconto,
      "tipoPagamento": p.tipoPagamento,
      "ehPedidoVenda": p.ehPedidoVenda,
      "dataPedido": p.dataPedido,
      "pedidoFinalizado": p.pedidoFinalizado,
      "label": p.labelTelaPedidos,
      "valorComDesconto": p.valorComDesconto,
      "dataFinalPedido": p.dataFinalPedido,
    };
  }

  Future<Null> salvarPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idPedido) async {
    this.dadosPedido = dadosPedido;
    this.dadosEmpresa = dadosEmpresa;
    this.dadosUsuario = dadosUsuario;

    //Grava os dados do pedido
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .setData(dadosPedido);

    //Salva dentro da collection pedido o ID do cliente do pedido
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosEmpresa);
    //Salva dentro da collection pedido o ID do vendedor
    await Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("vendedor")
        .document("IDvendedor")
        .setData(dadosUsuario);
  }

  Future<Null> editarPedido(
      Map<String, dynamic> dadosPedido,
      Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosUsuario,
      String idFirebase) async {
    this.dadosPedido = dadosPedido;
    this.dadosEmpresa = dadosEmpresa;
    this.dadosUsuario = dadosUsuario;
    await Firestore.instance
        .collection("pedidos")
        .document(idFirebase)
        .setData(dadosPedido);

    await Firestore.instance
        .collection("pedidos")
        .document(idFirebase)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosEmpresa);

    await Firestore.instance
        .collection("pedidos")
        .document(idFirebase)
        .collection("vendedor")
        .document("IDvendedor")
        .setData(dadosUsuario);
  }

//Aplica no valor total do pedido o desconto informado
  @override
  void calcularDesconto(Pedido p) {
    if (p.valorTotal != 0 || p.valorTotal == 0) {
      double vlDesc = (p.percentualDesconto / 100) * p.valorTotal;
      pedidoVenda.valorComDesconto = (p.valorTotal - vlDesc);
    } else {
      //Exceção para o caso de o desconto ser informado antes do pedido ter algum valor
      pedidoVenda.valorComDesconto = 0;
    }
  }

//Método chamado para atualizar regularmente o valor total do pedido
  @override
  void somarPrecoNoVlTotal(Pedido p, ItemPedido novoItem) {
    double valorTotalItem = novoItem.preco * novoItem.quantidade;
    p.valorTotal += valorTotalItem;
    pedidoVenda.valorTotal = p.valorTotal;
    calcularDesconto(p);
  }

//Método utilizado quando é realizada uma alteração num item do pedido
  void atualizarPrecoNoVlTotal(double precoAntigo, Pedido p, ItemPedido item) {
    //Diminui o valor total antigo obtido com a soma das quantidade do item
    double vlTotalItemAntigo = precoAntigo * item.quantidade;
    p.valorTotal -= vlTotalItemAntigo;
    //Após diminuir, chama o método abaixo para somar o novo valor no pedido
    somarPrecoNoVlTotal(p, item);
  }

//Método utilizado quando um item é removido, para diminuir seu valor do valor total do pedido
  void subtrairPrecoVlTotal(Pedido p, ItemPedido itemExcluido) {
    double valorTotalItem = itemExcluido.preco * itemExcluido.quantidade;
    p.valorTotal -= valorTotalItem;
    pedidoVenda.valorTotal = p.valorTotal;
    calcularDesconto(p);
  }

  Future<Null> verificarSePedidoTemItens(Pedido p) async {
    //este método tem o objetivo de verificar se o pedido possui itens cadastrados
    //para poder finalizar o pedido

    //Acessa a coleção onde os iens ficam salvos
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(p.id)
        .collection("itens");
    //Obtém todos os documentos da coleção
    QuerySnapshot _obterItens = await ref.getDocuments();

    if (_obterItens.documents.length > 0) {
      podeFinalizar = true;
    } else {
      podeFinalizar = false;
    }
  }

//Método chamado ao utilizar o botão de atualizar na capa do pedido
  @override
  Future<Null> atualizarCapaPedido(String idPedido) async {
    CollectionReference ref = Firestore.instance.collection('pedidos');
    QuerySnapshot _obterPedido = await ref.getDocuments();

    _obterPedido.documents.forEach((document) {
      if (idPedido == document.documentID) {
        pedidoVenda = PedidoVenda.buscarFirebase(document);
      }
    });
  }
}
