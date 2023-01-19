// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class OptionModel extends WidgetModel
{
  ///////////
  /* label */
  ///////////
  IViewableWidget? label;

  dynamic labelValue;
  ///////////
  /* Value */
  ///////////
  dynamic _value;
  set value (dynamic v)
  {
         if (_value is StringObservable) _value.set(v);
    else if (_value is String) _value = v;
    else if ((_value == null) && (v != null))
    {
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get value
  {
    if (_value == null) return null;
    if (_value is StringObservable) return _value.get();
    if (_value is String) return _value;
    return null;
  }

  //////////
  /* tags */
  //////////
  StringObservable? _tags;
  set tags(dynamic v) {
    if (_tags != null) {
      _tags!.set(v);
    } else if (v != null) {
      _tags = StringObservable(Binding.toKey(id, 'tags'), v, scope: scope, listener: onPropertyChange);
    }
  }

  String? get tags {
    return _tags?.get();
  }

  OptionModel(WidgetModel? parent, String? id, {dynamic data, dynamic labelValue, IViewableWidget? label, dynamic value, dynamic tags}) : super(parent, id, scope: Scope(id))
  {
    this.data = data;
    if (label != null) this.label = label;
    if (labelValue != null) this.labelValue = labelValue;
    if (value != null) this.value = value;
    if (tags != null) this.tags = tags;
  }

  static OptionModel? fromXml(WidgetModel? parent, XmlElement? xml, {dynamic data})
  {
    OptionModel? model;
    try
    {
      // build model
      model = OptionModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'option.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    if (xml == null) return;

    // deserialize 
    super.deserialize(xml);

    ///////////
    /* Label */
    ///////////
    String? label = Xml.attribute(node: xml, tag: 'label');
    if (S.isNullOrEmpty(label))
    {
      XmlElement? node = Xml.getElement(node: xml, tag: 'label');
      if (node != null)
      {
        if (Xml.hasChildElements(node))
             this.label = RowModel.fromXml(this, node);
        else this.label = TextModel(this, this.id, value: Xml.getText(node));
      }
    }
    else this.label = TextModel(this, this.id, value: label);

    ////////////
    /* Empty? */
    ////////////
    if (this.label == null)
    {
      label = Xml.getText(xml);
      this.label = TextModel(this, this.id, value: label);
    }

    ///////////
    /* Value */
    ///////////
    String? value = Xml.get(node: xml, tag: 'value');
    if (value == null) {
      this.value = label;
      labelValue = label;
    }
    else this.value = value;
    labelValue = label;

    tags = Xml.get(node: xml, tag: 'tags');
  }
}
