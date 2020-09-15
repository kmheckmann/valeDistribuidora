import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_2/controller/PedidoController.dart';
import 'package:tcc_2/model/PedidoCompra.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaCRUDPedidoCompra.dart';
import 'package:intl/intl.dart';


class TelaPedidosCompra extends StatefulWidget {
  @override
  _TelaPedidosCompraState createState() => _TelaPedidosCompraState();
}

class _TelaPedidosCompraState extends State<TelaPedidosCompra> {

Usuario u = Usuario();
DateFormat format = DateFormat();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usuario>(
      builder: (context, child, model){
        u.nome = model.dadosUsuarioAtual["nome"];
        u.email = model.dadosUsuarioAtual["email"];
        u.cpf = model.dadosUsuarioAtual["cpf"];
        u.ehAdministrador = model.dadosUsuarioAtual["ehAdministrador"];
        u.ativo = model.dadosUsuarioAtual["ativo"];

      return ScopedModel<PedidoCompra>(
        model: PedidoCompra(),
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaCRUDPedidoCompra(vendedor: u,))
            );
          }
      ),
      body: FutureBuilder<QuerySnapshot>(
        //O sistema ira acessar o documento "pedidos"
          future: Firestore.instance
              .collection("pedidos").where("ehPedidoVenda", isEqualTo: false).getDocuments(),
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
                    PedidoCompra pedidoCompra =
                    PedidoCompra.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaPedidos(context, pedidoCompra, snapshot.data.documents[index],u);
                  });
          }),
    ),
      );
      });
    
    
    /**/
  }

  Widget _construirListaPedidos(contexto, PedidoCompra p, DocumentSnapshot snapshot, Usuario u){
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
                      Text(
                        "Fornecedor: ${p.labelTelaPedidos}",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Data: ${p.dataPedido.day}/${p.dataPedido.month}/${p.dataPedido.year} ${new DateFormat.Hms().format(p.dataPedido)}",
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
        PedidoController _controller = PedidoController();
        await _controller.obterEmpresa(p.id);
        p.empresa = _controller.empresa;
        await _controller.obterUsuario(p.id);
        p.user = _controller.usuario;
        Navigator.of(contexto).push(MaterialPageRoute(builder: (contexto)=>TelaCRUDPedidoCompra(pedidoCompra: p,snapshot: snapshot, vendedor: u)));
      },
    );
  }
}