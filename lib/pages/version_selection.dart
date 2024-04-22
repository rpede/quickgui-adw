import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';

import '../model/operating_system.dart';
import '../model/option.dart';
import '../widgets/adw_back_button.dart';
import 'option_selection.dart';

class VersionSelection extends StatefulWidget {
  const VersionSelection({super.key, required this.operatingSystem});

  final OperatingSystem operatingSystem;

  @override
  _VersionSelectionState createState() => _VersionSelectionState();
}

class _VersionSelectionState extends State<VersionSelection> {
  var term = "";

  @override
  Widget build(BuildContext context) {
    var list = widget.operatingSystem.versions
        .where((version) =>
            version.version.toLowerCase().contains(term.toLowerCase()))
        .toList();

    return AdwScaffold(
      actions: AdwActions().windowManager,
      title: Text(context
          .t('Select version for {0}', args: [widget.operatingSystem.name])),
      start: [AdwBackButton()],
      end: [
        AdwSearchBar(
          hintText: context.t('Search version'),
          onChanged: (value) {
            setState(() {
              term = value;
            });
          },
        ),
      ],
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          var item = list[index];
          return Card(
            child: ListTile(
              title: Text(item.version),
              onTap: () {
                if (item.options.length > 1) {
                  Navigator.of(context)
                      .push<Option>(MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => OptionSelection(list[index])))
                      .then((selection) {
                    if (selection != null) {
                      Navigator.of(context).pop((item, selection));
                    }
                  });
                } else {
                  Navigator.of(context).pop((item, list[index].options[0]));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
