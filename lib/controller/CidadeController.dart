import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Cidade.dart';

class CidadeController {
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

  Future<Null> editarCidade(
      Map<String, dynamic> dadosCidade, String idFirebase) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document(idFirebase)
        .setData(dadosCidade);
  }

  Future<Null> obterProxID() async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("cidades");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document) {
      docID = int.parse(document.documentID);
      if (eventsQuery.documents.length == 0) {
        idTemp = 1;
        proxID = idTemp.toString();
      } else {
        if (docID > idTemp) {
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp + 1;
    proxID = idTemp.toString();
  }

  Future<Null> obterCidadePorNome(String nomeEestado) async {
    //Utilizado pelo cadastro de empresas, para saber qual o codigo da cidade selecionada no comboBox do cadastroF
    var array = nomeEestado.split(" - ");
    String nome = array[0];
    String estado = array[1];
    CollectionReference ref = Firestore.instance.collection("cidades");
    QuerySnapshot eventsQuery =
        await ref.where("nome", isEqualTo: nome).getDocuments();

    eventsQuery.documents.forEach((document) {
      if (document.data['estado'] == estado) {
        Cidade c = Cidade.buscarFirebase(document);
        c.id = document.documentID;
        cidade = c;
      }
    });
  }

  Future<Null> verificarExistenciaCidade(Cidade c, bool novoCad) async {
    int qtde = 0;
    //Busca todas as cidades cadastradas
    CollectionReference ref = Firestore.instance.collection("cidades");
    //Nas cidades cadastradas verifica se existe alguma com o mesmo nome e estado informados no cadastro atual
    //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery2 =
        await ref.where("estado", isEqualTo: c.estado).getDocuments();

    //Verificacao adicionada para contemplar o caso do usuario estar editando um registro existente
    //e alterar o texto e depois retornar ao original
    eventsQuery2.documents.forEach((document) {
      if (document.data["nome"] == c.nome) {
        qtde += 1;
      }
    });

    //Se for um novo cadastro a quantidade de registros nao pode ser maior que zero
    //pois não pode existir registros com a mesma descricao
    if (novoCad == true) {
      if (qtde == 1) {
        existeCadastro = true;
      } else {
        existeCadastro = false;
      }
    } else {
      //Se não for um novo cadastro, já existe 1 registro,
      //então caso o usuario altere o texto e depois tente voltar ao original e salvar não será impedido
      if (qtde > 1) {
        existeCadastro = true;
      } else {
        existeCadastro = false;
      }
    }
  }
}
