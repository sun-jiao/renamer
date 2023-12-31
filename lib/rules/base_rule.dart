part of 'rule.dart';

abstract interface class Rule {
  FutureOr<String> newName(String oldName, {FileMetadata? metadata});

  @override
  String toString();
}

(String, String) splitFileName(String oldName, bool ignoreExtension) {
  String newName = oldName;
  String extension = '';

  if (ignoreExtension) {
    final lastIndex = oldName.lastIndexOf('.');

    if (lastIndex > 0) {
      extension = oldName.substring(lastIndex);
      newName = oldName.substring(0, lastIndex);
    }
  }

  return (newName, extension);
}
