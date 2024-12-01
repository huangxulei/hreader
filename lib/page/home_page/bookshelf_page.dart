import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/model/book.dart';
import 'package:hreader/providers/book_list.dart';
import 'package:hreader/service/book.dart';
import 'package:hreader/utils/get_path/cache_path.dart';
import 'package:hreader/utils/log/common.dart';
import 'package:hreader/utils/toast/common.dart';
import 'package:hreader/widgets/bookshelf/book_bottom_sheet.dart';
import 'package:hreader/widgets/bookshelf/book_folder.dart';
import 'package:hreader/widgets/tips/bookshelf_tips.dart';

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => BookshelfPageState();
}

class BookshelfPageState extends ConsumerState<BookshelfPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _syncAnimationController;
  final _scrollController = ScrollController();

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
        Directory tempDir = await getHCacheDir();
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
                        await importBook(file, ref);
                      }
                      Navigator.of(context).pop('dialog');
                    },
                    child: Text("导入${supportedFiles.length}本书"))
            ],
          );
        });
  }

  @override
  void dispose() {
    _syncAnimationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    HToast.init(context);
    _syncAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    void handleBottomSheet(BuildContext context, Book book) {
      showBottomSheet(
        context: context,
        builder: (context) => BookBottomSheet(book: book),
      );
    }

    List<int> _lockedIndices = [];
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
      body: ref.watch(bookListProvider).when(
            data: (books) {
              for (int i = 0; i < books.length; i++) {
                // folder can't be dragged
                if (books[i].length != 1) {
                  _lockedIndices.add(i);
                }
              }
              return books.isEmpty
                  ? const Center(child: BookshelfTips())
                  : ReorderableBuilder(
                      lockedIndices: _lockedIndices,
                      enableDraggable: true,
                      longPressDelay: const Duration(milliseconds: 300),
                      onDragStarted: (index) {
                        if (books[index].length == 1) {
                          handleBottomSheet(context, books[index].first);
                          for (int i = 0; i < books.length; i++) {
                            if (i != index) {
                              _lockedIndices.add(i);
                            }
                          }
                        }
                      },
                      onDragEnd: (index) {
                        _lockedIndices = [];
                        for (int i = 0; i < books.length; i++) {
                          if (i != index) {
                            _lockedIndices.add(i);
                          }
                        }
                        setState(() {});
                      },
                      scrollController: _scrollController,
                      onReorder:
                          (ReorderedListFunction reorderedListFunction) {},
                      children: [
                        ...books.map((book) {
                          return book.length == 1
                              ? CustomDraggable(
                                  key: Key(book.first.id.toString()),
                                  data: book.first,
                                  child: BookFolder(books: book))
                              : BookFolder(
                                  key: Key(book.first.id.toString()),
                                  books: book,
                                );
                        })
                      ],
                      builder: (children) {
                        return GridView(
                          key: GlobalKey(),
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width ~/ 110,
                            childAspectRatio: 0.55,
                            mainAxisSpacing: 30,
                            crossAxisSpacing: 20,
                          ),
                          children: children,
                        );
                      });
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
          ),
    );
  }
}
