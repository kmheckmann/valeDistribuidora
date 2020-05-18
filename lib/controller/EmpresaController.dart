import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Cidade.dart';
import 'package:tcc_2/model/Empresa.dart';

class EmpresaController{

  EmpresaController();
  Empresa empresa = Empresa();
  Cidade cidade = Cidade();
  bool existeCadastroCNPJ;
  bool existeCadastroIE;

  Map<String, dynamic> dadosEmpresa = Map();
  Map<String, dynamic> dadosCidade = Map();

  Map<String, dynamic> converterParaMapa(Empresa e) {
    return {
      "razaoSocial": e.razaoSocial,
      "nomeFantasia": e.nomeFantasia,
      "cnpj": e.cnpj,
      "inscEstadual": e.inscEstadual,
      "cep": e.cep,
      "bairro": e.bairro,
      "logradouro": e.logradouro,
      "numero": e.numero,
      "telefone": e.telefone,
      "email": e.email,
      "ativo": e.ativo,
      "ehFornecedor": e.ehFornecedor
    };
  }

  Future<Null> salvarEmpresa(Map<String, dynamic> dadosEmpresa, Map<String, dynamic> dadosCidade) async {
    this.dadosEmpresa = dadosEmpresa;
    this.dadosCidade = dadosCidade;
    print(dadosCidade["id"]);
    await Firestore.instance
        .collection("empresas")
        .document(dadosEmpresa["cnpj"])
        .setData(dadosEmpresa);

    await Firestore.instance
    .collection("empresas")
    .document(dadosEmpresa["cnpj"])
    .collection("cidade")
    .document("IDcidade")
    .setData(dadosCidade);
  }

  Future<Null> editarEmpresa(
      Map<String, dynamic> dadosEmpresa, Map<String, dynamic> dadosCidade, 
      String idFirebase) async {
    this.dadosEmpresa = dadosEmpresa;
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("empresas")
        .document(idFirebase)
        .setData(dadosEmpresa);

    await Firestore.instance
        .collection("empresas")
        .document(idFirebase)
        .collection("cidade")
        .document("IDcidade")
        .setData(dadosCidade);
  }

  //Método para buscar os valores da cidade na subcoleção dentro da empresa
Future<Null> obterCidadeEmpresa(String idEmpresa) async {
  Cidade c = Cidade();
  CollectionReference ref = Firestore.instance.collection('empresas').document(idEmpresa).collection('cidade');
  QuerySnapshot obterCidadeDaEmpresa = await ref.getDocuments();

  CollectionReference refCidade = Firestore.instance.collection('cidades');
  QuerySnapshot obterDadosCidade = await refCidade.getDocuments();

  obterCidadeDaEmpresa.documents.forEach((document) {
  c.id = document.data["id"];

  obterDadosCidade.documents.forEach((document1){
  if(c.id == document1.documentID){
    c = Cidade.buscarFirebase(document1);
  }
});
});
  this.cidade = c;
 }

 Future<Null> verificarExistenciaEmpresa(Empresa e) async {
    //Busca todas as empresas cadastradas
    CollectionReference ref = Firestore.instance.collection("empresas");
  //Nas empresas cadastradas verifica se existe alguma com o mesmo cnpj e IE do cadastro atual
  //se houver atribui true para a variável _existeCadastro
    QuerySnapshot eventsQuery = await ref
    .where("inscEstadual", isEqualTo: e.inscEstadual)
    .getDocuments();

    QuerySnapshot eventsQuery1 = await ref
    .where("cnpj", isEqualTo: e.cnpj)
    .getDocuments();

    if(eventsQuery.documents.length > 0){
      existeCadastroIE = true;
    }else{
      existeCadastroIE = false;
    }

    if(eventsQuery1.documents.length > 0){
      existeCadastroCNPJ = true;
    }else{
      existeCadastroCNPJ = false;
    }
  }
}