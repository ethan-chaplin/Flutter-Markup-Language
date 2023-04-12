// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/card/card_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Card [CardModel]
///
/// DEPRECATED
/// Defines the properties used to build a [CARD.CardView]
class CardModel extends DecoratedWidgetModel 
{
  ///////////////
  /* elevation */
  ///////////////
  DoubleObservable? _elevation;
  set elevation(dynamic v) {
    if (_elevation != null) {
      _elevation!.set(v);
    } else if (v != null) {
      _elevation = DoubleObservable(Binding.toKey(id, 'elevation'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get elevation => _elevation?.get() ?? 1;

  ///////////////
  /* radius */
  ///////////////
  DoubleObservable? _radius;
  set radius(dynamic v) {
    if (_radius != null) {
      _radius!.set(v);
    } else if (v != null) {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => _radius?.get() ?? 4;

  // padding inside the widget 
  DoubleObservable? _padding;
  set padding(dynamic v) {
    if (_padding != null) {
      _padding!.set(v);
    } else if (v != null) {
      _padding = DoubleObservable(Binding.toKey(id, 'padding'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get padding => _padding?.get() ?? 5;

  //////////////////
  /* border color */
  //////////////////
  ColorObservable? _bordercolor;
  set bordercolor(dynamic v) {
    if (_bordercolor != null) {
      _bordercolor!.set(v);
    } else if (v != null) {
      _bordercolor = ColorObservable(
          Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get bordercolor => _bordercolor?.get();

  //////////////////
  /* border color */
  //////////////////
  DoubleObservable? _borderwidth;
  set borderwidth(dynamic v) {
    if (_borderwidth != null) {
      _borderwidth!.set(v);
    } else if (v != null) {
      _borderwidth = DoubleObservable(
          Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get borderwidth => _borderwidth?.get() ?? 1;

  //overrides
  double? get margins => super.marginTop ?? 5;
  String  get halign  => super.halign  ?? "start";
  String  get valign  => super.valign  ?? "start";

  CardModel(
    WidgetModel parent,
    String? id, {
    dynamic visible,
    dynamic margin,
    dynamic elevation,
    dynamic color,
    dynamic bordercolor,
    dynamic halign,
    dynamic valign,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic radius,
    dynamic borderwidth,
  }) : super(parent, id)
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    this.margins = margin;
    this.radius = radius;
    this.color = color;
    this.bordercolor = bordercolor;
    this.elevation = elevation;
    this.padding = padding;
    this.halign = halign;
    this.valign = valign;
    this.borderwidth = borderwidth;
  }

  static CardModel? fromXml(WidgetModel parent, XmlElement xml) {
    CardModel? model;
    try {
// build model
      model = CardModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch(e) {
      Log().exception(e,
           caller: 'card.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    padding = Xml.get(node: xml, tag: 'padding');
    elevation = Xml.get(node: xml, tag: 'elevation');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(CardView(this));
}
