// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:fml/helper/helper_barrel.dart';

class RowView extends StatefulWidget
{
  final RowModel model;

  RowView(this.model) : super(key: ObjectKey(model));

  @override
  _RowViewState createState() => _RowViewState();
}

class _RowViewState extends State<RowView> implements IModelListener {

  
  @override
  void initState() {
    super.initState();
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  
  @override
  void didUpdateWidget(RowView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_RowViewState.build] when the [RowModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minwidth = constraints.minWidth;
    widget.model.maxwidth = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());

    //this must go after the children are determined. Returns an alignment map.
    Map<String, dynamic> align = AlignmentHelper.alignWidgetAxis(
        children.length,
        'row',
        widget.model.center,
        widget.model.halign,
        widget.model.valign);
    CrossAxisAlignment? crossAlignment = align['crossAlignment'];
    MainAxisAlignment? mainAlignment = align['mainAlignment'];
    WrapAlignment? mainWrapAlignment = align['mainWrapAlignment'];
    WrapCrossAlignment? crossWrapAlignment = align['crossWrapAlignment'];

    ///////////////
    /* Safeguard */
    ///////////////
    var mainAxisSize =
        widget.model.shrinkwrap == true || widget.model.expand == false
            ? MainAxisSize.min
            : MainAxisSize.max;
    if ((mainAxisSize == MainAxisSize.max) &&
        (!widget.model.constrained) &&
        (constraints.maxWidth == double.infinity))
      mainAxisSize = MainAxisSize.min;

    // check if wrap is true,and return the wrap widgets children.
    Widget view;

    ////////////////////
    /* Padding values */
    ////////////////////
    EdgeInsets insets = EdgeInsets.only();
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

    if (widget.model.wrap == true)
      view = Padding(
          padding: insets,
          child: Wrap(
              children: children,
              direction: Axis.horizontal,
              alignment: mainWrapAlignment!,
              runAlignment: mainWrapAlignment,
              crossAxisAlignment: crossWrapAlignment!));
    else
      view = Padding(
          padding: insets,
          child: Row(
              children: children,
              crossAxisAlignment: crossAlignment!,
              mainAxisAlignment: mainAlignment!,
              mainAxisSize: mainAxisSize));

    //////////////////
    /* Constrained? */
    //////////////////
    if (widget.model.constrained) {
      Map<String, double?> constraints = widget.model.constraints;
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constraints['minheight']!,
              maxHeight: constraints['maxheight']!,
              minWidth: constraints['minwidth']!,
              maxWidth: constraints['maxwidth']!));
    }

    return view;
  }
}