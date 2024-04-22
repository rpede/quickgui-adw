import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';

import '../bloc/download_cubit.dart';
import '../bloc/download_state.dart';
import '../widgets/adw_back_button.dart';
import '../widgets/downloader/operating_system_icon.dart';

class OperatingSystemSelection extends StatefulWidget {
  const OperatingSystemSelection({super.key});

  @override
  State<OperatingSystemSelection> createState() =>
      _OperatingSystemSelectionState();
}

class _OperatingSystemSelectionState extends State<OperatingSystemSelection> {
  var term = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions().windowManager,
      title: Text(context.t('Select operating system')),
      start: [AdwBackButton()],
      end: [
        AdwSearchBar(
          hintText: context.t('Search operating system'),
          onChanged: (value) {
            setState(() {
              term = value;
            });
          },
        ),
      ],
      body: BlocBuilder<DownloadCubit, DownloaderState>(
        builder: (context, state) {
          var list = state.choices
              .where((os) => os.name.toLowerCase().contains(term.toLowerCase()))
              .toList();
          if (list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 4),
            itemCount: list.length,
            itemBuilder: (context, index) {
              var item = list[index];
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  leading: OperatingSystemIcon(item: item),
                  onTap: () {
                    Navigator.of(context).pop(item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
