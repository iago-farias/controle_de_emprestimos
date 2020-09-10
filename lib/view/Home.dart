import 'package:flutter/material.dart';
import 'dart:convert';
import '../model/Emprestimo.dart';
import '../persistence/FileManagement.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FileManagement fileManagement = FileManagement();

  List emprestimos = [];
  String selectedTypeValue = "Selecione o tipo do objeto";
  Map<String, dynamic> _ultimoRemovido;
  int _ultimoRemovidoPos;
  DateTime _dataInfo = DateTime.now();

  TextEditingController nomeClienteController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Função para carregar os empréstimos que já foram salvos
  @override
  void initState() {
    super.initState();
    fileManagement.readEmprestimo().then((dados) {
      setState(() {
        emprestimos = json.decode(dados);
      });
    });
  }

  void inserir() {
    setState(() {
      Map<String, dynamic> novoEmprestimo = Map();
      Emprestimo emprestimo = new Emprestimo(
          selectedTypeValue,
          nomeClienteController.text,
          descricaoController.text,
          false,
          _dataInfo);

      novoEmprestimo = emprestimo.getEmprestimo();

      selectedTypeValue = "Selecione o tipo do objeto";
      nomeClienteController.text = "";
      descricaoController.text = "";

      emprestimos.add(novoEmprestimo);

      fileManagement.saveEmprestimo(emprestimos);
    });
  }

  //Ordena a lista de empréstimos, os que não foram devolvidos aparecem primeiro
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      emprestimos.sort((a, b) {
        if (a["devolvido"] && !b["devolvido"])
          return 1;
        else if (!a["devolvido"] && b["devolvido"])
          return -1;
        else
          return 0;
      });
      fileManagement.saveEmprestimo(emprestimos);
    });
    return null;
  }

  //Formata a data selecionada para o padrão dd/mm/aaaa
  String dateFormat() {
    dynamic dia = _dataInfo.day;
    dynamic mes = _dataInfo.month;
    int ano = _dataInfo.year;

    if (dia < 10) {
      dia = "0$dia";
    }

    if (mes < 10) {
      mes = "0$mes";
    }

    return "$dia/$mes/$ano";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Controle de empréstimos"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Nome do cliente",
                      labelStyle: TextStyle(color: Colors.black38),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    controller: nomeClienteController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "O campo de nome do cliente deve ser preenchido";
                      }
                    },
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Tipo do objeto",
                          style: TextStyle(fontSize: 20),
                        ),
                        _buildDropdownButton(),
                      ],
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Descrição",
                      labelStyle: TextStyle(color: Colors.black38),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    controller: descricaoController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "O campo de descrição do objeto deve ser preenchido";
                      }
                    },
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Data do empréstimo",
                          style: TextStyle(fontSize: 20),
                        ),
                        _buildCalendarButton(),
                      ],
                    ),
                  ),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: emprestimos.length,
                  itemBuilder: buildItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(emprestimos[index]["nome_do_cliente"]),
        value: emprestimos[index]["devolvido"],
        secondary: CircleAvatar(
          child:
              Icon(emprestimos[index]["devolvido"] ? Icons.check : Icons.error),
        ),
        onChanged: (bool c) {
          setState(() {
            emprestimos[index]["devolvido"] = c;
            fileManagement.saveEmprestimo(emprestimos);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimoRemovido = Map.from(emprestimos[index]);
          _ultimoRemovidoPos = index;
          emprestimos.removeAt(index);
          fileManagement.saveEmprestimo(emprestimos);
          final snack = SnackBar(
            content: Text(
                "Empréstimo do cliente \"${_ultimoRemovido["nome_do_cliente"]}\"removido"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    emprestimos.insert(_ultimoRemovidoPos, _ultimoRemovido);
                    fileManagement.saveEmprestimo(emprestimos);
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  _buildCalendarButton() {
    return FlatButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            dateFormat(),
            style: TextStyle(fontSize: 18),
          ),
          Icon(Icons.calendar_today),
        ],
      ),
      onPressed: () async {
        final dataSelecionada = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1967),
          lastDate: DateTime(2050),
          builder: (BuildContext context, Widget child) {
            return Theme(
              data: ThemeData.dark(),
              child: child,
            );
          },
        );
        if (dataSelecionada != null && dataSelecionada != _dataInfo) {
          setState(() {
            _dataInfo = dataSelecionada as DateTime;
          });
        }
      },
    );
  }

  _buildSubmitButton() {
    return RaisedButton(
      child: Text(
        "Inserir",
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.indigo,
      onPressed: () {
        if (_formKey.currentState.validate()) {
          inserir();
        }
      },
    );
  }

  _buildDropdownButton() {
    return DropdownButton(
      value: selectedTypeValue,
      items: <String>[
        "Selecione o tipo do objeto",
        "Calça",
        "Sapato",
        "Camisa",
        "Paletó",
        "Gravata",
        "Outros"
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String newValue) {
        setState(() {
          selectedTypeValue = newValue;
        });
      },
    );
  }
}
