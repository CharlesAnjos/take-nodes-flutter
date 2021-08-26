import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import './widgets/node_form_dialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take Nodes',
      home: MyHomePage(title: 'Take Nodes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nodeNameController = TextEditingController();

  String? _selectedNodeKey;
  List<Node> _nodes = [];
  late TreeViewController _treeViewController;
  final Map<ExpanderPosition, Widget> expansionPositionOptions = const {
    ExpanderPosition.start: Text('Start'),
    ExpanderPosition.end: Text('End'),
  };
  final Map<ExpanderType, Widget> expansionTypeOptions = const {
    ExpanderType.caret: Icon(
      Icons.arrow_drop_down,
      size: 28,
    ),
    ExpanderType.arrow: Icon(Icons.arrow_downward),
    ExpanderType.chevron: Icon(Icons.expand_more),
    ExpanderType.plusMinus: Icon(Icons.add),
  };

  final Map<ExpanderModifier, Widget> expansionModifierOptions = const {
    ExpanderModifier.none: ModContainer(ExpanderModifier.none),
    ExpanderModifier.circleFilled: ModContainer(ExpanderModifier.circleFilled),
    ExpanderModifier.circleOutlined:
        ModContainer(ExpanderModifier.circleOutlined),
    ExpanderModifier.squareFilled: ModContainer(ExpanderModifier.squareFilled),
    ExpanderModifier.squareOutlined:
        ModContainer(ExpanderModifier.squareOutlined),
  };

  ExpanderPosition _expanderPosition = ExpanderPosition.start;
  ExpanderType _expanderType = ExpanderType.plusMinus;
  ExpanderModifier _expanderModifier = ExpanderModifier.none;
  bool _allowParentSelect = true;
  bool _supportParentDoubleTap = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nodeNameController.dispose();
    super.dispose();
  }

  void initState() {
    _treeViewController = TreeViewController(
      children: _nodes,
      selectedKey: _selectedNodeKey,
    );
    super.initState();
  }

  ListTile _makeExpanderPosition() {
    return ListTile(
      title: Text('Expander Position'),
      dense: true,
      trailing: CupertinoSlidingSegmentedControl(
        children: expansionPositionOptions,
        groupValue: _expanderPosition,
        onValueChanged: (ExpanderPosition? newValue) {
          setState(() {
            _expanderPosition = newValue!;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  SwitchListTile _makeAllowParentSelect() {
    return SwitchListTile.adaptive(
      title: Text('Allow Parent Select'),
      dense: true,
      value: _allowParentSelect,
      onChanged: (v) {
        setState(() {
          _allowParentSelect = v;
        });
      },
    );
  }

  SwitchListTile _makeSupportParentDoubleTap() {
    return SwitchListTile.adaptive(
      title: Text('Support Parent Double Tap'),
      dense: true,
      value: _supportParentDoubleTap,
      onChanged: (v) {
        setState(() {
          _supportParentDoubleTap = v;
        });
      },
    );
  }

  ListTile _makeExpanderType() {
    return ListTile(
      title: Text('Expander Style'),
      dense: true,
      trailing: CupertinoSlidingSegmentedControl(
        children: expansionTypeOptions,
        groupValue: _expanderType,
        onValueChanged: (ExpanderType? newValue) {
          setState(() {
            _expanderType = newValue!;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  ListTile _makeExpanderModifier() {
    return ListTile(
      title: Text('Expander Modifier'),
      dense: true,
      trailing: CupertinoSlidingSegmentedControl(
        children: expansionModifierOptions,
        groupValue: _expanderModifier,
        onValueChanged: (ExpanderModifier? newValue) {
          setState(() {
            _expanderModifier = newValue!;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TreeViewTheme _treeViewTheme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
        type: _expanderType,
        modifier: _expanderModifier,
        position: _expanderPosition,
        // color: Colors.grey.shade800,
        size: 20,
        //color: _expanderColor
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
        //fontWeight: FontWeight.w800,
        //color: Colors.blue.shade700,
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: Theme.of(context).colorScheme,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.expand_more),
            tooltip: 'Expand all nodes',
            onPressed: () {
              setState(() {
                _treeViewController = _treeViewController.copyWith(
                    children: _treeViewController.expandAll());
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.expand_less),
            tooltip: 'Collapse all nodes',
            onPressed: () {
              setState(() {
                _treeViewController = _treeViewController.copyWith(
                    children: _treeViewController.collapseAll());
              });
            },
          ),
          IconButton(
              icon: const Icon(Icons.add_circle),
              tooltip: 'Add Note',
              onPressed: () => _showNodeFormDialog(false)),
          _selectedNodeKey != null
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Node',
                  onPressed: () => _showNodeFormDialog(true))
              : Container(),
          _selectedNodeKey != null
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Node',
                  onPressed: () => _showDeleteNodeDialog())
              : Container(),
        ],
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Options'),
            ),
            _makeExpanderPosition(),
            _makeExpanderType(),
            _makeExpanderModifier(),
            _makeAllowParentSelect(),
            _makeSupportParentDoubleTap(),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _selectedNodeKey = null;
            _treeViewController = _treeViewController.copyWith(selectedKey: "");
          });
        },
        onDoubleTap: () {
          print("double tapped empty");
          setState(() {
            _selectedNodeKey = null;
            _treeViewController = _treeViewController.copyWith(selectedKey: "");
          });
        },
        //onLongPress: () => _showNodeFormDialog(false),
        child: Container(
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //padding: EdgeInsets.all(10),
                    child: Container(
                      child: TreeView(
                        shrinkWrap: true,
                        controller: _treeViewController,
                        allowParentSelect: _allowParentSelect,
                        supportParentDoubleTap: _supportParentDoubleTap,
                        onExpansionChanged: (key, expanded) =>
                            _expandNode(key, expanded),
                        onNodeTap: (key) {
                          setState(() {
                            //_expanderColor = Colors.white;
                            _selectedNodeKey = key;
                            _treeViewController =
                                _treeViewController.copyWith(selectedKey: key);
                          });
                        },
                        onNodeDoubleTap: (key) {
                          debugPrint('the node was DPed (lol)');
                        },
                        theme: _treeViewTheme,
                      ),
                      key: ValueKey(_selectedNodeKey),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showNodeFormDialog(bool? isEdit) async {
    Node? selectedNode;
    if (isEdit == true) {
      selectedNode = _treeViewController.selectedNode;
    } else {
      selectedNode = null;
    }
    Node? newNode = await showDialog(
        context: context,
        builder: (context) => NodeFormDialog(
              selectedNode: selectedNode,
            ));
    if (newNode != null) {
      if (_selectedNodeKey == null) {
        setState(() {
          _treeViewController.children.add(newNode);
        });
      } else {
        if (isEdit == true) {
          setState(() {
            _treeViewController = _treeViewController.copyWith(
                children:
                    _treeViewController.updateNode(selectedNode!.key, newNode));
          });
        } else {
          Node? selectedNode = _treeViewController.selectedNode;
          List<Node> updated = _treeViewController.updateNode(
              selectedNode!.key,
              selectedNode.copyWith(
                children: selectedNode.children + [newNode],
              ));
          setState(() {
            _treeViewController =
                _treeViewController.copyWith(children: updated);
          });
          _expandNode(_treeViewController.selectedNode!.key, true);
        }
      }
    }
  }

  _expandNode(String key, bool expanded) {
    String msg = '${expanded ? "Expanded" : "Collapsed"}: $key';
    debugPrint(msg);
    Node? node = _treeViewController.getNode(key);
    if (node != null) {
      List<Node> updated;
      updated = _treeViewController.updateNode(
          key, node.copyWith(expanded: expanded));
      setState(() {
        _treeViewController = _treeViewController.copyWith(children: updated);
      });
    }
  }

  _showDeleteNodeDialog() async {
    Node? selectedNode = _treeViewController.selectedNode;
    String nodeLabel = selectedNode!.label;
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Delete node $nodeLabel?'),
              content: const Text(
                  'Are you sure? All its children will be deleted. This is irreversible. Long press "Delete Anyway" to confirm.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {},
                  onLongPress: () {
                    setState(() {
                      _treeViewController = _treeViewController.copyWith(
                          children:
                              _treeViewController.deleteNode(selectedNode.key));
                      _selectedNodeKey = null;
                      _treeViewController =
                          _treeViewController.copyWith(selectedKey: "");
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Delete Anyway'),
                ),
              ],
            ));
  }
}

class ModContainer extends StatelessWidget {
  final ExpanderModifier modifier;

  const ModContainer(this.modifier, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _borderWidth = 0;
    BoxShape _shapeBorder = BoxShape.rectangle;
    Color _backColor = Colors.transparent;
    Color _backAltColor = Colors.grey.shade700;
    switch (modifier) {
      case ExpanderModifier.none:
        break;
      case ExpanderModifier.circleFilled:
        _shapeBorder = BoxShape.circle;
        _backColor = _backAltColor;
        break;
      case ExpanderModifier.circleOutlined:
        _borderWidth = 1;
        _shapeBorder = BoxShape.circle;
        break;
      case ExpanderModifier.squareFilled:
        _backColor = _backAltColor;
        break;
      case ExpanderModifier.squareOutlined:
        _borderWidth = 1;
        break;
    }
    return Container(
      decoration: BoxDecoration(
        shape: _shapeBorder,
        border: _borderWidth == 0
            ? null
            : Border.all(
                width: _borderWidth,
                color: _backAltColor,
              ),
        color: _backColor,
      ),
      width: 15,
      height: 15,
    );
  }
}
