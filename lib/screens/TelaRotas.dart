import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_2/controller/RotaController.dart';
import 'package:tcc_2/model/Usuario.dart';
import 'package:tcc_2/screens/TelaCRUDRota.dart';
import 'package:tcc_2/model/Rota.dart';

class TelaRotas extends StatefulWidget {
  @override
  _TelaRotasState createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  RotaController _controller = RotaController();
  Usuario u = Usuario();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usuario>(builder: (context, child, model) {
      u.nome = model.dadosUsuarioAtual["nome"];
      u.email = model.dadosUsuarioAtual["email"];
      u.cpf = model.dadosUsuarioAtual["cpf"];
      u.ehAdministrador = model.dadosUsuarioAtual["ehAdm"];
      u.ativo = model.dadosUsuarioAtual["ativo"];
      return Scaffold(
        //Cria botão para adicionar
        floatingActionButton: Visibility(
            visible: u.ehAdministrador,
            child: FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  //Ao pressionar o botão direciona para a tela de cadastro
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TelaCRUDRota(
                            user: u,
                          )));
                  setState(() {});
                })),
        //Corpo da tela atual
        body: FutureBuilder<QuerySnapshot>(
            //O sistema ira acessar o documento "cidades"
            future: u.ehAdministrador
                ? Firestore.instance.collection("rotas").getDocuments()
                : Firestore.instance
                    .collection("rotas")
                    .where("idv", isEqualTo: model.usuarioFirebase.uid)
                    .getDocuments(),
            //O builder será responsável por construir os cards que listarão as rotas
            //de acordo com o que está armazenado no firebase
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
                    //ListViewBuilder é o que faz os cards serem criados
                    padding: EdgeInsets.all(4.0),
                    //Pega a quantidade de cidades
                    itemCount: snapshot.data.documents.length,
                    //Ira pegar cada cidade no firebase e retornar
                    itemBuilder: (context, index) {
                      //Para cada item da lista do build irá chamar o método que controi o card
                      Rota rota =
                          Rota.buscarFirebase(snapshot.data.documents[index]);
                      return _construirCardRotas(
                          context, rota, snapshot.data.documents[index]);
                    });
            }),
      );
    });
  }

  Widget _construirCardRotas(contexto, Rota r, DocumentSnapshot snapshot) {
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar no produto
      child: Card(
        //Componente card que vai apresentar os dados
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
                  //O que está dentro do children irá fazer ser mostrado na tela
                  //as informações da rota
                  Text(
                    r.getTituloRota,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: corTitulo(r.getAtiva),
                        fontSize: 20.0),
                  ),
                  Text(
                    r.getAtiva ? "Ativa" : "Inativa",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: corSituacao(r.getAtiva)),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () async {
        //Se for clicado no card busca os dados do vendedor e cliente e atribui na rota
        r.setVendedor = await _controller.obterVendedor(r.getIdFirebase);
        r.setCliente = await _controller.obterCliente(r.getIdFirebase);
        //direciona para a tela onde será possível visualizar em detalhe a rota
        Navigator.of(contexto).push(MaterialPageRoute(
            builder: (contexto) => TelaCRUDRota(
                  rota: r,
                  snapshot: snapshot,
                  user: u,
                )));
      },
    );
  }

  Color corTitulo(bool situacao) {
    if (situacao == true) {
      return Color.fromARGB(255, 0, 120, 189);
    } else {
      return Color.fromARGB(255, 144, 144, 144);
    }
  }

  Color corSituacao(bool situacao) {
    if (situacao == true) {
      return Color.fromARGB(255, 0, 0, 0);
    } else {
      return Color.fromARGB(255, 144, 144, 144);
    }
  }
}
