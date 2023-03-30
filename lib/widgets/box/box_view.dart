// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/positioned/positioned_view.dart';
import 'package:fml/widgets/widget/alignment.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// [BOX] view
class BoxView extends StatefulWidget implements IWidgetView
{
  final BoxModel model;

  BoxView(this.model) : super(key: ObjectKey(model));

  @override
  _BoxViewState createState() => _BoxViewState();

  /// Function to find gradient alignment
  static Alignment? toGradientAlignment(String? alignment) {
    Alignment? align;
    switch (alignment) {
      case 'top':
      case 'topcenter':
      case 'centertop':
        align = Alignment.topCenter;
        break;
      case 'bottom':
      case 'bottomcenter':
      case 'centerbottom':
        align = Alignment.bottomCenter;
        break;
      case 'left':
      case 'leftcenter':
      case 'centerleft':
        align = Alignment.centerLeft;
        break;
      case 'right':
      case 'rightcenter':
      case 'centerright':
        align = Alignment.centerRight;
        break;
      case 'topleft':
      case 'lefttop':
        align = Alignment.topLeft;
        break;
      case 'topright':
      case 'righttop':
        align = Alignment.topRight;
        break;
      case 'bottomleft':
      case 'leftbottom':
        align = Alignment.bottomLeft;
        break;
      case 'bottomright':
      case 'rightbottom':
        align = Alignment.bottomRight;
        break;
      default:
        align = null;
        break;
    }
    return align;
  }
}

List<Color> getGradientColors(c1, c2, c3, c4) {
  List<Color> gradientColors = [];
  if (c1 != null) gradientColors.add(c1);
  if (c2 != null) gradientColors.add(c2);
  if (c3 != null) gradientColors.add(c3);
  if (c4 != null) gradientColors.add(c4);
  return gradientColors;
}

class _BoxViewState extends WidgetState<BoxView>
{
  Widget _layoutChildren(List<Widget> children, WidgetAlignment alignment)
  {
    var layout = widget.model.getLayoutType();
    var wrap = widget.model.wrap;
    var constraints = widget.model.constraints.model;
    var expanding = widget.model.expand;

    Widget? child;
    switch (layout)
    {
      // stack widget
      case LayoutTypes.stack:

        if (!expanding)
        {
          // The stack sizes itself to contain all the non-positioned children,
          // which are positioned according to alignment.
          var hasNonPositionedChildren = children.firstWhereOrNull((child) => child is! PositionedView) != null;

          // we default the size to 50 pixels in the case
          // where there is no dimension or min dimension and the stack has no
          // non positioned children. Otherwise the stack size would be 0;
          var width  = constraints.width  ?? constraints.minWidth  ?? (hasNonPositionedChildren ? null : 50);
          var height = constraints.height ?? constraints.minHeight ?? (hasNonPositionedChildren ? null : 50);
          if (width  != null) children.add(SizedBox.fromSize(size: Size(width, 0)));
          if (height != null) children.add(SizedBox.fromSize(size: Size(0, height)));
        }
        else children.add(SizedBox.expand());

        // create the stack
        child = Stack(children: children, alignment: alignment.aligned);
        break;

      // row widget
      case LayoutTypes.row:

        // if the box is contracting and
        // there are no horizontal model (template) constraints
        // limiting the expansion (width, maxWidth) of the box,
        // set the axis size to min
        var mainAxisSize = MainAxisSize.max;
        if (!expanding && !constraints.hasHorizontalExpansionConstraints) mainAxisSize = MainAxisSize.min;

        if (!wrap)
             child = Row(mainAxisSize: mainAxisSize, children: children, crossAxisAlignment: alignment.crossAlignment, mainAxisAlignment: alignment.mainAlignment);
        else child = Wrap(direction: Axis.horizontal, children: children, alignment: alignment.mainWrapAlignment, runAlignment: alignment.mainWrapAlignment, crossAxisAlignment: alignment.crossWrapAlignment);
        break;

      // column widget
      case LayoutTypes.column:
      default:

        // if the box isn't expanding and
        // there are no vertical model (template) constraints
        // limiting the expansion (height, maxHeight) of the box,
        // set the axis size to min
        var mainAxisSize = MainAxisSize.max;
        if (!expanding && !widget.model.constraints.model.hasVerticalExpansionConstraints) mainAxisSize = MainAxisSize.min;

        if (!wrap)
               child = Column(mainAxisSize: mainAxisSize, children: children, crossAxisAlignment: alignment.crossAlignment, mainAxisAlignment: alignment.mainAlignment);
          else child = Wrap(direction: Axis.vertical, children: children, alignment: alignment.mainWrapAlignment, runAlignment: alignment.mainWrapAlignment, crossAxisAlignment: alignment.crossWrapAlignment);
          break;
    }
    return child;
  }

