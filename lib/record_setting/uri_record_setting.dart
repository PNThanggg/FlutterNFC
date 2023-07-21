import 'package:flutter/material.dart';

import '../nfc/ndef/ndef.dart' as ndef;

class UriRecordSetting extends StatefulWidget {
  final ndef.UriRecord record;

  UriRecordSetting({Key? key, ndef.UriRecord? record})
      : record = record ?? ndef.UriRecord(prefix: '', content: ''),
        super(key: key);

  @override
  _UriRecordSetting createState() => _UriRecordSetting();
}

class _UriRecordSetting extends State<UriRecordSetting> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  String? _dropButtonValue;

  @override
  initState() {
    super.initState();

    _contentController =
        TextEditingController.fromValue(TextEditingValue(text: widget.record.content!));
    _dropButtonValue = widget.record.prefix;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Set Record'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DropdownButton(
                    value: _dropButtonValue,
                    items: ndef.UriRecord.prefixMap.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _dropButtonValue = value;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'content'),
                    controller: _contentController,
                  ),
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      if ((_formKey.currentState as FormState).validate()) {
                        Navigator.pop(
                          context,
                          ndef.UriRecord(
                            prefix: _dropButtonValue,
                            content: (_contentController.text),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
