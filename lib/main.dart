import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import './widgets/node_form_dialog.dart';

import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take Nodes',
      home: MyHomePage(
        title: 'Take Nodes',
        storage: NodesStorage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NodesStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/default.txt');
  }

  Future<String> readNodes() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeNodes(String nodesList) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$nodesList');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.storage})
      : super(key: key);

  final NodesStorage storage;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nodeNameController = TextEditingController();
  String? _selectedNodeKey;

  //List<Node> _nodes = [];
  TreeViewController _treeViewController = new TreeViewController();
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
    super.initState();
    //_treeViewController = TreeViewController();
    //String serializedNodes = _treeViewController.toString();
    //_treeViewController.loadJSON(json: serializedNodes);
    widget.storage.readNodes().then((String nodes) {
      if (nodes.isNotEmpty) {
        setState(() {
          _treeViewController = _treeViewController.loadJSON(json: nodes);
          //_nodes = _treeViewController.children;
        });
      }
    });
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
        onLongPress: () {
          print("long pressed something");
        },
        child: Container(
          height: double.infinity,
          color: Colors.grey,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        //borderRadius: BorderRadius.circular(10),
                        ),
                    child: Container(
                      child: TreeView(
                        shrinkWrap: true,
                        controller: _treeViewController,
                        allowParentSelect: _allowParentSelect,
                        supportParentDoubleTap: _supportParentDoubleTap,
                        nodeBuilder: (context, node) {
                          return GestureDetector(
                            child: Card(
                                //color: Colors.grey.shade100.withAlpha(200),
                                child: Container(
                              padding: EdgeInsets.all(15),
                              child: Text(node.label),
                            )),
                            onLongPressStart: (LongPressStartDetails details) {
                              _onLongPressStartHandler(node, details);
                            },
                          );
                        },
                        onExpansionChanged: (key, expanded) =>
                            _expandNode(key, expanded),
                        onNodeTap: (key) {
                          print('node was tapped');
                          setState(() {
                            //_expanderColor = Colors.white;
                            _selectedNodeKey = key;
                            _treeViewController =
                                _treeViewController.copyWith(selectedKey: key);
                          });
                        },
                        onNodeDoubleTap: (key) {
                          print("double tapped " + key);
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
      floatingActionButton:
          _selectedNodeKey == null ? _singleFab() : _expandableFab(),
    );
  }

  _onLongPressStartHandler(node, details) {
    Offset _tapPosition = details.globalPosition;
    print("longpressed " + node.label);
    setState(() {
      //_expanderColor = Colors.white;
      _selectedNodeKey = node.key;
      _treeViewController = _treeViewController.copyWith(selectedKey: node.key);
    });
    showMenu(
      //shape: CircleBorder(),
      position:
          RelativeRect.fromLTRB(_tapPosition.dx, _tapPosition.dy, 0.0, 0.0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          padding: EdgeInsets.all(0),
          value: node.key,
          child: TextButton.icon(
              label: const Text('Edit Node'),
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                _showNodeFormDialog(true);
              }),
        ),
        PopupMenuItem(
          padding: EdgeInsets.all(0),
          value: node.key,
          child: TextButton.icon(
              icon: const Icon(Icons.account_tree),
              label: const Text('Add Child Node'),
              onPressed: () {
                Navigator.pop(context);
                _showNodeFormDialog(false);
              }),
        ),
        PopupMenuItem(
          padding: EdgeInsets.all(0),
          value: node.key,
          child: TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete Node'),
              onPressed: () {
                Navigator.pop(context);
                _showDeleteNodeDialog();
              }),
        ),
      ],
      context: context,
    );
  }

  _singleFab() {
    return FloatingActionButton(
        tooltip: 'Add Note',
        onPressed: () => _showNodeFormDialog(false),
        child: const Icon(Icons.add));
  }

  _expandableFab() {
    return ExpandableFab(
      distance: 112.0,
      children: [
        ActionButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Node',
            onPressed: () => _showNodeFormDialog(true)),
        ActionButton(
            icon: const Icon(Icons.account_tree),
            tooltip: 'Add Child Node',
            onPressed: () => _showNodeFormDialog(false)),
        ActionButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Node',
            onPressed: () => _showDeleteNodeDialog()),
      ],
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
          _treeViewController = _treeViewController.copyWith(
              children: _treeViewController.children + [newNode]);
          //_treeViewController.children.add(newNode);
          widget.storage.writeNodes(_treeViewController.toString());
        });
      } else {
        if (isEdit == true) {
          setState(() {
            _treeViewController = _treeViewController.copyWith(
                children:
                    _treeViewController.updateNode(selectedNode!.key, newNode));
            widget.storage.writeNodes(_treeViewController.toString());
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
            widget.storage.writeNodes(_treeViewController.toString());
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
    const TextStyle alertStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.red);
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Delete node $nodeLabel?'),
              content: const Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'Are you sure? '),
                    TextSpan(
                        text: 'ALL its children will be deleted',
                        style: alertStyle),
                    TextSpan(text: '. This is '),
                    TextSpan(text: 'irreversible', style: alertStyle),
                    TextSpan(text: '. \n\n'),
                    TextSpan(text: 'LONG PRESS', style: alertStyle),
                    TextSpan(text: ' "Delete Anyway" to confirm.'),
                  ],
                ),
              ),
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
                      widget.storage.writeNodes(_treeViewController.toString());
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

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
    this.selectedNode,
  }) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final selectedNode;

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  _ExpandingActionButton({
    Key? key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  }) : super(key: key);

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    this.tooltip,
    required this.icon,
  }) : super(key: key);

  final String? tooltip;
  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.accentColor,
      elevation: 4.0,
      child: IconTheme.merge(
        data: theme.accentIconTheme,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: icon,
        ),
      ),
    );
  }
}
