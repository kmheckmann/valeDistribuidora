import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Cidade.dart';

class CidadeController{

  String proxID;
  Cidade cidade = Cidade();
  bool existeCadastro;

  CidadeController();

  Map<String, dynamic> dadosCidade = Map();

  
  Map<String, dynamic> converterParaMapa(Cidade c) {
    return {
      "nome": c.nome,
      "estado": c.estado,
      "ativa": c.ativa,
    };
  }

  Future<Null> salvarCidade(Map<String, dynamic> dadosCidade, String id) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document(id)
        .setData(dadosCidade);
  }

  Future<Null> editarCidade(Map<String, dynamic> dadosCidade, String idFirebase) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document(idFirebase)
        .setData(dadosCidade);
  }

  Future<Null> obterProxID() async{
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("cidades");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document){
      docID = int.parse(document.documentID);
      if(eventsQuery.documents.length == 0){
        idTemp = 1;
        proxID = idTemp.toString();
      }else{
        if(docID > idTemp){
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp+1;
    proxID = idTemp.toString();
  }

  Future<Null> obterCidadePorNome(String nome) async {
  CollectionReference ref = Firestore.instance.collection("cidades");
  QuerySnapshot eventsQuery = await ref
    .where("nome", isEqualTo: nome)
    .getDocuments();

  eventsQuery.documents.forEach((document) {
  Cidade c = Cidade.buscarFirebase(document);
  c.id = document.documentID;
  cidade = c;
  });
}

  Future<Null> verificarExistenciaCidade(Cidade c) async {
    //Busca todas as cidades cadastradas
    CollectionReference ref = Firestore.instance.collection("cidades");
  //Nas cidades cadastradas verifica se existe alguma com o mesmo nome e estado informados no cadastro atual
  //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery2 = await ref
    .where("estado", isEqualTo: c.estado)
    .getDocuments();
    eventsQuery2.documents.forEach((document){
      print(document.data["nome"]);
      print(document.data["estado"]);
      if(document.data["nome"] == c.nome && document.data["estado"] == c.estado){
        existeCadastro = true;
      }
      if(document.data["nome"] != c.nome || document.data["estado"] != c.estado){
        existeCadastro = false;
      }
    });
  }

}