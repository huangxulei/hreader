import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/utils/log/common.dart';

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
