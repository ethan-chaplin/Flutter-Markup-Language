// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/switch/switch_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';

class SwitchView extends StatefulWidget {
  final SwitchModel model;
  final dynamic onChangeCallback;
  SwitchView(this.model, {this.onChangeCallback});

  @override
  _SwitchViewState createState() => _SwitchViewState();
}

class _SwitchViewState extends State<SwitchView> with WidgetsBindingObserver implements IModelListener {
  RenderBox? box;
  Offset? position;

  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SwitchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_SwitchViewState.build] when the [SwitchModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    widget.model.minWidth = constraints.minWidth;
    widget.model.maxWidth = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    bool value = widget.model.value;
    String? label = widget.model.label;
    bool canSwitch =
        (widget.model.enabled != false && widget.model.editable != false);
    double width = widget.model.width;

    //////////
    /* View */
    //////////
    Widget view;
    ColorScheme th = Theme.of(context).colorScheme;
    view = Switch.adaptive(
      value: value, onChanged: canSwitch ? onChange : null,
      // activeColor: th.inversePrimary, activeTrackColor: th.primaryContainer, inactiveThumbColor: th.onInverseSurface, inactiveTrackColor: th.surfaceVariant,);
      activeColor: widget.model.color ?? th.primary,
      activeTrackColor:
          widget.model.color?.withOpacity(0.65) ?? th.inversePrimary,
      inactiveThumbColor: th.onInverseSurface,
      inactiveTrackColor: th.surfaceVariant,
    );

    ///////////////
    /* Disabled? */
    ///////////////
    if (!canSwitch)
      view = MouseRegion(
          cursor: SystemMouseCursors.forbidden,
          child: Tooltip(
              message: 'Locked',
              preferBelow: false,
              verticalOffset: 12,
              child: view));

    ///////////////
    /* Labelled? */
    ///////////////
    if (widget.model.label != null)
      view = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(label, style: TextStyle(fontStyle: )),
          TextView(TextModel(null, null,
              value: label,
              style: 'caption',
              color: th.onSurfaceVariant.withOpacity(0.75))),
          view
        ],
      );

    ////////////////////
    /* Constrain Size */
    ////////////////////
    view = SizedBox(child: view, width: width);

    return view;
  }

  /// After [iFormFields] are drawn we get the global offset for scrollTo functionality
  _afterBuild(BuildContext context) {
    // Set the global offset position of each input
    box = context.findRenderObject() as RenderBox?;
    if (box != null) position = box!.localToGlobal(Offset.zero);
    if (position != null) widget.model.offset = position;
  }

  onChange(bool value) async {
    var editable = (widget.model.editable != false);
    if (!editable) return;

      ////////////////////
      /* Value Changed? */
      ////////////////////
    if (widget.model.value != value) {
      ///////////////////////////
      /* Retain Rollback Value */
      ///////////////////////////
      dynamic old = widget.model.value;

      ////////////////
      /* Set Answer */
      ////////////////
      await widget.model.answer(value);

      //////////////////////////
      /* Fire on Change Event */
      //////////////////////////
      if (value != old) await widget.model.onChange(context);
    }
  }
}
