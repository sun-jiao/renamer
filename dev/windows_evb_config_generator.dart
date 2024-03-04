import 'dart:io';

import 'package:xml/xml.dart';

void main() {
  XmlBuilder builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="windows-1252"');
  // evb needs absolute dir, in fact the relative dir works in wine, but not work on
  // Windows runner of Github Actions. I cannot test it on a physical Windows machine.
  final windowsBuildDir = Directory(r"build/linux/x64/release/bundle").absolute; // use this for test: "build/linux/x64/release/bundle"
  final entities = windowsBuildDir.listSync();
  final input = entities.firstWhere((e) => e is File && e.path.endsWith('renamer'));
  final output = File(input.name).absolute;
  entities.removeWhere((e) => e is File && e.path.endsWith('renamer'));

  builder.element('', nest: () {
    builder.element('InputFile', nest: input.path);
    builder.element('OutputFile', nest: output.path);
    builder.element('Files', nest: () {
      builder.element('Enabled', nest: 'True');
      builder.element('DeleteExtractedOnExit', nest: 'False');
      builder.element('CompressFiles', nest: 'False');
      buildDir(builder, '%DEFAULT FOLDER%', entities);
    });
    builder.element('Registries', nest: () {
      builder.element('Enabled', nest: 'False');
      builder.element('Registries', nest: () {
        buildRegistry(builder, 'Classes');
        buildRegistry(builder, 'User');
        buildRegistry(builder, 'Machine');
        buildRegistry(builder, 'Users');
        buildRegistry(builder, 'Config');
      });
    });
    builder.element('Packaging', nest: () {
      builder.element('Enabled', nest: 'False');
    });
    builder.element('Options', nest: () {
      builder.element('ShareVirtualSystem', nest: 'False');
      builder.element('MapExecutableWithTemporaryFile', nest: 'True');
      builder.element('TemporaryFileMask');
      builder.element('AllowRunningOfVirtualExeFiles', nest: 'True');
      builder.element('ProcessesOfAnyPlatforms', nest: 'False');
    });
    builder.element('Storage', nest: () {
      builder.element('Storage', nest: () {
        builder.element('Enabled', nest: 'False');
        builder.element('Folder', nest: '%DEFAULT FOLDER%\\');
        builder.element('RandomFileNames', nest: 'False');
        builder.element('EncryptContent', nest: 'False');
        builder.element('ProcessesOfAnyPlatforms', nest: 'False');
      });
    });
  });

  final document = builder.buildDocument();
  File('renamer.evb').writeAsStringSync(document.toXmlString(pretty: true));
}

void buildFile(XmlBuilder builder, String name, String path) {
  builder.element('File', nest: () {
    builder.element('Type', nest: 2);
    builder.element('Name', nest: name);
    builder.element('File', nest: path);
    builder.element('ActiveX', nest: 'False');
    builder.element('ActiveXInstall', nest: 'False');
    builder.element('Action', nest: 0);
    builder.element('OverwriteDateTime', nest: 'False');
    builder.element('OverwriteAttributes', nest: 'False');
    builder.element('PassCommandLine', nest: 'False');
    builder.element('HideFromDialogs', nest: 0);
  });
}

void buildDir(XmlBuilder builder, String name, List<FileSystemEntity> entities) {
  builder.element('File', nest: () {
    builder.element('Type', nest: 3);
    builder.element('Name', nest: name);
    builder.element('Action', nest: 0);
    builder.element('OverwriteDateTime', nest: 'False');
    builder.element('OverwriteAttributes', nest: 'False');
    builder.element('HideFromDialogs', nest: 0);
    builder.element('Files', nest: () {
      for (final file in entities.whereType<File>()) {
        buildFile(builder, file.name, file.absolute.path);
      }

      for (final dir in entities.whereType<Directory>()) {
        buildDir(builder, dir.name, dir.listSync());
      }
    });
  });
}

void buildRegistry(XmlBuilder builder, String name) {
  builder.element('File', nest: () {
    builder.element('Type', nest: 1);
    builder.element('Virtual', nest: 'True');
    builder.element('Name', nest: name);
    builder.element('ValueType', nest: 0);
    builder.element('Value');
    builder.element('Registries');
  });
}

extension on FileSystemEntity {
  // get file name
  String get name => path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);
}