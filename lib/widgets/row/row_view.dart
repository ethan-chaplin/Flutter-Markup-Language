// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/alignment.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/layout_model.dart';

class RowView extends StatefulWidget implements IWidgetView
{
  final LayoutModel model;

  RowView(this.model) : super(key: ObjectKey(model));

  @override
  _RowViewState createState() => _RowViewState();
}

class _RowViewState extends WidgetState<RowView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    //this must go after the children are determined. Returns an alignment map.
    var alignment = WidgetAlignment(LayoutType.row, widget.model.center, WidgetAlignment.getHorizontalAlignmentType(widget.model.halign), WidgetAlignment.getVerticalAlignmentType(widget.model.valign));

    // get main axis size
    MainAxisSize? mainAxisSize = widget.model.horizontalAxisSize;

    // check if wrap is true,and return the wrap widgets children.
    Widget view;

    // create view
    if (widget.model.wrap == true)
      view = Wrap(
              children: children,
              direction: Axis.horizontal,
              alignment: alignment.mainWrapAlignment,
              runAlignment: alignment.mainWrapAlignment,
              crossAxisAlignment: alignment.crossWrapAlignment);
    else
      view = Row(
              children: children,
              crossAxisAlignment: alignment.crossAlignment,
              mainAxisAlignment: alignment.mainAlignment,
              mainAxisSize: mainAxisSize);

    // add margins
    if (model is RowModel) view = addMargins(view);

    // apply user defined constraints
    if (model is RowModel) view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }
}
