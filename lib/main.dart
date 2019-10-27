import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';

import 'package:crud_redux/model/model.dart';
import 'package:crud_redux/redux/actions.dart';
import 'package:crud_redux/redux/reducers.dart';
import 'package:crud_redux/redux/middleware.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final DevToolsStore<AppState> store = DevToolsStore<AppState>(
        appStateReducer,
        initialState: AppState.initialState(),
        middleware: appStateMiddleware());
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
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
          primarySwatch: Colors.blue,
        ),
        home: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(GetItemsAction()),
          builder: (BuildContext context, Store<AppState> store) =>
              MyHomePage(store: store, title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final DevToolsStore<AppState> store;
  final String title;

  MyHomePage({Key key, this.title, this.store}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(this.title),
      ),
      body: StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        builder: (BuildContext context, _ViewModel viewModel) => Column(
          children: <Widget>[
            AddItemWidget(viewModel),
            Expanded(child: ItemListWidget(viewModel)),
            RemoveItemsButton(viewModel)
          ],
        ),
      ),
      drawer: Container(
        child: ReduxDevTools(store),
      ),
    );
  }
}

class AddItemWidget extends StatefulWidget {
  final _ViewModel model;

  AddItemWidget(this.model);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItemWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: 'Add An Item'),
      onSubmitted: (String s) {
        widget.model.onAddItem(s);
        controller.text = '';
      },
    );
  }
}

class ItemListWidget extends StatelessWidget {
  final _ViewModel model;

  ItemListWidget(this.model);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: model.items
          .map((Item item) => ListTile(
                title: Text(item.body),
                leading: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => model.onRemoveItem(item),
                ),
                trailing: Checkbox(
                  value: item.completed,
                  onChanged: (b) {
                    model.onCompleted(item);
                  },
                ),
              ))
          .toList(),
    );
  }
}

class RemoveItemsButton extends StatelessWidget {
  final _ViewModel model;

  RemoveItemsButton(this.model);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Delete All Items'),
      onPressed: () => model.onRemoveItems(),
    );
  }
}

class _ViewModel {
  final List<Item> items;
  final Function(Item) onCompleted;
  final Function(String) onAddItem;
  final Function(Item) onRemoveItem;
  final Function() onRemoveItems;

  _ViewModel(
      {this.items,
      this.onCompleted,
      this.onAddItem,
      this.onRemoveItem,
      this.onRemoveItems});

  factory _ViewModel.create(Store<AppState> store) {
    _onAddItem(String body) {
      store.dispatch(AddItemAction(body));
    }

    _onRemoveItem(Item item) {
      store.dispatch(RemoveItemAction(item));
    }

    _onRemoveItems() {
      store.dispatch(RemoveItemsAction());
    }

    _onCompleted(Item item) {
      store.dispatch(ItemCompletedAction(item));
    }

    return _ViewModel(
      items: store.state.items,
      onCompleted: _onCompleted,
      onAddItem: _onAddItem,
      onRemoveItem: _onRemoveItem,
      onRemoveItems: _onRemoveItems,
    );
  }
}
