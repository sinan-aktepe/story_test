import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pirimedya_story/src/backward_compatibility/flutter_v2_compatibility.dart';

/// Signature for a function that creates a widget for a given index in a [CubePageView]
///
/// Used by [CubePageView.builder] and other APIs that use lazily-generated widgets.
///
typedef CubeWidgetBuilder = CubeWidget Function(BuildContext context, int index, double pageNotifier);

/// This Widget has the [PageView] widget inside.
/// It works in two modes :
///   1 - Using the default constructor [CubePageView] passing the items in `children` property.
///   2 - Using the factory constructor [CubePageView.builder] passing a `itemBuilder` and `itemCount` properties.
class CubePageView extends StatefulWidget {
  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int>? onPageChanged;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final PageController? controller;

  final int? initialIndex;

  /// Builder to customize your items
  final CubeWidgetBuilder? itemBuilder;

  /// The number of items you have, this is only required if you use [CubePageView.builder]
  final int? itemCount;

  /// Widgets you want to use inside the [CubePageView], this is only required if you use [CubePageView] constructor
  final List<Widget>? children;

  final ValueNotifier<bool> isAutoScroll;

  /// Creates a scrollable list that works page by page from an explicit [List]
  /// of widgets.
  const CubePageView({
    Key? key,
    this.onPageChanged,
    this.controller,
    this.initialIndex,
    required this.children,
    required this.isAutoScroll,
  })  : itemBuilder = null,
        itemCount = null,
        assert(children != null),
        super(key: key);

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate if you want to customize the behavior
  ///
  /// Providing a non-null [itemCount] lets the [CubePageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  const CubePageView.builder({
    Key? key,
    required this.itemCount,
    required this.isAutoScroll,
    required this.itemBuilder,
    this.onPageChanged,
    this.controller,
    this.initialIndex,
  })  : children = null,
        assert(itemCount != null),
        assert(itemBuilder != null),
        super(key: key);

  @override
  _CubePageViewState createState() => _CubePageViewState();
}

class _CubePageViewState extends State<CubePageView> {
  late ValueNotifier<double> _pageNotifier;
  late PageController _pageController;

  //ScrollPhysics? scrollPhysics;

  @override
  void initState() {
    _pageController = widget.controller ?? PageController(initialPage: widget.initialIndex ?? 0);
    //scrollPhysics = const ClampingScrollPhysics();
    _pageNotifier = ValueNotifier(widget.initialIndex?.toDouble() ?? 0);

    ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
      _pageController.addListener(_listener);
      widget.isAutoScroll.addListener(_listenIsScrolling);
    });
    super.initState();
  }

  void localOnPageChange() {

      _pageController.position.context.setCanDrag(true);
      widget.isAutoScroll.value = false;

  }

  void _listener() {
    _pageNotifier.value = _pageController.page!;
   // print('_CubePageViewState._listener ${_pageController.position.allowImplicitScrolling}');
  }

  _listenIsScrolling() {
    if (widget.isAutoScroll.value) {
      _pageController.position.context.setCanDrag(false);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_listener);
    widget.isAutoScroll.removeListener(_listenIsScrolling);
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<double>(
        valueListenable: _pageNotifier,
        builder: (_, value, child) => PageView.builder(
          controller: _pageController,
          onPageChanged: (value) {
            localOnPageChange();
            widget.onPageChanged?.call(value);
          },
          physics: const CustomPageViewScrollPhysics(),
          itemCount: widget.itemCount ?? widget.children?.length,
          itemBuilder: (_, index) {
            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(context, index, value);
            }
            return CubeWidget(
              child: widget.children![index],
              index: index,
              pageNotifier: value,
            );
          },
        ),
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 80,
    stiffness: 100,
    damping: 1,
  );
}


/// This widget has the logic to do the 3D cube transformation
/// It only should be used if you use [CubePageView.builder]
class CubeWidget extends StatelessWidget {
  /// Index of the current item
  final int index;

  /// Page Notifier value, it comes from the [CubeWidgetBuilder]
  final double pageNotifier;

  /// Child you want to use inside the Cube
  final Widget child;

  const CubeWidget({
    Key? key,
    required this.index,
    required this.pageNotifier,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLeaving;
    Locale myLocale = Localizations.localeOf(context);
    final t = (index - pageNotifier);
    final rotationY = lerpDouble(0, 40, t);
    final opacity = lerpDouble(0, 0.8, t.abs())?.clamp(0.0, 1.0) ?? 1;
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.003);
    if (myLocale.languageCode == 'ar'){
      transform.rotateY(degToRad(rotationY ?? 0));
      isLeaving  = (pageNotifier - index ) <= 0;
    } else {
      transform.rotateY(-degToRad(rotationY ?? 0));
      isLeaving  = (index - pageNotifier ) <= 0;
    }
    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Opacity(
        opacity: 1 - opacity,
        child: child,
      ),
    );
  }
}

double degToRad(double deg) => deg * (pi / 180.0);

double radToDeg(double rad) => rad * (180.0 / pi);
