import 'package:flutter/material.dart';
import 'package:openroadmap/export/exporter.dart';
import 'package:openroadmap/export/plantuml_exporter.dart';
import 'package:openroadmap/export/plantuml_generator.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/util/setting_provider.dart';
import 'package:provider/provider.dart';

class ExportForm extends StatefulWidget {
  ExportForm();

  _ExportForm createState() => _ExportForm();
}

class _ExportForm extends State<ExportForm> {
  Map<String, Exporter> exporters = {'PlantUMLExporter': PlantUMLExporter()};
  late String dropdownValue;

  @override
  void initState() {
    dropdownValue = exporters.keys.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButton<String>(
            items: exporters.keys
                .toList()
                .map<DropdownMenuItem<String>>((String s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s),
              );
            }).toList(),
            value: dropdownValue,
            onChanged: (newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            }),
        Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Consumer<ORProvider>(
            builder: (context, orProvider, child) {
              return ElevatedButton(
                child: Text('Export'),
                onPressed: () {
                  exporters['$dropdownValue']!.export(orProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported using $dropdownValue')));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        Column(
          children: [
            Text('Preview:'),
            Consumer<SettingProvider>(
                builder: (context, settingProvider, child) {
              return Consumer<ORProvider>(
                  builder: (context, orProvider, child) {
                if (settingProvider.isPlantUmlJarPathConfigured) {
                  return FutureBuilder<Image>(
                    future: PlantUmlGenerator.generateImageFromPlantUml(
                        PlantUmlGenerator.generatePlantUmlCode(orProvider),
                        settingProvider),
                    builder:
                        (BuildContext context, AsyncSnapshot<Image> snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
                } else {
                  return Column(
                    children: [
                      Icon(Icons.warning)
                      ,Text(
                    'Please configure the PlantUML Jar Path in\nthe Settings to enable the preview.'),
                    ],
                  );
                }
              });
            }),
          ],
        ),
      ],
    );
  }
}
