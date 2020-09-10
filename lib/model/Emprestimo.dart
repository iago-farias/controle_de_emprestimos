
class Emprestimo {
  String _tipoObjeto;
  String _nomeCliente;
  String _descricao;
  bool _devolvido;
  DateTime _dataRetirada;

  Emprestimo(this._tipoObjeto, this._nomeCliente, this._descricao, this._devolvido, this._dataRetirada);

  String get tipoObjeto => _tipoObjeto;
  String get nomePessoa => _nomeCliente;
  String get descricao => _descricao;
  bool get devolvido => _devolvido;
  DateTime get dataRetirada => _dataRetirada;
  

  Map getEmprestimo(){
    Map<String, dynamic> emprestimo = Map();
    emprestimo["tipo_do_objeto"] = _tipoObjeto;
    emprestimo["nome_do_cliente"] = _nomeCliente;
    emprestimo["descricao"] = _descricao;
    emprestimo["devolvido"] = _devolvido;
    emprestimo["data_retirada"] = _dataRetirada;

    return emprestimo;
  }

}