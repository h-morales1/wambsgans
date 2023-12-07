import 'package:flutter/material.dart';
import 'package:wambsgans/sql_helper.dart';
import 'package:wambsgans/local_auth_service.dart';
import 'package:wambsgans/view_entry.dart';
import 'package:wambsgans/entry.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wambsgans',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Wambsgans'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool authenticated = false;
  List<Map<String, dynamic>> _entries = [];

  bool _isLoading = true;

  void _refreshEntries() async {
    final data = await SQLHelper.getEntries();
    setState(() {
      _entries = data;
      _isLoading = false;
    });
  }

  void _unlock() async {
    final authenticate = await LocalAuth.authenticate();
    if(!authenticate) {
      exit(0);
    }

    _refreshEntries();

    setState(() {
      authenticated = authenticate;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _unlock();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _addEntry() async {
    await SQLHelper.createEntry(_titleController.text, _contentController.text);
    _refreshEntries();
  }

  Future<void> _updateEntry(int id) async {
    await SQLHelper.updateEntry(id, _titleController.text, _contentController.text);
    _refreshEntries();
  }

  void _deleteEntry(int id) async {
    await SQLHelper.deleteEntry(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully delete an entry.'),
    ));
    _refreshEntries();
  }

  void _showForm(int? id) async {
    if(id != null) {

      final existingEntry = _entries.firstWhere((element) => element['id'] == id);
      _titleController.text = existingEntry['title'];
      _contentController.text = existingEntry['content'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // this will prevent soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: 'Content'),
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addEntry();
                  }
                  if(id != null) {
                    await _updateEntry(id);
                  }
                  // clear  the text fields
                  _titleController.text = '';
                  _contentController.text = '';
                  // close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      )
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) => Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(_entries[index]['title']),
            // add on tap
            onTap: () {
              // init entry
              Entry toview = Entry();
              toview.title = _entries[index]['title'];
              toview.content = _entries[index]['content'];
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewEntry(entry: toview)),
              );
            },
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(_entries[index]['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteEntry(_entries[index]['id']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
