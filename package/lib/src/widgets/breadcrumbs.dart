import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../utils/models/breadcrumb_item.dart';
import '../utils/extensions/listview_extended.dart';

/// Scrolling horizontal breadcrumbs with `Icons.chevron_right` separator and fade on the right.
class Breadcrumbs<T> extends StatelessWidget {
  static const double defaultHeight = 50;

  /// List of items of breadcrumbs
  final List<BreadcrumbItem<T?>> items;

  /// Height of the breadcrumbs panel
  final double height;

  /// List item text color
  final Color? textColor;

  /// Called when an item is selected
  final ValueChanged<T?>? onSelect;

  /// The theme for Breadcrumbs.
  final BreadcrumbsThemeData? theme;

  final ScrollController _scrollController = ScrollController();

  final ThemeData? themeData;

  Breadcrumbs({
    Key? key,
    required this.items,
    this.height = defaultHeight,
    this.textColor,
    this.onSelect,
    this.themeData,
  }) : super(key: key);

  void _scrollToEnd() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment(0.7, 0.5),
          end: Alignment.centerRight,
          colors: <Color>[Colors.white, Colors.transparent],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Container(
        alignment: Directionality.of(context) == TextDirection.rtl
            ? Alignment.topRight
            : Alignment.topLeft,
        height: height,
        child: ListViewExtended.separatedWithHeaderFooter(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ButtonTheme(
              minWidth: 48,
              padding: EdgeInsets.symmetric(
                    vertical: ButtonTheme.of(context).padding.vertical,
                  ) +
                  const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: (index == (items.length - 1))
                        ? (themeData ?? Theme.of(context))
                            .textTheme
                            .bodyMedium!
                            .color
                        : (themeData ?? Theme.of(context))
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withOpacity(0.75)),
                onPressed: () {
                  items[index].onSelect?.call(items[index].data);
                  onSelect?.call(items[index].data);
                },
                child: Text(
                  path.basename(
                    Directory(items[index].data.toString()).absolute.path,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => Container(
            alignment: Alignment.center,
            child: Icon(
              Icons.chevron_right,
              color: (themeData ?? Theme.of(context))
                  .textTheme
                  .bodyMedium!
                  .color!
                  .withOpacity(0.45),
            ),
          ),
          headerBuilder: (_) => SizedBox(
            width: ButtonTheme.of(context).padding.horizontal - 8,
          ),
          footerBuilder: (_) => const SizedBox(width: 70),
        ),
      ),
    );
  }
}
