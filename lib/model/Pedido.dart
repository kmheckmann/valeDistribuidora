import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Usuario.dart';

abstract class Pedido{

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
  

  Map<String, dynamic> dadosPedido = Map();
  Map<String, dynamic> dadosUsuario = Map();
  Map<String, dynamic> dadosEmpresa = Map();

  Map<String, dynamic> converterParaMapa() {
    return {
      "valorTotal": valorTotal,
      "percentualDesconto": percentualDesconto,
      "tipoPagamento": tipoPagamento,
      "ehPedidoVenda": ehPedidoVenda,
      "dataPedido": dataPedido,
      "pedidoFinalizado": pedidoFinalizado,
    };
  }

  Future<Null> salvarPedido(Map<String, dynamic> dadosPedido, Map<String, dynamic> dadosEmpresa, Map<String, dynamic> dadosUsuario) async {
    this.dadosPedido = dadosPedido;
    this.dadosEmpresa = dadosEmpresa;
    this.dadosUsuario = dadosUsuario;
    await Firestore.instance
        .collection("pedidos")
        .add(dadosPedido)
        .then((doc){
          this.id = doc.documentID;
        });

    await Firestore.instance
    .collection("pedidos")
    .document(id)
    .collection("cliente")
    .document("IDcliente")
    .setData(dadosEmpresa);

    await Firestore.instance
    .collection("pedidos")
    .document(id)
    .collection("vendedor")
    .document("IDvendedor")
    .setData(dadosUsuario);
  }

  Future<Null> editarPedido(Map<String, dynamic> dadosPedido, Map<String, dynamic> dadosEmpresa, Map<String, dynamic> dadosUsuario, String idFirebase) async {
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

  void adicionarItem(ItemPedido item){
    itens.add(item);

//Salva o item no firebase e após salvar pega o id gerado automaticamente e atribui ao item
    Firestore.instance.collection("pedidos")
    .document(id)
    .collection("itens")
    .add(item.converterParaMapa())
    .then((doc){
      item.id = doc.documentID;
    });
  }

  void editarItem(ItemPedido item){
    Firestore.instance.collection("pedidos")
    .document(id).collection("itens")
    .document(item.id)
    .setData(item.converterParaMapa());

  }

  void removerItem(ItemPedido item){
    Firestore.instance.collection("pedidos")
    .document(id)
    .collection("itens")
    .document(item.id)
    .delete();

    itens.remove(item);
  }

Future<Empresa> obterEmpresa(String idPedido) async {
CollectionReference ref = Firestore.instance.collection('pedidos').document(idPedido).collection('cliente');
QuerySnapshot obterEmpresaPedido = await ref.getDocuments();

CollectionReference refCliente = Firestore.instance.collection('empresas');
QuerySnapshot obterDadosEmpresa = await refCliente.getDocuments();

  obterEmpresaPedido.documents.forEach((document) {
    empresa.id = document.data["id"];

      obterDadosEmpresa.documents.forEach((document1){
        if(empresa.id == document1.documentID){
        empresa = Empresa.buscarFirebase(document1);
        }
      });
  });
  return empresa;
}

Future<Usuario> obterUsuario(String idPedido) async {
CollectionReference ref = Firestore.instance.collection('pedidos').document(idPedido).collection('vendedor');
QuerySnapshot obterUsuario = await ref.getDocuments();

CollectionReference refCliente = Firestore.instance.collection('usuarios');
QuerySnapshot obterDadosUsuario = await refCliente.getDocuments();

  obterUsuario.documents.forEach((document) {
    user.id = document.data["id"];

      obterDadosUsuario.documents.forEach((document1){
        if(user.id == document1.documentID){
        user = Usuario.buscarFirebase(document1);
        }
      });
  });
  return user;
}

void calcularDesconto(){
  if(valorTotal != 0 || valorTotal == 0){
    double vlDesc = (percentualDesconto/100)*valorTotal;
    valorTotal = (valorTotal - vlDesc);
  }else{
    valorTotal = 0;
  }
}

}