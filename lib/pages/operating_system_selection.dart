import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

import '../bloc/download_cubit.dart';
import '../bloc/download_state.dart';
import '../widgets/downloader/operating_system_icon.dart';

class OperatingSystemSelection extends StatefulWidget {
  const OperatingSystemSelection({super.key});

  @override
  State<OperatingSystemSelection> createState() =>
      _OperatingSystemSelectionState();
}

class _OperatingSystemSelectionState extends State<OperatingSystemSelection> {
  var term = "";
  final focusNode = FocusNode();

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Select operating system')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.search),
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          decoration: InputDecoration.collapsed(
                              hintText: context.t('Search operating system')),
                          onChanged: (value) {
                            setState(() {
                              term = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
