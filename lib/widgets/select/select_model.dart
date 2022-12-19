// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/dialog/service.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/iFormField.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/select/select_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class SelectModel extends FormFieldModel implements IFormField, IViewableWidget
{
  bool? addempty = true;

  // bindable data
  ListObservable? _data;
  set data(dynamic v)
  {
    if (_data != null)
    {
      _data!.set(v);
    }
    else if (v != null)
    {
      _data = ListObservable(Binding.toKey(id, 'data'), null, scope: scope, listener: onPropertyChange);
      _data!.set(v);
    }
  }
  get data => _data?.get();

  //////////
  /* hint */
  //////////
  StringObservable? _hint;
  set hint(dynamic v) {
    if (_hint != null) {
      _hint!.set(v);
    } else if (v != null) {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get hint {
    return _hint?.get();
  }

  //////////
  /* label */
  //////////
  StringObservable? _label;
  set label(dynamic v) {
    if (_label != null) {
      _label!.set(v);
    } else if (v != null) {
      _label = StringObservable(Binding.toKey(id, 'label'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get label {
    return _label?.get();
  }

  ////////////
  /* border */
  ////////////
  StringObservable? _border;
  set border(dynamic v) {
    if (_border != null) {
      _border!.set(v);
    } else if (v != null) {
      _border = StringObservable(Binding.toKey(id, 'border'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get border {
    if (_border == null) return 'all';
    return _border?.get();
  }

  /////////////////
  /* borderwidth */
  /////////////////
  IntegerObservable? _borderwidth;
  set borderwidth(dynamic v) {
    if (_borderwidth != null) {
      _borderwidth!.set(v);
    } else if (v != null) {
      _borderwidth = IntegerObservable(
          Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int? get borderwidth {
    return _borderwidth?.get();
  }

  //////////////////
  /* borderradius */
  //////////////////
  IntegerObservable? _radius;
  set radius(dynamic v) {
    if (_radius != null) {
      _radius!.set(v);
    } else if (v != null) {
      _radius = IntegerObservable(Binding.toKey(id, 'radius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int? get radius {
    return _radius?.get();
  }

  //////////////////
  /* Border Color */
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

  Color? get bordercolor {
    return _bordercolor?.get();
  }

  // prototype
  String? prototype;

  // options
  final List<OptionModel> options = [];

  ///////////////
  /* typeahead */
  ///////////////
  BooleanObservable? _typeahead;
  set typeahead(dynamic v) {
    if (_typeahead != null) {
      _typeahead!.set(v);
    } else if (v != null) {
      _typeahead = BooleanObservable(
          Binding.toKey(id, 'typeahead'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get typeahead => _typeahead?.get() ??  false;

  //////////////////
  /* inputenabled */
  //////////////////
  BooleanObservable? _inputenabled;
  set inputenabled(dynamic v) {
    if (_inputenabled != null) {
      _inputenabled!.set(v);
    } else if (v != null) {
      _inputenabled = BooleanObservable(
          Binding.toKey(id, 'inputenabled'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get inputenabled => _inputenabled?.get() ?? false;

  ///////////
  /* Value */
  ///////////
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
    setData();
  }
  dynamic get value
  {
    if (_value == null) return defaultValue;
    if ((!dirty) && (S.isNullOrEmpty(_value?.get())) && (!S.isNullOrEmpty(defaultValue))) _value!.set(defaultValue);
    return _value?.get();
  }

  ///////////////
  /* font size */
  ///////////////
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
    } else {
      if (v != null)
        _size = DoubleObservable(Binding.toKey(id, 'size'), v,
            scope: scope, listener: onPropertyChange);
    }
  }
  double? get size => _size?.get();


  ////////////
  /* length */
  ////////////
  IntegerObservable? _length;
  set length(dynamic v) {
    if (_length != null) {
      _length!.set(v);
    } else {
      if (v != null)
        _length = IntegerObservable(Binding.toKey(id, 'length'), v,
            scope: scope, listener: onPropertyChange);
    }
  }
  int? get length => _length?.get();


  //
  //  Match Type
  //
  StringObservable? _matchtype;
  set matchtype(dynamic v) {
    if (_matchtype != null) {
      _matchtype!.set(v);
    } else {
      if (v != null)
        matchtype = StringObservable(Binding.toKey(id, 'matchtype'), v,
            scope: scope, listener: onPropertyChange);
    }
  }
  String? get matchtype => _matchtype?.get();


  SelectModel(WidgetModel parent, String? id,
      {dynamic visible,
        dynamic hint,
        dynamic border,
        dynamic mandatory,
        dynamic editable,
        dynamic enabled,
        dynamic inputenabled,
        dynamic value,
        dynamic defaultValue,
        dynamic width,
        dynamic onchange,
        dynamic post,
        dynamic typeahead,
        dynamic bold,
        dynamic italic,
        String? postbroker,
        dynamic bordercolor,
        dynamic color,
        dynamic borderwidth,
        dynamic radius,
        dynamic matchtype,
        dynamic label,
        })
      : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    if (mandatory    != null)  this.mandatory   = mandatory;
    if (bordercolor  != null)  this.bordercolor = bordercolor;
    if (color        != null)  this.color       = color;
    if (radius       != null)  this.radius      = radius;
    if (borderwidth  != null)  this.borderwidth = borderwidth;
    if (border       != null)  this.border      = border;
    if (hint         != null)  this.hint        = hint;
    if (editable     != null)  this.editable    = editable;
    if (enabled      != null)  this.enabled     = enabled;
    if (inputenabled != null) this.inputenabled = inputenabled;
    if (value        != null) this.value        = value;
    if (defaultValue != null) this.defaultValue = defaultValue;
    if (width        != null) this.width        = width;
    if (onchange     != null) this.onchange     = onchange;
    if (post         != null) this.post         = post;
    if (typeahead    != null) this.typeahead    = typeahead;
    if (matchtype    != null) this.matchtype    = matchtype;
    if (label    != null) this.label    = label;

    this.alarming = false;
    this.dirty    = false;
  }

  static SelectModel? fromXml(WidgetModel parent, XmlElement xml) {
    SelectModel? model;
    try
    {
      model = SelectModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'select.Model');
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

    // set properties
    value = Xml.get(node: xml, tag: 'value');
    hint = Xml.get(node: xml, tag: 'hint');
    border = Xml.get(node: xml, tag: 'border');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
    inputenabled = Xml.get(node: xml, tag: 'inputenabled');
    typeahead = Xml.get(node: xml, tag: 'typeahead');
    matchtype = Xml.get(node: xml, tag: 'matchtype') ?? Xml.get(node: xml, tag: 'searchtype');

    String? empty = Xml.get(node: xml, tag: 'addempty');
    if (S.isBool(empty)) addempty = S.toBool(empty);

    // Build options
    this.options.clear();
    List<OptionModel> options = findChildrenOfExactType(OptionModel).cast<OptionModel>();

      // set prototype
      if ((!S.isNullOrEmpty(datasource)) && (options.isNotEmpty))
      {
        prototype = S.toPrototype(options[0].element.toString());
        options.removeAt(0);
      }
      // build options
      options.forEach((option) => this.options.add(option));


    // Set selected option
    setData();
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource? source, Data? list) async
  {
    try
    {
      if (prototype == null) return true;

      options.clear();

      int i = 0;
      if (addempty == true)
      {
        options.add(OptionModel(this, "${this.id}-$i", value: ''));
        i = i + 1;
      }

      // build options
      if ((list != null) && (source != null))
      {
        // build options
        list.forEach((row)
        {
          XmlElement? prototype = S.fromPrototype(this.prototype, "${this.id}-$i");
          i = i + 1;
          var model = OptionModel.fromXml(this, prototype, data: row);
          if (model != null) options.add(model);
        });
      }

      // Set value to first option or null if the current value is not in option list
      if (!containsOption()) value = options.isNotEmpty ? options[0].value : null;

      // sets the data
      setData();

      // notify listeners
      notifyListeners('options', options);
    }
    catch(e)
    {
      DialogService().show(
          type: DialogType.error,
          title: phrase.error,
          description: e.toString());
    }
    return true;
  }

  @override
  onDataSourceException(IDataSource source, Exception exception)
  {
    // Clear the List - Olajos 2021-09-04
    onDataSourceSuccess(null,null);
  }

  void setData()
  {
    dynamic data;
      options.forEach((option)
      {
        if (option.value == value)
          {
            data = option.data;
            this.label = option.labelValue;
          }
      });
    this.data = data;
  }

  bool containsOption()
  {
    bool contains = false;
      options.forEach((option)
      {
        if (option.value == value) contains = true;
      });
    return contains;
  }

  @override
  dispose() {
Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => SelectView(this);
}