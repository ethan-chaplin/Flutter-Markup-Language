// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/grid/grid_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class GridItemModel extends DecoratedWidgetModel
{
  Map? map;

  String? type;

// indicates if this item has been selected
  BooleanObservable? _selected;
  set selected (dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v, scope: scope);
    }
  }
  bool? get selected =>  _selected?.get();

  // indicates that this item can be selected
  // by clicking it
  BooleanObservable? _selectable;
  set selectable (dynamic v)
  {
    if (_selectable != null)
    {
      _selectable!.set(v);
    }
    else if (v != null)
    {
      _selectable = BooleanObservable(Binding.toKey(id, 'selectable'), v, scope: scope);
    }
  }
  bool get selectable =>  _selectable?.get() ?? true;

  ///////////
  /* dirty */
  ///////////
  BooleanObservable? _dirty;
  BooleanObservable? get dirtyObservable  => _dirty;
  set dirty (dynamic v)
  {
    if (_dirty != null)
    {
      _dirty!.set(v);
    }
    else if (v != null)
    {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }
  bool get dirty => _dirty?.get() ?? false;

  GridItemModel(WidgetModel parent, String?  id, {dynamic data, this.type, dynamic backgroundcolor}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    this.data = data;
  }

  static GridItemModel? fromXml(WidgetModel parent, XmlElement? xml, {dynamic data})
  {
    GridItemModel? model;
    try
    {
      // build model
      model = GridItemModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'grid.item.Model');
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

    // properties
    type       = Xml.get(node: xml, tag: 'type');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }

  Future<bool> onTap() async
  {
    if (parent is GridModel)
    {
      (parent as GridModel).onTap(this);
    }
    return true;
  }
}