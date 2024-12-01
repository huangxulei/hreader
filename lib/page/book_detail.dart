import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/model/book.dart';
import 'package:hreader/service/book.dart';
import 'package:hreader/utils/log/common.dart';
import 'package:hreader/widgets/bookshelf/book_cover.dart';

class BookDetail extends ConsumerStatefulWidget {
  const BookDetail({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookDetailState();
}

class _BookDetailState extends ConsumerState<BookDetail> {
  late double rating;
  bool isEditing = false;
  late Book _book;

  @override
  void initState() {
    super.initState();
    rating = widget.book.rating;
    _book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBackground() {
      return ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(0.20),
                Colors.transparent
              ]).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: bookCover(context, _book,
            height: 600, width: MediaQuery.of(context).size.width),
      );
    }

    Widget buildBookBaseDetail(double width) {
      TextStyle bookTitleStyle = TextStyle(
        fontSize: 24,
        fontFamily: 'SourceHanSerif',
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      );
      TextStyle bookAuthorStyle = TextStyle(
        fontSize: 15,
        fontFamily: 'SourceHanSerif',
        color: Theme.of(context).textTheme.bodyLarge!.color,
      );
      double top = 60;

      return SizedBox(
          height: 270 + top,
          child: Stack(children: [
            Positioned(
                left: 0,
                top: 150 + top,
                child: SizedBox(
                    height: 120,
                    width: width,
                    child: Card(
                        child: Row(
                      children: [
                        const Spacer(),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: widget.book.readingPercentage,
                                strokeWidth: 6,
                                backgroundColor: Colors.grey[400],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  "${(widget.book.readingPercentage * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )))),
            Positioned(
              left: 20,
              top: 0 + top,
              child: GestureDetector(
                onTap: () async {
                  if (!isEditing) {
                    return;
                  }

                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.image, allowMultiple: false);
                  if (result == null) {
                    return;
                  }
                  File image = File(result.files.single.path!);

                  HLog.info("BookDetail: Image path: ${image.path}");

                  final File oldCoverImageFile =
                      File(widget.book.coverFullPath);
                  if (await oldCoverImageFile.exists()) {
                    await oldCoverImageFile.delete();
                  }

                  String newPath =
                      '${widget.book.coverPath.split('/').sublist(0, widget.book.coverPath.split('/').length - 1).join('/')}/${widget.book.title.length > 20 ? widget.book.title.substring(0, 20) : widget.book.title}-${DateTime.now().millisecond.toString()}.png'
                          .replaceAll(' ', '_');
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 6,
                            blurRadius: 30,
                            offset: const Offset(0, 3))
                      ]),
                  child: Hero(
                      tag: widget.book.coverFullPath,
                      child: bookCover(context, widget.book,
                          height: 230, width: 160)),
                ),
              ),
            ),
            Positioned(
                left: 30,
                top: 240 + top,
                child: RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      this.rating = rating;
                      updateBookRating(widget.book, rating);
                    });
                  },
                )),
            // book title and author
            Positioned(
              left: 190,
              top: 5 + top,
              child: SizedBox(
                width: width - 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      autofocus: true,
                      initialValue: widget.book.title,
                      enabled: isEditing,
                      style: bookTitleStyle,
                      maxLines: null,
                      minLines: 1,
                      decoration: const InputDecoration(
                          border: InputBorder.none, isCollapsed: true),
                      onChanged: (value) => value.replaceAll('\n', ' '),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      initialValue: widget.book.author,
                      enabled: isEditing,
                      style: bookAuthorStyle,
                      maxLength: null,
                      minLines: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged: (value) {
                        widget.book.author = value;
                      },
                    )
                  ],
                ),
              ),
            )
          ]));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          buildBackground(),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: ListView(
                            padding: const EdgeInsets.all(0),
                            children: [
                              buildBookBaseDetail(
                                  constraints.maxWidth / 2 - 20),
                              const SizedBox(height: 5),
                            ],
                          )),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Container(
                            child: Text("1111"),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return ListView(padding: const EdgeInsets.all(0), children: [
                    buildBookBaseDetail(constraints.maxWidth),
                    const SizedBox(height: 5),
                  ]);
                }
              }))
        ],
      ),
    );
  }
}
