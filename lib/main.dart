import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:todo_desafio_dio/controller/task_controller.dart';
import 'dart:async';
import 'dart:convert';

import 'package:todo_desafio_dio/repository/task_repository.dart';

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
  List<Map<String, dynamic>> _toDoList = <Map<String, dynamic>>[];
  final _toDoController = TextEditingController();
  Map<String, dynamic>? _lastRemoved;
  int? _lastRemovedPos;
  double status = 0.0;
  TaskRepository taskRepository = TaskRepository();
  TaskController taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();

    taskController.getTasks();

    // taskRepository.readData().then((data) {
    //   setState(() {
    //     _toDoList = json.decode(data!);
    //     _atualizaStatus();
    //   });
    // });
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
      taskRepository.saveData(_toDoList);
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
        taskRepository.saveData(_toDoList);
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
              Obx(()=> Text("Lista de tarefas   -  ${taskController.status.value.toStringAsFixed(1)} %")),
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
                    onPressed: ()=> taskController.addToDo(_toDoController.text),
                    child: const Text("ADD"),
                  )
                ],
              )),
          Expanded(
              child: RefreshIndicator(
            onRefresh: ()=>taskController.refreshList(), //_refresh,
            child: Obx(()=>ListView.builder(
                padding: const EdgeInsets.only(top: 10.0),
                itemCount: taskController.toDoList.length,
                itemBuilder: buildItem),
          )))
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
      child: GetBuilder<TaskController>(builder:(_)=> CheckboxListTile(
          onChanged: (c) {
            taskController.toDoList[index]['ok'] = c;
            taskController.atualizaStatus();
            taskController.saveTasks();
            // setState(() {
            //   _toDoList[index]["ok"] = c;
            //   _atualizaStatus();
            //   taskRepository.saveData(_toDoList);
            // });
          },
          title: Text(taskController.toDoList[index]["title"]),
          value: taskController.toDoList[index]["ok"],
          secondary: CircleAvatar(
              backgroundColor:
                  taskController.toDoList[index]["ok"] ? Colors.green : Colors.blueAccent,
                  child: Icon(taskController.toDoList[index]["ok"] ? Icons.check : Icons.error),),),),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _atualizaStatus();
          taskRepository.saveData(_toDoList);

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved!["title"]} \" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos!, _lastRemoved!);
                    taskRepository.saveData(_toDoList);
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

}
