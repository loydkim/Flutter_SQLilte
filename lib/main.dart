import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class TestData {
  TestData({
    this.name,
    this.age,
    this.id
  });

  final String name;
  final int age;
  final int id;
}

class _MyHomePageState extends State<MyHomePage> {

// reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;
  final TextEditingController _textController = new TextEditingController();

  List<TestData> testData = List<TestData>();

  @override
  void initState() {
    _query();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 20.0),
                children:
                  testData.map<Widget>( (data){
                    return textSection(data.name,data.age,data.id);
                  }).toList(),
              ),
            ),
            _buildTextComposer()
          ],
        ),
      ),
    );
  }

  Widget textSection(String title, int age, int id) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        _delete(id);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(title),
            trailing: Container(child: Text(age.toString())),
          onTap: () {
            _update(id,title,age);
              print('');
          }),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(                                            //new
      data: new IconThemeData(color: Theme.of(context).accentColor), //new
      child: new Container(                                     //modified
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText: "Type anything to insert data"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),                                                             //new
    );
  }

  Future<void> _handleSubmitted(String text) async {
    try {
      _insert(text, 20);
      _textController.text = '';
      FocusScope.of(context).requestFocus(FocusNode());
    }catch(e){
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          }
      );
    }
  }

  void _insert(String name, int age) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnAge  : age
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    _query();
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    testData.clear();
    allRows.forEach((row) {
      setState(() {
        var data = TestData(name: row[DatabaseHelper.columnName],
            age: row[DatabaseHelper.columnAge],
            id:row[DatabaseHelper.columnId]);
        testData.add(data);
      });
    });
  }

  void _update(int id,String name ,int age) async {
    // row to update
    int newAge = age+1;
    Map<String, dynamic> row = {
      DatabaseHelper.columnId   : id,
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnAge  : newAge
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');


    _query();
  }

  void _delete(int id) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }
}
