import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String taskTable = "contactTable";
final String idColumn = 'idColummn';
final String taskColumn = 'taskColumn';
final String checkColumn = 'checkColumn';

class TaskHelper {
  static final TaskHelper? _instance = TaskHelper.internal();

  factory TaskHelper() => _instance!;
  //declara o construtor interno
  TaskHelper.internal();
  //declara o banco de dados usando _db, o _ é para que não seja possível acessar a variável de fora da classe
  Database? _db;

  //inicializando o banco de dados
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  //iniciar o banco de dados
  Future<Database> initDb() async {
    //o getDatabasesPath não retorna a informação instantaneamente, leva um tempinho, portanto é necessário usar o await
    //pegar o local que vai estar armazenado o banco de dados
    //para usar o await é necessário colocar o async depois de nome_da_função() para indicar que é uma função assíncrona
    final databasesPath = await getDatabasesPath();
    //pegar o arquivo que vai tá arazenado no manco de dados
    final path = join(databasesPath, "todoList.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $taskTable($idColumn INTEGER PRIMARY KEY, $taskColumn TEXT, $checkColumn TEXT)");
    });
  }

  //salvar contato
  Future<Task> saveContact(Task contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(taskTable, contact.toMap());
    return contact;
  }

  //obter um contato
  Future<Task?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(taskTable,
        columns: [idColumn, taskColumn, checkColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Task.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //deletar contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(taskTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //Atualizar contato
  Future<int> updateContact(Task contact) async {
    Database dbContact = await db;
    return await dbContact.update(taskTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //Obter todos os contatos
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $taskTable");
    List<Task> listContact = <Task>[];
    for (Map m in listMap) {
      listContact.add(Task.fromMap(m));
    }
    return listContact;
  }

  //obter quantidade
  //não será usado nesse projeto mas pode ser útil em outros
  getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(x) FROM $taskTable"));
  }

  //Fechar banco de dados
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Task {
  int? id;
  String? task;
  bool? check;

  Task.fromMap(Map map) {
    id = map[idColumn];
    task = map[taskColumn];
    check = map[checkColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      taskColumn: task,
      checkColumn: check,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Task(id: $id, name: $task, email: $check)";
  }
}