  Border? _getBorder()
  {
    Border? border;
    bool hasBorder = widget.model.border != 'none';
    if (hasBorder)
    {
      if (widget.model.border == 'all')
      {
        border = Border.all(
            color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface,
            width: widget.model.borderwidth!);
      } else {
        border = Border(
          top: (widget.model.border == 'top' ||
              widget.model.border == 'vertical')
              ? BorderSide(
              width: widget.model.borderwidth!,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          bottom: (widget.model.border == 'bottom' ||
              widget.model.border == 'vertical')
              ? BorderSide(
              width: widget.model.borderwidth!,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          left: (widget.model.border == 'left' ||
              widget.model.border == 'horizontal')
              ? BorderSide(
              width: widget.model.borderwidth!,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          right: (widget.model.border == 'right' ||
              widget.model.border == 'horizontal')
              ? BorderSide(
              width: widget.model.borderwidth!,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
        );
      }
    }
    return border;
  }

  BorderRadius? _getRadius(Border? border)
  {
    String? radius = widget.model.radius;
    if (radius == null) return null;
    if (border != null && widget.model.border != 'all') return null;

    // border decoration
    List<String> cornersFromTopRightClockwise = [];
    List<double?> radii = [];
    try
    {
      cornersFromTopRightClockwise = radius.split(',');
      if (cornersFromTopRightClockwise.length == 1) // round all the same
           radii = List<double?>.filled(4, S.toDouble(cornersFromTopRightClockwise[0]));
      else radii = cornersFromTopRightClockwise.map((r) => S.toDouble(r)).toList();
    }
    catch(e)
    {
      // TODO LOG
      radii = List<double>.filled(4, 0);
    }

    BorderRadius? containerRadius =
        BorderRadius.only(
        topRight: Radius.circular(
            radii.asMap().containsKey(0) ? radii[0] ?? 0 : 0),
        bottomRight: Radius.circular(
            radii.asMap().containsKey(1) ? radii[1] ?? 0 : 0),
        bottomLeft: Radius.circular(
            radii.asMap().containsKey(2) ? radii[2] ?? 0 : 0),
        topLeft: Radius.circular(
            radii.asMap().containsKey(3) ? radii[3] ?? 0 : 0));

    return containerRadius;
  }

  BoxShadow? _getShadow()
  {
    BoxShadow? shadow;
    if (widget.model.elevation != 0)
      shadow = BoxShadow(
          color: widget.model.shadowcolor,
          spreadRadius: widget.model.elevation,
          blurRadius: widget.model.elevation * 2,
          offset: Offset(
              widget.model.shadowx,
              widget.model
                  .shadowy));
    return shadow;
  }

  _getBoxDecoration(BorderRadius? radius)
  {
    // shadow
    BoxShadow? boxShadow = _getShadow();

    // get colors
    Color?  color  = widget.model.color;
    Color?  color2 = widget.model.color2;
    Color?  color3 = widget.model.color3;
    Color?  color4 = widget.model.color4;

    // gradient
    LinearGradient? gradient;
    if ((color != null) && (color2 != null))
    {
      gradient = LinearGradient(
        begin: BoxView.toGradientAlignment(widget.model.start)!,
        end: BoxView.toGradientAlignment(widget.model.end)!,
        colors: getGradientColors(color, color2, color3, color4),
        tileMode: TileMode.clamp);

      color = null;
    }
    return BoxDecoration(borderRadius: radius, boxShadow: boxShadow != null ? [boxShadow] : null, color: color, gradient: gradient);
  }

  EdgeInsets _getPadding()
  {
    var insets = EdgeInsets.only();
    if (widget.model.paddings > 0)
    {
      // pad all
      if (widget.model.paddings == 1) insets = EdgeInsets.all(widget.model.padding);

      // pad directions v,h
      else if (widget.model.paddings == 2) insets = EdgeInsets.symmetric(vertical: widget.model.padding, horizontal: widget.model.padding2);

      // pad sides top, right, bottom
      else if (widget.model.paddings == 3) insets = EdgeInsets.only(top: widget.model.padding, left: widget.model.padding2, right: widget.model.padding2, bottom: widget.model.padding3);

      // pad sides top, right, bottom
      else if (widget.model.paddings == 4) insets = EdgeInsets.only(top: widget.model.padding, right: widget.model.padding2, bottom: widget.model.padding3, left: widget.model.padding4);
    }
    return insets;
  }

  Widget _getFadedView(Widget view)
  {
    double? opacity = widget.model.opacity;
    if (opacity == null) return view;
    if (opacity > 1) opacity = 1;
    if (opacity < 0) opacity = 0;
    return Opacity(child: view, opacity: opacity);
  }

  Widget _getFrostedView(Widget child, BorderRadius? radius)
  {
     Widget view = BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: child);
     if (radius != null)
          view = ClipRRect(borderRadius: radius, child: view);
     else view = ClipRect(child: view);
     return view;
  }

  Widget _getBlurredView(Widget child, Decoration? decoration)
  {
     return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          child,
          ClipRect(
            clipBehavior: Clip.antiAlias,
            // <-- clips to the [Container] below
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: decoration,
                color: Colors.transparent,
              ),
            ),
          ),
        ]);
  }

  Widget _applyExpansionConstraints(Widget view)
  {
    // if widget is expanding we need to limit
    // its size if there are no limiting constraints
    if (widget.model.expand)
    {
      // get constraints in both axis?
      var hConstrained = widget.model.isHorizontallyConstrained();
      var vConstrained = widget.model.isVerticallyConstrained();

      // is the box unconstrained in either axis?
      if (!hConstrained || !vConstrained)
      {
        // calculate global min/max constraints
        var global = widget.model.constraints.calculate();

        // min width is either the global value or the size of the display
        var maxWidth  = global.maxWidth  ?? MediaQuery.of(context).size.height;
        var maxHeight = global.maxHeight ?? MediaQuery.of(context).size.height;

        // set constraints in order to contain the box
        // otherwise the flutter layout with throw an exception
        BoxConstraints constraints = BoxConstraints(maxHeight: maxHeight);
        if (!hConstrained && !vConstrained) constraints = BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
        if (!hConstrained &&  vConstrained) constraints = BoxConstraints(maxWidth: maxWidth);

        // set the constraints on the view
        view = ConstrainedBox(child: view, constraints: constraints);
      }
    }

    // allow box to shrink at will
    else view = UnconstrainedBox(child: view);

    return view;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    // save system constraints
    var minWidth  = constraints.minWidth;
    var maxWidth  = constraints.maxWidth  - ((S.toDouble(widget.model.borderwidth) ?? 0) * 2);
    var minHeight = constraints.minHeight - ((S.toDouble(widget.model.borderwidth) ?? 0) * 2);
    var maxHeight = constraints.maxHeight;

    // set system sizing
    widget.model.constraints.system = BoxConstraints(minWidth:  minWidth, maxWidth:  maxWidth, minHeight: minHeight, maxHeight: maxHeight);

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container(width: 0, height: 0));

    // this must go after the children are determined
    var alignment = AlignmentHelper.alignWidgetAxis(children.length, widget.model.layout, widget.model.center, widget.model.halign, widget.model.valign);

    // layout the children
    Widget? child = _layoutChildren(children, alignment);

    // border
    Border? border = _getBorder();

    // border radius
    BorderRadius? radius = _getRadius(border);

    // box decoration
    BoxDecoration? decoration = _getBoxDecoration(radius);

    // border decoration
    BoxDecoration? borderDecoration = border != null ? BoxDecoration(border: border, borderRadius: radius) : null;

    // blurred?
    if (widget.model.blur) child = _getBlurredView(child, borderDecoration);

    // inner box - contents
    Widget view = Container(padding: _getPadding(), clipBehavior: Clip.antiAlias, decoration: decoration, alignment: alignment.aligned, child: child);

    // outer box - border
    view = Container(decoration: borderDecoration, child: view);

    // set opacity
    if (widget.model.opacity != null) view = _getFadedView(view);

    // set blur - white10 = Blur (This creates mirrored/frosted effect overtop of something else)
    if (widget.model.color == Colors.white10) view = _getFrostedView(view, radius);

    // apply constraints
    // note: localConstraints is overridden in BoxModel
    // in order to handle "expand" correctly
    view = applyConstraints(view, widget.model.constraints.model);

    // apply constraints to allow the box
    // to fit properly based on expand=true/false
    view = _applyExpansionConstraints(view);

    return view;
  }
}
