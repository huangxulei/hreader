import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/utils/get_path/cache_path.dart';
import 'package:hreader/utils/log/common.dart';
import 'package:hreader/utils/toast/common.dart';

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => BookshelfPageState();
}

class BookshelfPageState extends ConsumerState<BookshelfPage>
    with SingleTickerProviderStateMixin {
  Future<void> _importBook() async {
    final allowBookExtensions = ["epub", "mobi", "azw3", "fb2"];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result == null) {
      return;
    }

    List<PlatformFile> files = result.files;
    HLog.info('importBook files: ${files.toString()}');
    List<File> fileList = [];

    if (!Platform.isAndroid) {
      fileList = await Future.wait(files.map((file) async {
        Directory tempDir = await getAnxCacheDir();
        File tempFile = File("${tempDir.path}/${file.name}");
        await File(file.path!).copy(tempFile.path);
        return tempFile;
      }).toList());
    } else {
      fileList = files.map((file) => File(file.path!)).toList();
    }

    HLog.info("importBook fileList: ${fileList.toString()}");

    List<File> supportedFiles = fileList.where((file) {
      return allowBookExtensions.contains(file.path.split('.').last);
    }).toList();
    List<File> unsupportedFiles = fileList.where((file) {
      return !allowBookExtensions.contains(file.path.split('.').last);
    }).toList();

    // delete unsupported files
    for (var file in unsupportedFiles) {
      file.deleteSync();
    }

    Widget bookItem(String path, Icon icon) {
      return Row(children: [
        icon,
        Expanded(
            child: Text(path.split('/').last,
                style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    overflow: TextOverflow.ellipsis)))
      ]);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${fileList.length}"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(allowBookExtensions.join(' / ')),
                  const SizedBox(height: 10),
                  if (unsupportedFiles.isNotEmpty)
                    Text("${unsupportedFiles.length}"),
                  const SizedBox(height: 20),
                  for (var file in unsupportedFiles)
                    bookItem(file.path, const Icon(Icons.error)),
                  for (var file in supportedFiles)
                    bookItem(file.path, const Icon(Icons.done)),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    for (var file in supportedFiles) {
                      file.deleteSync();
                    }
                  },
                  child: Text("取消")),
              if (supportedFiles.isNotEmpty)
                TextButton(
                    onPressed: () async {
                      for (var file in supportedFiles) {
                        HToast.show(file.path.split('/').last);
                      }
                    },
                    child: Text("导入${supportedFiles.length}本书"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("黄读"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _importBook,
          ),
        ],
      ),
    );
  }
}
