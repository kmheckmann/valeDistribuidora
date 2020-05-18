import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Categoria.dart';
import 'package:tcc_2/model/Produto.dart';

class ProdutoController{

  bool existeCadastroCodigo;
  bool existeCadastroCodigoBarra;
  String proxID;


  ProdutoController();

  Categoria categoria = Categoria();

  Map<String, dynamic> dadosProduto = Map();
  Map<String, dynamic> dadosCategoria = Map();

  Map<String, dynamic> converterParaMapa(Produto produto){
    return{
     "codigo": produto.codigo,
     "codBarra": produto.codBarra,
     "descricao": produto.descricao,
     "percentLucro": produto.percentualLucro,
     "ativo": produto.ativo
    };
  }

  Future<Null> salvarProduto(Map<String, dynamic> dadosProduto, Map<String, dynamic> dadosCategoria, String id) async {
    this.dadosProduto = dadosProduto;
    this.dadosCategoria = dadosCategoria;
    await Firestore.instance
        .collection("produtos")
        .document(id)
        .setData(dadosProduto);

        await Firestore.instance
        .collection("produtos")
        .document(id)
        .collection("categoria")
        .document("IdCategoria")
        .setData(dadosCategoria);
  }

  Future<Null> editarProduto(Map<String, dynamic> dadosProduto, Map<String, dynamic> dadosCategoria,String idFirebase) async {
    this.dadosProduto = dadosProduto;
    this.dadosCategoria = dadosCategoria;
    await Firestore.instance
        .collection("produtos")
        .document(idFirebase)
        .setData(dadosProduto);

        await Firestore.instance
        .collection("produtos")
        .document(idFirebase)
        .collection("categoria")
        .document("IdCategoria")
        .setData(dadosCategoria);
  }

  Future<Null> obterProxID() async{
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("produtos");
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

  Future<Null> obterCategoria(String idProduto) async{
    Categoria c = Categoria();
    //Busca a categoria vinculada ao produto (dentro do produto está salvo somente o ID da categoria)
    CollectionReference ref = Firestore.instance.collection('produtos').document(idProduto).collection('categoria');
    QuerySnapshot obterCategoria = await ref.getDocuments();

    //Busca todas as categorias cadastradas
    CollectionReference refCliente = Firestore.instance.collection('categorias');
    QuerySnapshot obterDadosCategoria = await refCliente.getDocuments();

    //Pega o ID da categoria vinculada ao produto e compara com os IDs das categorias cadastradas
    //Se o ID da categoria vinculada ao produto for igual ao ID de uma das categorias cadastradas, atribui as informações dessa categoria a categoria vinculada ao produto
    obterCategoria.documents.forEach((document){
      c.id = document.data["id"];
      obterDadosCategoria.documents.forEach((document1){
        if(c.id == document1.documentID){
          c = Categoria.buscarFirebase(document1);
        }
      });
    });
    this.categoria = c;
  }

  Future<Null> verificarExistenciaCodigoProduto(int cod) async {
    //Busca todos os produtos cadastrados
    CollectionReference ref = Firestore.instance.collection("produtos");
  //Verifica se existe algum com o mesmo codigo informado no cadastro atual
  //se houver atribui true para a variável
    QuerySnapshot eventsQuery = await ref
    .where("codigo", isEqualTo: cod)
    .getDocuments();

    if(eventsQuery.documents.length > 0){
      existeCadastroCodigo = true;
    }else{
      existeCadastroCodigo = false;
    }
  }

  Future<Null> verificarExistenciaCodigoBarrasProduto(int codBarras) async {
    //Busca todos os produtos cadastrados
    CollectionReference ref = Firestore.instance.collection("produtos");
  //Verifica se existe algum com o mesmo codigo informado no cadastro atual
  //se houver atribui true para a variável
    QuerySnapshot eventsQuery = await ref
    .where("codBarra", isEqualTo: codBarras)
    .getDocuments();

    if(eventsQuery.documents.length > 0){
      existeCadastroCodigoBarra = true;
    }else{
      existeCadastroCodigoBarra = false;
    }
  }
}