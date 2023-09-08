// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableRowCellModel extends BoxModel
{
  // row
  TableRowModel? get row => parent is TableRowModel ? parent as TableRowModel : null;

  // cell is dynamic?
  bool isDynamic() => (element?.toString().contains("{field}") ?? false) && (row?.table?.hasDataSource ?? false);

  @override
  double? get paddingTop => super.paddingTop ?? row?.paddingTop;

  @override
  double? get paddingRight => super.paddingRight ?? row?.paddingRight;

  @override
  double? get paddingBottom => super.paddingBottom ?? row?.paddingBottom;

  @override
  double? get paddingLeft => super.paddingLeft ?? row?.paddingLeft;

  @override
  String? get halign => super.halign ?? row?.halign;

  @override
  String? get valign => super.valign ?? row?.valign;

  // Position in Row
  int? get index
  {
    if ((parent != null) && (parent is TableRowModel))
    {
      return (parent as TableRowModel).cells.indexOf(this);
    }
    return null;
  }

  // value - used to sort
  StringObservable? _value;
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else if (v != null)
    {
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope);
    }
  }
  String? get value => _value?.get();

  // selected
  BooleanObservable? _selected;
  set selected(dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get selected => _selected?.get() ?? false;


  TableRowCellModel(WidgetModel parent, String? id) : super(parent, id);

  static TableRowCellModel? fromXml(WidgetModel parent, XmlElement xml) {
    TableRowCellModel? model;
    try
    {
      model = TableRowCellModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'column.Model');
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
    value = Xml.get(node: xml, tag: 'value');
    if (_value == null)
    {
      var txt = findChildOfExactType(TextModel);
      if (txt is TextModel) value = txt.value;
    }
  }

  void onSelect() => row?.onSelect(this);

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }
}
