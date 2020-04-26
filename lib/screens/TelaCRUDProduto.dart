import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_2/controller/ProdutoController.dart';
import 'package:tcc_2/model/Categoria.dart';
import 'package:tcc_2/model/Produto.dart';

class TelaCRUDProduto extends StatefulWidget {
  final Produto produto;

  final DocumentSnapshot snapshot;

  TelaCRUDProduto({this.produto, this.snapshot});

  @override
  _TelaCRUDProdutoState createState() =>
      _TelaCRUDProdutoState(produto, snapshot);
}

class _TelaCRUDProdutoState extends State<TelaCRUDProduto> {
  Produto produto;
  final DocumentSnapshot snapshot;

  _TelaCRUDProdutoState(this.produto, this.snapshot);

  final _validadorCampos = GlobalKey<FormState>();
  final _controllerCodigo = TextEditingController();
  final _controllerDescricao = TextEditingController();
  final _controllerCodBarra = TextEditingController();
  final _controllerPrecoCompra = TextEditingController();
  final _controllerPrecoVenda = TextEditingController();
  final _controllerQtdEstoque = TextEditingController();
  ProdutoController controllerProduto = ProdutoController();
  Categoria categoria;
  bool _existeCadastroCodigo;
  bool _existeCadastroCodigoBarra;
  bool _novocadastro;
  String _nomeTela;

  @override
  void initState() {
    super.initState();
    _existeCadastroCodigo = false;
    _existeCadastroCodigoBarra = false;
    if (produto != null) {
      _nomeTela = "Editar Produto";
      _novocadastro = false;
      _controllerCodigo.text = produto.codigo.toString();
      _controllerDescricao.text = produto.descricao;
      _controllerCodBarra.text = produto.codBarra.toString();
      _controllerPrecoCompra.text = produto.precoCompra.toString();
      _controllerPrecoVenda.text = produto.precoVenda.toString();
      _controllerQtdEstoque.text = produto.qtdEstoque.toString();
    } else {
      _nomeTela = "Cadastrar Produto";
      produto = Produto();
      produto.ativo = true;
      _novocadastro = true;
      produto.qtdEstoque = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_nomeTela),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.blue,
          onPressed: () async{
            if(_validadorCampos.currentState.validate()){
              Map<String, dynamic> mapa = controllerProduto.converterParaMapa(produto);
              Map<String, dynamic> mapaCategoria = Map();
              mapaCategoria["id"] = categoria.id;
            if(_novocadastro){
              await controllerProduto.obterProxID();
              produto.id = controllerProduto.proxID;
              controllerProduto.salvarProduto(mapa, mapaCategoria, produto.id);
            }else{
              controllerProduto.editarProduto(mapa, mapaCategoria, produto.id);
            }
            Navigator.of(context).pop();
            }
          }),
      body: Form(
        key: _validadorCampos,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            _criarCampoText(_controllerCodigo, "Código", TextInputType.number),
            _criarCampoText(
                _controllerDescricao, "Descrição", TextInputType.text),
            _criarCampoCodBarra(),
            _criarCampoText(
                _controllerPrecoCompra, "Preço Compra", TextInputType.number),
            _criarCampoText(
                _controllerPrecoVenda, "Preço Venda", TextInputType.number),
            Container(
              padding: EdgeInsets.all(6.0),
              child: TextField(
                controller: _controllerQtdEstoque,
                keyboardType: TextInputType.number,
                enabled: false,
                decoration: InputDecoration(labelText: "Quantidade em Estoque"),
                style: TextStyle(color: Colors.grey, fontSize: 17.0),
              ),
            ),
            _criarCampoCheckBox()
          ],
        ),
      ),
      
    );
  }

  Widget _criarCampoText(
      TextEditingController controller, String nome, TextInputType tipo) {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: controller,
          keyboardType: tipo,
          decoration: InputDecoration(
            hintText: nome,
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text){
            if(text.isEmpty) return "É necessário informar este campo!";
            if(_existeCadastroCodigo && text.isNotEmpty) return "Já existe um produto com esse código, verifique!";      
          },
          onChanged: (texto) {
            switch (nome) {
              case "Descrição":
                produto.descricao = texto;
                break;
              case "Código":
                produto.codigo = int.parse(texto);
                _verificarExistenciaProduto();
                break;
              case "Preço Compra":
                produto.precoCompra = double.parse(texto);
                break;
              case "Preço Venda":
                produto.precoVenda = double.parse(texto);
                break;
            }
          },
        ));
  }

  Widget _criarCampoCodBarra() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerCodBarra,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Código de Barra",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text){
            if(text.isEmpty) return "É necessário informar este campo!";
            if(_existeCadastroCodigoBarra && text.isNotEmpty) return "Já existe um produto com esse código de barras, verifique!";
          },
          onChanged: (texto) {
                produto.codBarra = int.parse(texto);
                _verificarExistenciaProduto();
          },
        ));
  }
  

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: produto.ativo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  produto.ativo = true;
                } else {
                  produto.ativo = false;
                }
              });
            },
          ),
          Text(
            "Ativo?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

    void _verificarExistenciaProduto() async {
    //Busca todas as cidades cadastradas
    CollectionReference ref = Firestore.instance.collection("produtos");
  //Nas cidades cadastradas verifica se existe alguma com o mesmo nome informado no cadastro atual
  //se houver atribui tru para a variável _existeCadastro
    QuerySnapshot eventsQuery = await ref
    .where("codigo", isEqualTo: produto.codigo)
    .getDocuments();

    QuerySnapshot eventsQuery1 = await ref
    .where("codBarra", isEqualTo: produto.codBarra)
    .getDocuments();

    print(eventsQuery.documents.length);
    if(eventsQuery.documents.length > 0){
      _existeCadastroCodigo = true;
    }else{
      _existeCadastroCodigo = false;
    }

    print(eventsQuery1.documents.length);
    if(eventsQuery1.documents.length > 0){
      _existeCadastroCodigoBarra = true;
    }else{
      _existeCadastroCodigoBarra = false;
    }
  }
}
