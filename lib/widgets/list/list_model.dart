// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart'            ;
import 'package:fml/widgets/list/list_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'     ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class ListModel extends DecoratedWidgetModel implements IViewableWidget, IForm, IScrolling
{
  final HashMap<int,ListItemModel> items = HashMap<int,ListItemModel>();
  bool   selectable = false;

  // prototype
  String? prototype;

  BooleanObservable? _scrollShadows;
  set scrollShadows (dynamic v)
  {
    if (_scrollShadows != null)
    {
      _scrollShadows!.set(v);
    }
    else if (v != null)
    {
      _scrollShadows = BooleanObservable(Binding.toKey(id, 'scrollshadows'), v, scope: scope);
    }
  }
  bool get scrollShadows => _scrollShadows?.get() ?? false;


  BooleanObservable? _scrollButtons;
  set scrollButtons (dynamic v)
  {
    if (_scrollButtons != null)
    {
      _scrollButtons!.set(v);
    }
    else if (v != null)
    {
      _scrollButtons = BooleanObservable(Binding.toKey(id, 'scrollbuttons'), v, scope: scope);
    }
  }
  bool get scrollButtons => _scrollButtons?.get() ?? false;


  ///////////
  /* moreup */
  ///////////
  BooleanObservable? _moreUp;
  set moreUp (dynamic v)
  {
    if (_moreUp != null)
    {
      _moreUp!.set(v);
    }
    else if (v != null)
    {
      _moreUp = BooleanObservable(Binding.toKey(id, 'moreup'), v, scope: scope);
    }
  }
  bool? get moreUp => _moreUp?.get();

  ///////////
  /* moreDown */
  ///////////
  BooleanObservable? _moreDown;
  set moreDown (dynamic v)
  {
    if (_moreDown != null)
    {
      _moreDown!.set(v);
    }
    else if (v != null)
    {
      _moreDown = BooleanObservable(Binding.toKey(id, 'moredown'), v, scope: scope);
    }
  }
  bool? get moreDown => _moreDown?.get();

  ///////////
  /* moreLeft */
  ///////////
  BooleanObservable? _moreLeft;
  set moreLeft (dynamic v)
  {
    if (_moreLeft != null)
    {
      _moreLeft!.set(v);
    }
    else if (v != null)
    {
      _moreLeft = BooleanObservable(Binding.toKey(id, 'moreleft'), v, scope: scope);
    }
  }
  bool? get moreLeft => _moreLeft?.get();

  ///////////
  /* moreRight */
  ///////////
  BooleanObservable? _moreRight;
  set moreRight (dynamic v)
  {
    if (_moreRight != null)
    {
      _moreRight!.set(v);
    }
    else if (v != null)
    {
      _moreRight = BooleanObservable(Binding.toKey(id, 'moreright'), v, scope: scope);
    }
  }
  bool? get moreRight => _moreRight?.get();


  ///////////
  /* dirty */
  ///////////
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
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

  void onDirtyListener(Observable property)
  {
    bool isDirty = false;
      for (var entry in items.entries)
      {
        if ((entry.value.dirty == true))
        {
          isDirty = true;
          break;
        }
      }
    dirty = isDirty;
  }

  ///////////
  /* Clean */
  ///////////
  set clean (bool b)
  {
    dirty = false;
      items.forEach((index, item) => item.dirty = false);
  }

  /////////////////
  /* onccomplete */
  /////////////////
  StringObservable? _oncomplete;
  set oncomplete (dynamic v)
  {
    if (_oncomplete != null)
    {
      _oncomplete!.set(v);
    }
    else if (v != null)
    {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v, scope: scope, lazyEval: true);
    }
  }
  String? get oncomplete => _oncomplete?.get();

  ///////////////
  /* Direction */
  ///////////////
  StringObservable? _direction;
  set direction (dynamic v)
  {
    if (_direction != null)
    {
      _direction!.set(v);
    }
    else if (v != null)
    {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get direction => _direction?.get();

  BooleanObservable? _collapsed;
  set collapsed (dynamic v)
  {
    if (_collapsed != null)
    {
      _collapsed!.set(v);
    }
    else if (v != null)
    {
      _collapsed = BooleanObservable(Binding.toKey(id, 'collapsed'), v, scope: scope);
    }
  }
  bool get collapsed => _collapsed?.get() ?? false;

  ListModel(WidgetModel? parent, String? id, {dynamic direction, dynamic scrollShadows}) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    this.direction = direction;
    this.scrollShadows = scrollShadows;
    this.scrollButtons = scrollButtons;
    this.collapsed = collapsed;
    moreUp = false;
    moreDown = false;
    moreLeft = false;
    moreRight = false;
  }

  static ListModel? fromXml(WidgetModel? parent, XmlElement xml)
  {
    ListModel? model;
    try
    {
      model = ListModel(parent, Xml.get(node: xml, tag: 'id'));


      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'list.Model');
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
    direction  = Xml.get(node: xml, tag: 'direction');
    scrollShadows = Xml.get(node: xml, tag: 'scrollshadows');
    scrollButtons = Xml.get(node: xml, tag: 'scrollbuttons');
    collapsed = Xml.get(node: xml, tag: 'collapsed');

    // Process Items
    this.items.clear();
    int i = 0;
    List<ListItemModel> items = findChildrenOfExactType(ListItemModel).cast<ListItemModel>();

      // set prototype
      if ((!S.isNullOrEmpty(datasource)) && (items.isNotEmpty))
      {
        prototype = S.toPrototype(items[0].element.toString());
        items.removeAt(0);
      }
      // build items
      items.forEach((item) => this.items[i++] = item);

  }

  ListItemModel? getItemModel(int index)
  {
    // fixed list?
    if (S.isNullOrEmpty(datasource)) return (index < items.length) ? items[index] : null;

    // item model exists?
    if (data == null) return null;
    if ((data.length < (index + 1))) return null;
    if ((items.containsKey(index))) return items[index];
    if ((index < 0) || (data.length < index)) return null;

    // build prototype
    XmlElement? prototype = S.fromPrototype(this.prototype, "${this.id}-$index");

    // build item model
    var model = ListItemModel.fromXml(this, prototype, data: data[index]);

    if (model != null)
    {
      // register listener to dirty field
      if (model.dirtyObservable != null) model.dirtyObservable!.registerListener(onDirtyListener);
      // save model
      items[index] = model;
    }

    return model;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = true;
    if (list != null)
    {
      clean = true;
      items.clear();
      data = list;
      notifyListeners('list', items);
    }
    busy = false;
    return true;
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> complete() async
  {
    busy = true;

    bool ok = true;

    ///////////////////
    /* Post the Form */
    ///////////////////
    if (dirty) for (var entry in items.entries) ok = await entry.value.complete();

    busy = false;
    return ok;
  }

  Future<bool> onComplete(BuildContext context) async
  {
    return await EventHandler(this).execute(_oncomplete);
  }

  Future<bool> save() async
  {
    // not implemented
    return true;
  }

  Widget getView({Key? key}) => ListLayoutView(this);
}