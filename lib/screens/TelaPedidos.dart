import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_2/model/PedidoVenda.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaCRUDPedido.dart';

class TelaPedidos extends StatefulWidget {
  @override
  _TelaPedidosState createState() => _TelaPedidosState();
}

class _TelaPedidosState extends State<TelaPedidos> {

  Usuario u = Usuario();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usuario>(
      builder: (context, child, model){
        u.id = model.dadosUsuarioAtual["id"];
        u.nome = model.dadosUsuarioAtual["nome"];
        u.email = model.dadosUsuarioAtual["email"];
        u.cpf = model.dadosUsuarioAtual["cpf"];
        u.ehAdministrador = model.dadosUsuarioAtual["ehAdministrador"];
        u.ativo = model.dadosUsuarioAtual["ativo"];

      return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            print(u.nome);
            print(model.nome);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaCRUDPedido(user: u,))
            );
          }
      ),
      body: FutureBuilder<QuerySnapshot>(
        //O sistema ira acessar o documento "pedidos"
          future: Firestore.instance
              .collection("pedidos").getDocuments(),
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
                    PedidoVenda pedidoVenda =
                    PedidoVenda.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaPedidos(context, pedidoVenda, snapshot.data.documents[index],u);
                  });
          }),
    );
      });
    
    
    /**/
  }

  Widget _construirListaPedidos(contexto, PedidoVenda p, DocumentSnapshot snapshot, Usuario u){
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
                        p.id,
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
        Navigator.of(contexto).push(MaterialPageRoute(builder: (contexto)=>TelaCRUDPedido(pedidoVenda: p,snapshot: snapshot, user: u)));
      },
    );
  }
}