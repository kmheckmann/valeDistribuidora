import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Cidade.dart';
import 'package:tcc_2/model/Empresa.dart';
import 'package:cpfcnpj/cpfcnpj.dart';

class EmpresaController {
  EmpresaController();
  Empresa empresa = Empresa();
  Cidade cidade = Cidade();
  bool existeCadastroCNPJ = true;
  bool existeCadastroIE = true;

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

  Future<Null> salvarEmpresa(Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosCidade) async {
    this.dadosEmpresa = dadosEmpresa;
    this.dadosCidade = dadosCidade;
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

  Future<Null> editarEmpresa(Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosCidade, String idFirebase) async {
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
    CollectionReference ref = Firestore.instance
        .collection('empresas')
        .document(idEmpresa)
        .collection('cidade');
    QuerySnapshot obterCidadeDaEmpresa = await ref.getDocuments();

    CollectionReference refCidade = Firestore.instance.collection('cidades');
    QuerySnapshot obterDadosCidade = await refCidade.getDocuments();

    obterCidadeDaEmpresa.documents.forEach((document) {
      c.id = document.data["id"];

      obterDadosCidade.documents.forEach((document1) {
        if (c.id == document1.documentID) {
          c = Cidade.buscarFirebase(document1);
        }
      });
    });
    this.cidade = c;
  }

  Future<Null> verificarExistenciaEmpresa(Empresa e, bool novoCadastro) async {
    Empresa emp;
    //Duas listas criadas para indicar corretamente ao usuario se já existe uma empresa com só com o mesmo CNPJ
    //Se existe uma empresa só com a mesma Inscrição Estadual ou ambos
    List<Empresa> empresasMesmoCNPJ = List<Empresa>();
    List<Empresa> empresasMesmaInscEstadual = List<Empresa>();
    //Busca todas as empresas cadastradas
    CollectionReference ref = Firestore.instance.collection("empresas");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document) {
      //Para cada empresa retornada verificar se o CNPJ ou inscrição estadual
      //são iguais ao que está tentando ser atribuído ao novo cadastro
      //Se for, adiciona na lista correspondente
      if (document.data["cnpj"] == e.cnpj) {
        emp = Empresa.buscarFirebase(document);
        emp.id = document.documentID;
        empresasMesmoCNPJ.add(emp);
      }

      if (document.data["inscEstadual"] == e.inscEstadual) {
        emp = Empresa.buscarFirebase(document);
        emp.id = document.documentID;
        empresasMesmaInscEstadual.add(emp);
      }
    });

    if (novoCadastro) {
      //Quando for um novo cadastro não pode existir nenhuma outra empresa com o mesmo cnpj e inscrição estadual
      //entao o tamanho da lista da empresa deve ser 0 para permitir adicionar o registro
      if (empresasMesmoCNPJ.length == 0 || empresasMesmoCNPJ.isEmpty)
        existeCadastroCNPJ = false;
      if (empresasMesmaInscEstadual.length == 0 ||
          empresasMesmaInscEstadual.isEmpty) existeCadastroIE = false;
    } else {
      //Se não for um novo cadastro, já existe 1 registro,
      //Existe a possibilidade do usuario alterar o valor e depois tentar voltar ao original
      //Para tratar isso será comparado o ID do cadastro existente com o que esta sendo alterado
      //Se forem diferentes, será informado que o cadastro já existe e não será possível salvar
      //Se forem iguais, permite salvar
      if (empresasMesmaInscEstadual.length == 1 &&
          empresasMesmaInscEstadual[0].id == e.id) existeCadastroIE = false;
      if (empresasMesmoCNPJ.length == 1 && empresasMesmoCNPJ[0].id == e.id)
        existeCadastroCNPJ = false;
    }
  }

  //Método utilizado pela tela te pedidos
  //seleciona-se a empresa no comboBox e pelo nome fantasia busca os outros dados da empresa
  Future<Empresa> obterEmpresaPorDescricao(String nomeEmpresa) async {
    Empresa emp;
    CollectionReference ref = Firestore.instance.collection('empresas');
    QuerySnapshot eventsQuery =
        await ref.where("razaoSocial", isEqualTo: nomeEmpresa).getDocuments();

    eventsQuery.documents.forEach((document) {
      emp = Empresa.buscarFirebase(document);
      emp.id = document.documentID;
    });
    return Future.value(emp);
  }
}
