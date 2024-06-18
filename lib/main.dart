import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home:  Home(),
  ));
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  final _toDoController = TextEditingController();
  Map<String, dynamic>? _lastRemoved;
  int? _lastRemovedPos;
  double status = 0.0;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data!);
        _atualizaStatus();
      });
    });
  }

  void _atualizaStatus() {
    double contador = 0;
    for (var i = 0; i < _toDoList.length; i++) {
      if (_toDoList[i]["ok"]) {
        contador++;
      }
    }
    if (_toDoList.isNotEmpty) {
      status = (contador / _toDoList.length) * 100;
    } else {
      status = 0.0;
    }
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = <String, dynamic>{};
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
      _atualizaStatus();
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]){
          return -1;
        }else{
        _saveData();
          return 0;
        } 
      });

      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text("Lista de tarefas   -  ${status.toStringAsFixed(1)} %"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(17, 1, 7, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _toDoController,
                      decoration: const InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blueAccent[400], ), foregroundColor: const WidgetStatePropertyAll(Colors.white)),
                    onPressed: _addToDo,
                    child: const Text("ADD"),
                  )
                ],
              )),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),
          ))
        ]));
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
          onChanged: (c) {
            setState(() {
              _toDoList[index]["ok"] = c;
              _atualizaStatus();
              _saveData();
            });
          },
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
              backgroundColor:
                  _toDoList[index]["ok"] ? Colors.green : Colors.blueAccent,
                  child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),),),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _atualizaStatus();
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved!["title"]} \" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos!, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
         
         
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    debugPrint(directory.path);
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
