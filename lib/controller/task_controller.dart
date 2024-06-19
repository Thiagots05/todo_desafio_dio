
import 'dart:convert';

import 'package:get/state_manager.dart';
import 'package:todo_desafio_dio/repository/task_repository.dart';

class TaskController extends GetxController{

  RxList<Map<String, dynamic>> toDoList = <Map<String, dynamic>>[].obs;
  var status = 0.0.obs;
  var lastRemovedPos = 0.obs;
  RxMap<String, dynamic>? lastRemoved = <String, dynamic>{}.obs;
  TaskRepository taskRepository = TaskRepository();


  saveTasks(){
    taskRepository.saveData(toDoList);
  }

  void atualizaStatus() {
    double contador = 0;
    for (var i = 0; i < toDoList.length; i++) {
      if (toDoList[i]["ok"]) {
        contador++;
      }
    }
    if (toDoList.isNotEmpty) {
      status.value = (contador / toDoList.length) * 100;
    } else {
      status.value = 0.0;
    }
  }

    void addToDo(String title) {
    
      Map<String, dynamic> newToDo = <String, dynamic>{};
      newToDo["title"] = title;
      newToDo["ok"] = false;
      toDoList.add(newToDo);
      saveTasks();
      atualizaStatus();
    
  }

    Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));

    
      toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]){
          return -1;
        }else{
        taskRepository.saveData(toDoList);
          return 0;
        } 
      }); 
  }

  void removeTask(int index){
          lastRemoved = RxMap.from(toDoList[index]);
          lastRemovedPos.value = index;
          toDoList.removeAt(index);
          atualizaStatus();
          taskRepository.saveData(toDoList);
  }

   

  Future<void> getTasks()async{
    var tasks = await taskRepository.readData();
    if(tasks!=null){
    List<dynamic> decodedJson = json.decode(tasks);
    toDoList.value = decodedJson.map((item) => Map<String, dynamic>.from(item)).toList();
    print(toDoList);
    atualizaStatus();
    }
    
  }



}