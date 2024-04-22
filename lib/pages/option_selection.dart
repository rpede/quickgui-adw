import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';

import '../model/version.dart';

class OptionSelection extends StatefulWidget {
  const OptionSelection(this.version, {super.key});

  final Version version;

  @override
  State<OptionSelection> createState() => _OptionSelectionState();
}

class _OptionSelectionState extends State<OptionSelection> {
  var term = "";
  final focusNode = FocusNode();

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var list = widget.version.options
        .where((e) => e.option.toLowerCase().contains(term.toLowerCase()))
        .toList();

    return AdwScaffold(
      actions: AdwActions().windowManager,
      title: Text(context.t('Select option')),
      start: [BackButton()],
      end: [
        AdwSearchBar(
          hintText: context.t('Search option'),
          onChanged: (value) {
            setState(() {
              term = value;
            });
          },
        ),
      ],
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          var item = list[index];
          return Card(
            child: ListTile(
              title: Text(item.option),
              onTap: () {
                Navigator.of(context).pop(item);
              },
            ),
          );
        },
      ),
    );
  }
}
