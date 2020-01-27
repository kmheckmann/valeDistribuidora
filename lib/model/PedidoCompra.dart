import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Cidade.dart';
import 'package:tcc_2/model/Empresa.dart';

class PedidoCompra {
  //ID do documento no firebase
  String id;

  int codPedido;
  Empresa fornecedor;
  String razaoSocial;
  String nomeFantasia;
  String cnpj;
  String inscEstadual;
  String cep;
  Cidade cidade;
  String bairro;
  String logradouro;
  int numero;
  String telefone;
  String email;
  bool ativo;
  bool ehFornecedor;

  Map<String, dynamic> dadosPedidoCompra = Map();

  PedidoCompra();

  PedidoCompra.buscarFirebase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    razaoSocial = snapshot.data["razaoSocial"];
    nomeFantasia = snapshot.data["nomeFantasia"];
    cnpj = snapshot.data["cnpj"];
    inscEstadual = snapshot.data["inscEstadual"];
    cep = snapshot.data["cep"];
    cidade.id = snapshot.data["cidade"];
    bairro = snapshot.data["bairro"];
    logradouro = snapshot.data["logradouro"];
    numero = snapshot.data["numero"];
    telefone = snapshot.data["telefone"];
    email = snapshot.data["email"];
    ehFornecedor = snapshot.data["ehFornecedor"];
    ativo = snapshot.data["ativo"];
  }

  Map<String, dynamic> converterParaMapa() {
    return {
      "razaoSocial": razaoSocial,
      "nomeFantasia": nomeFantasia,
      "cnpj": cnpj,
      "inscEstadual": inscEstadual,
      "cep": cep,
      "cidade": cidade.id,
      "bairro": bairro,
      "logradouro": logradouro,
      "numero": numero,
      "telefone": telefone,
      "email": email,
      "atvo": ativo,
      "ehFornecedor": ehFornecedor
    };
  }

  Future<Null> salvarPedidoCompra(Map<String, dynamic> dadosEmpresa) async {
    this.dadosPedidoCompra = dadosEmpresa;
    await Firestore.instance
        .collection("empresas")
        .document()
        .setData(dadosEmpresa);
  }

  Future<Null> editarPedidoCompra(
      Map<String, dynamic> dadosEmpresa, String idFirebase) async {
    this.dadosPedidoCompra = dadosEmpresa;
    await Firestore.instance
        .collection("empresas")
        .document(idFirebase)
        .setData(dadosEmpresa);
  }
}
