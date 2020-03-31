import 'package:flutter/material.dart';
import 'package:tcc_2/screens/TelaCidades.dart';
import 'package:tcc_2/screens/TelaEmpresas.dart';
import 'package:tcc_2/screens/TelaUsuario.dart';
import 'package:tcc_2/screens/TelaRotas.dart';
import 'package:tcc_2/screens/TelaUsuarios.dart';
import 'package:tcc_2/tabs/CategoriaTab.dart';
import 'package:tcc_2/tabs/HomeTab.dart';
import 'package:tcc_2/widgets/Menu.dart';

class HomeScreen extends StatelessWidget {

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      //Nao permite que seja possivel trocar as telas do pageView arrastando
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        //Chamada de cada uma das telas
        Scaffold(
          body: HomeTab(),
          drawer: Menu(_pageController),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Pedido de Venda"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: Container(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Empresas"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaEmpresas(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Cidades"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaCidades(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Categorias"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: Container(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Rotas"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaRotas(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Categorias"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: CategoriaTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Categorias"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: Container(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Categorias"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: Container(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Usuários"),
            centerTitle: true,
          ),
          drawer: Menu(_pageController),
          body: TelaUsuarios(),
        ),


      ],
    );
  }
}
