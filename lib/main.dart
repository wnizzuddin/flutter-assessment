import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'flutter_application_1',
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  int orderNumber = 0;
  int totalorders = 0;
  var bot = [];
  var pending = [];
  var processing = [];
  var complete = [];
  var cancel = [];

  void handleOrder(String type) {
    if (type == "RESET") {
      orderNumber = 0;
      pending = [];
      processing = [];
      complete = [];
    } else {
      orderNumber++;
      var display = "$type ${orderNumber.toString().padLeft(3, '0')}";

      handleOrderType(type, display);
    }

    totalorders = pending.length + complete.length;
    if (bot.isNotEmpty) {
      assignOrder();
    }
    notifyListeners();
  }

  handleOrderType(var type, var display) {
    if (type == "VIP") {
      bool vipOnly = true;
      for (var i = 0; i < pending.length; i++) {
        if (pending[i].contains("NOR")) {
          vipOnly = false;
          pending.insert(i, display);
          break;
        }
      }

      if (vipOnly) {
        pending.add(display);
      }
    } else {
      pending.add(display);
    }
  }

  void handleBot(String action) {
    if (action == "add") {
      bot.add({'id': bot.length + 1, 'status': 'idle', 'order': ''});

      if (pending.isNotEmpty) {
        assignOrder();
      }
    } else {
      if (bot.isNotEmpty) {
        removeProcessingBot();
        bot.removeAt(bot.length - 1);
      } else {
        print('Reach minimum bot');
      }
    }
    print(bot);
    notifyListeners();
  }

  void assignOrder() {
    var idleBot = checkIdleBot();
    var availableOrder = checkAvailableOrder();

    for (var i = 0; i < bot.length; i++) {
      if (bot[i]['id'] == idleBot['id']) {
        bot[i]['status'] = 'processing';
        bot[i]['order'] = availableOrder;
        processing.add(availableOrder);
        pending.remove(availableOrder);
      }
    }
    completeOrder(idleBot);
  }

  void completeOrder(var currentbot) {
    Future.delayed(Duration(seconds: 10), () {
      complete.add(currentbot['order']);
      processing.remove(currentbot['order']);
      currentbot['status'] = 'idle';
      currentbot['order'] = '';
      if (pending.isNotEmpty) {
        assignOrder();
      }
      if (cancel.isNotEmpty) {
        for (var i = 0; i < cancel.length; i++) {
          complete.remove(cancel[i]);
        }
      }
      notifyListeners();
    });
  }

  checkIdleBot() {
    var temp = {};
    for (var i = 0; i < bot.length; i++) {
      if (bot[i]['status'] == 'idle') {
        temp = bot[i];
      }
    }
    return temp;
  }

  checkAvailableOrder() {
    for (var i = 0; i < bot.length; i++) {
      var order = bot[i]['order'];
      for (var j = 0; j < pending.length; j++) {
        if (pending[j] != order) {
          return pending[j];
        }
      }
    }
  }

  removeProcessingBot() {
    var newestBotOrder = bot[bot.length - 1]['order'];
    if (newestBotOrder != '') {
      processing.remove(newestBotOrder);

      var type = "";
      if (newestBotOrder.contains("VIP")) {
        type = "VIP";
      } else {
        type = "NOR";
      }
      handleOrderType(type, newestBotOrder);

      cancel.add(newestBotOrder);
    }
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(218, 41, 28, 1),
          centerTitle: true,
          title: const Text(
            "McDonald's Order Queue",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          )),
      body: BodyComponent(),
    );
  }
}

class BodyComponent extends StatelessWidget {
  // const BodyComponent({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 50,
          child: Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(10),
                  child: Text('Pending'),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(10),
                  child: Text('Processing'),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(10),
                  child: Text('Complete'),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: appState.pending.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.all(4),
                        itemCount: appState.pending.length,
                        itemBuilder: (BuildContext context, int index) {
                          var order = appState.pending[index];
                          bool isVip = order.contains("VIP");
                          return Container(
                            height: 50,
                            color: isVip ? Colors.yellow[700] : Colors.yellow,
                            child: Center(
                              child: Text('Order $order'),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          thickness: 1.0,
                          color: Colors.red,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        alignment: Alignment(0, 0),
                        color: Colors.amber[50],
                        child: Text("No Order"),
                      ),
              ),
              Expanded(
                child: appState.processing.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.all(4),
                        itemCount: appState.processing.length,
                        itemBuilder: (BuildContext context, int index) {
                          var order = appState.processing[index];
                          bool isVip = order.contains("VIP");
                          return Container(
                            height: 50,
                            color: isVip ? Colors.yellow[700] : Colors.yellow,
                            child: Center(
                              child: Text('Order $order'),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          thickness: 1.0,
                          color: Colors.red,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        alignment: Alignment(0, 0),
                        color: Colors.amber[50],
                        child: Text("No Order"),
                      ),
              ),
              Expanded(
                child: appState.complete.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.all(4),
                        itemCount: appState.complete.length,
                        itemBuilder: (BuildContext context, int index) {
                          var order = appState.complete[index];
                          return Container(
                              height: 50,
                              color: Colors.blue[200],
                              child: Center(child: Text('Order $order')));
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          thickness: 1.0,
                          color: Colors.red,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        alignment: Alignment(0, 0),
                        color: Colors.amber[50],
                        child: Text("No Order"),
                      ),
              )
            ],
          ),
        ),
        Container(
          color: Colors.blueGrey,
          height: 70,
          child: Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Total Orders: ${appState.totalorders}',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.handleOrder("VIP");
                  },
                  child: Text('+ VIP'),
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.handleOrder("NOR");
                  },
                  child: Text('+ Normal'),
                ),
                FloatingActionButton(
                  onPressed: () {
                    appState.handleOrder("RESET");
                  },
                  child: Text("RESET"),
                )
              ],
            ),
          ),
        ),
        Container(
          color: Colors.black,
          height: 70,
          child: Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No of bots: ${appState.bot.length}',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          appState.handleBot("add");
                        },
                        child: Text('+ Bot')),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          appState.handleBot("delete");
                        },
                        child: Text('- Bot'))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
