import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Categoria.dart';

class CategoriaController {

  bool existeCadastro;
  String proxID;
  CategoriaController();
  Categoria categoria = Categoria();

  Map<String, dynamic> dadosCategoria = Map();

  Map<String, dynamic> converterParaMapa(Categoria categoria) {
    return {
      "descricao": categoria.descricao,
      "ativa": categoria.ativa,
    };
  }

    Future<Null> salvarCategoaria(Map<String, dynamic> dadosCategoria, String id) async {
    this.dadosCategoria = dadosCategoria;
    await Firestore.instance
        .collection("categorias")
        .document(id)
        .setData(dadosCategoria);
  }

  Future<Null> editarCategoria(Map<String, dynamic> dadosCategoria, String idFirebase) async {
    this.dadosCategoria = dadosCategoria;
    await Firestore.instance
        .collection("categorias")
        .document(idFirebase)
        .setData(dadosCategoria);
  }

  Future<Null> obterProxID() async{
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("categorias");
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

  Future<Null> verificarExistenciaCategoria(String descricao) async {
    //Busca todas as categoria cadastradas
    CollectionReference ref = Firestore.instance.collection("categorias");
  //Nas categorias cadastradas verifica se existe alguma com o mesmo nome e estado informados no cadastro atual
    QuerySnapshot eventsQuery = await ref
    .where("descricao", isEqualTo: descricao).getDocuments(); 
    print(eventsQuery.documents.length);   

    if(eventsQuery.documents.length > 0){
      existeCadastro = true;
    }else{
      existeCadastro = false;
    }
  }

  Future<Null> obterCategoriaPorDescricao(String descricao) async {
  CollectionReference ref = Firestore.instance.collection("categorias");
  QuerySnapshot eventsQuery = await ref
    .where("descricao", isEqualTo: descricao)
    .getDocuments();

  eventsQuery.documents.forEach((document) {
  Categoria c = Categoria.buscarFirebase(document);
  c.id = document.documentID;
  categoria = c;
  });
}
}