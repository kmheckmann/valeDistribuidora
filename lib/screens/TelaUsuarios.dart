import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaUsuario.dart';


class TelaUsuarios extends StatefulWidget {
  @override
  _TelaUsuariosState createState() => _TelaUsuariosState();
}

class _TelaUsuariosState extends State<TelaUsuarios> {
  //esse documento ira passar a qual categoria o produto pertence

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaUsuario())
            );
          }
      ),
      body: FutureBuilder<QuerySnapshot>(
        //O sistema ira acessar o documento "usuarios"
          future: Firestore.instance
              .collection("usuarios").getDocuments(),
          //O FutureBuilder do tipo QuerySnapshot eh para obter todos os itens de uma colecao,
          //no caso a colecao itens dentro da categoria
          builder: (context, snapshot) {
            //Como os dados serao buscados do direbase, pode ser que demore para obter
            //entao, enquanto os dados nao sao obtidos sera apresentado um circulo na tela
            //indicando que esta carregando
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return ListView.builder(
                  padding: EdgeInsets.all(4.0),
                  //Pega a quantidade de produtos
                  itemCount: snapshot.data.documents.length,
                  //Ira pegar cada produto da categoria no firebase e retornar
                  itemBuilder: (context, index) {
                    Usuario usuario =
                    Usuario.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaProdutos(context, usuario, snapshot.data.documents[index]);
                  });
          }),
    );
  }

  Widget _construirListaProdutos(contexto, Usuario u, DocumentSnapshot snapshot){
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
                        u.nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 120, 189),
                            fontSize: 20.0),
                      ),
                      Text(
                        u.email,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        u.ehAdministrador ? "Administrador" : "",
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
      onTap: (){
        Navigator.of(contexto).push(MaterialPageRoute(builder: (contexto)=>TelaUsuario(usuario: u, snapshot: snapshot,)));
      },
    );
  }
}

