import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/ItemPedidoController.dart';
import 'package:tcc_2/controller/ProdutoController.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/Pedido.dart';
import 'package:tcc_2/model/PedidoCompra.dart';
import 'package:tcc_2/model/Produto.dart';
import 'package:tcc_2/screens/TelaCRUDItemPedidoCompra.dart';

class TelaItensPedidoCompra extends StatefulWidget {
  final PedidoCompra pedidoCompra;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaItensPedidoCompra({this.pedidoCompra, this.itemPedido, this.snapshot});

  @override
  _TelaItensPedidoCompraState createState() => _TelaItensPedidoCompraState(snapshot, pedidoCompra, itemPedido);
}

class _TelaItensPedidoCompraState extends State<TelaItensPedidoCompra> {
  final DocumentSnapshot snapshot;
  ItemPedido itemPedido;
  PedidoCompra pedidoCompra;
  ItemPedidoController _controller = ItemPedidoController();

  _TelaItensPedidoCompraState(this.snapshot, this.pedidoCompra, this.itemPedido);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Itens do Pedido"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaCRUDItemPedidoCompra(pedidoCompra: pedidoCompra,))
            );
          }
      ),
      body: FutureBuilder<QuerySnapshot>(
        //O sistema ira acessar o documento "pedidos" e depois a coleção de itens dos pedidos
          future: Firestore.instance
              .collection("pedidos").document(pedidoCompra.id).collection("itens").getDocuments(),
          builder: (context, snapshot){
            //Como os dados serao buscados do firebase, pode ser que demore para obter
            //entao, enquanto os dados nao sao obtidos sera apresentado um circulo na tela
            //indicando que esta carregando
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return ListView.builder(
                  padding: EdgeInsets.all(4.0),
                  //Pega a quantidade de cidades
                  itemCount: snapshot.data.documents.length,
                  //Ira pegar cada cidade no firebase e retornar
                  itemBuilder: (context, index){
                    _controller.obterProduto(pedidoCompra.id);
                    ItemPedido itemPedido = ItemPedido.buscarFirebase(snapshot.data.documents[index]);
                    itemPedido.produto = _controller.produto;
                    return _construirListaPedidos(context, itemPedido, snapshot.data.documents[index]);
                  });
          }),
    );
  }

  Widget _construirListaPedidos(contexto, ItemPedido p, DocumentSnapshot snapshot){
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar no produto
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao do produto seja maior que a largura da tela
            Flexible(
              //padding: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        snapshot.data["label"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 120, 189),
                            fontSize: 20.0),
                      ),
                      Text(
                        "Preço: ${snapshot.data["preco"]}",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Qtde: ${snapshot.data["quantidade"]}",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
      onTap: () async{
        await _controller.obterProduto(pedidoCompra.id);
        p.produto = _controller.produto;
        Navigator.of(contexto).push(MaterialPageRoute(builder: (contexto)=>TelaCRUDItemPedidoCompra(pedidoCompra: pedidoCompra, itemPedido: p,snapshot: snapshot,)));
      },
    );
  }
}