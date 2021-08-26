import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
//import 'package:example/widgets/icon_button_selector.dart';

class NodeFormDialog extends StatefulWidget {
  final Node? selectedNode;

  NodeFormDialog({Key? key, this.selectedNode}) : super(key: key);
  @override
  _NodeFormDialogState createState() => _NodeFormDialogState();
}

class _NodeFormDialogState extends State<NodeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final nodeNameController = TextEditingController();
  Node? selectedNode;
  Node? newNode;

  @override
  void initState() {
    selectedNode = widget.selectedNode;
    if (selectedNode != null) {
      nodeNameController.text = selectedNode!.label;
    }
    super.initState();
    //newNode =
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                autofocus: true,
                controller: nodeNameController,
                decoration: InputDecoration(
                  //icon: Icon(_selectedIcon),
                  hintText: 'Input the item name',
                  labelText: 'Name *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            nodeNameController.text = "";
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Node newNode;
              if (selectedNode == null) {
                newNode = Node.fromLabel(nodeNameController.text);
                nodeNameController.text = "";
                _formKey.currentState!.save();
              } else {
                newNode = Node(
                    key: selectedNode!.key,
                    label: nodeNameController.text,
                    children: selectedNode!.children,
                    data: selectedNode!.data,
                    expanded: selectedNode!.expanded,
                    icon: selectedNode!.icon,
                    iconColor: selectedNode!.iconColor,
                    parent: selectedNode!.parent,
                    selectedIconColor: selectedNode!.selectedIconColor);
              }
              Navigator.pop(context, newNode);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
