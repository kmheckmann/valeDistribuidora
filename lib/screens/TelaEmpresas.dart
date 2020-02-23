import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:tcc_2/screens/TelaCRUDEmpresa.dart';

class TelaEmpresas extends StatefulWidget {
  @override
  _TelaEmpresasState createState() => _TelaEmpresasState();
}

class _TelaEmpresasState extends State<TelaEmpresas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaCRUDEmpresa())
            );
          }
      ),
      body: FutureBuilder<QuerySnapshot>(
        //O sistema ira acessar o documento "cidades"
          future: Firestore.instance
              .collection("empresas").getDocuments(),
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
                    Empresa empresa =
                    Empresa.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaEmpresas(context, empresa, snapshot.data.documents[index]);
                  });
          }),
    );
  }

  Widget _construirListaEmpresas(contexto, Empresa e, DocumentSnapshot snapshot){
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar na empresa
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao da empresa seja maior que a largura da tela
            Flexible(
              //padding: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        e.razaoSocial,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 120, 189),
                            fontSize: 20.0),
                      ),
                      Text(
                        e.ativo ? "Ativa" : "Inativa",
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
        Navigator.of(contexto).push(MaterialPageRoute(builder: (contexto)=>TelaCRUDEmpresa(empresa: e,snapshot: snapshot)));
      },
    );
  }
}
