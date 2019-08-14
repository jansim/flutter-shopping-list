import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: TodoList(title: 'Simple Shopping List'),
    );
  }
}

class TodoList extends StatefulWidget {
  TodoList({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> _items = [];
  List<String> _completedItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData () async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _items = prefs.getStringList("items") ?? [];
      _completedItems = prefs.getStringList("completedItems") ?? [];
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("items", _items);
    prefs.setStringList("completedItems", _completedItems);
  }

  TextEditingController inputController = new TextEditingController();
  void _addItem() {
    setState(() {
      String item = inputController.text;
      if (item.length > 0) {
        _items.add(inputController.text);

        // Reset input
        inputController.text = "";
      }
    });
    _saveData();
  }

  void _completeItem(int index) {
    setState(() {
      _completedItems.insert(0, _items.removeAt(index));
    });
    _saveData();
  }
  void _uncompleteItem(int index) {
    setState(() {
      _items.add(_completedItems.removeAt(index));
    });
    _saveData();
  }

  void _clearCompleted() {
    setState(() {
      _completedItems.clear();
    });
    _saveData();
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return new ListView.builder(
      itemCount: _items.length + _completedItems.length,
      itemBuilder: (context, index) {
        if (index < _items.length) {
          return _buildListItem(index, _items[index]);
        } else {
          int completedIndex = index - _items.length;
          return _buildCompletedListItem(completedIndex, _completedItems[completedIndex]);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildListItem(int itemIndex, String todoText) {
    return new ListTile(
        title: new Text(todoText), onTap: () => _completeItem(itemIndex));
  }
  // Build a single completed todo item
  Widget _buildCompletedListItem(int itemIndex, String todoText) {
    return new ListTile(
        title: new Text(todoText, style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),),
        onTap: () => _uncompleteItem(itemIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the TodoList object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearCompleted,
            )
          ]
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: _buildTodoList(),
              padding: EdgeInsets.only(bottom: 60),
            ),
            Positioned(
                bottom: 0.0,
                width: MediaQuery.of(context).size.width, // width 100%
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0x80000000),
                            offset: Offset(0.0, 6.0),
                            blurRadius: 20.0,
                          )
                        ]),
                    child: TextField(
                      controller: inputController,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (String s) => _addItem(),
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: "New Item..",
                          contentPadding: EdgeInsets.all(20)),
                    ))),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
