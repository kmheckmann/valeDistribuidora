import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/ItemPedido.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/screens/TelaCRUDItemPedido.dart';

class TelaItensPedido extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final DocumentSnapshot snapshot;

  TelaItensPedido({this.pedidoVenda, this.snapshot});
  @override
  _TelaItensPedidoState createState() => _TelaItensPedidoState(pedidoVenda: pedidoVenda,snapshot: snapshot);
}

class _TelaItensPedidoState extends State<TelaItensPedido> {
  final DocumentSnapshot snapshot;
  PedidoVenda pedidoVenda;
  _TelaItensPedidoState({this.pedidoVenda, this.snapshot});

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => TelaCRUDItemPedido(pedidoVenda: pedidoVenda,))
            );
          }
      ),
      body: FutureBuilder<QuerySnapshot>(
        //O sistema ira acessar o documento "pedidos" e depois a coleção de itens dos pedidos
          future: Firestore.instance
              .collection("pedidos").document(snapshot.documentID).collection("itens").getDocuments(),
          builder: (context, snapshot) {
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
                  itemBuilder: (context, index) {
                    ItemPedido itemPedido = ItemPedido.buscarFirebase(snapshot.data.documents[index]);
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
                        "a",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 120, 189),
                            fontSize: 20.0),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
      onTap: (){
        Navigator.of(contexto).push(MaterialPageRoute(builder: (contexto)=>TelaCRUDItemPedido(pedidoVenda: pedidoVenda, itemPedido: p,snapshot: snapshot,)));
      },
    );
  }

}