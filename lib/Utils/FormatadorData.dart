import 'package:intl/intl.dart';
String? ConverteDataParaDataAPI(String pDataPT){
var dataold;
var data;

dataold = pDataPT;
data =(dataold.substring( 6,10));
data = (data +'-'+ dataold.substring(3,5));
data = data +'-'+ dataold.substring(0,2);

return data;
}

int RetornaIdadeAtualizada(String pDataPT){
  int? _validNasc = 0;
  int? _AnoAtual = 0;
  int? _idade = 0;

  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy');
  String formatted = formatter.format(now);

  _validNasc = int.tryParse(pDataPT.substring( 6,10));
  _AnoAtual = int.tryParse(formatted);
  _idade = (_AnoAtual! - _validNasc!);
  return _idade;
}



