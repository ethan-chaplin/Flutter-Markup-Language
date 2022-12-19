// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class TriggerConditionModel extends WidgetModel
{
  //////////
  /* When */
  //////////
  StringObservable? _when;
  set when (dynamic v)
  {
    if (_when != null)
    {
      _when!.set(v);
    }
    else if (v != null)
    {
      _when = StringObservable(Binding.toKey(id, 'when'), v, scope: scope);
    }
  }
  String? get when
  {
    return _when?.get();
  }

  ///////////
  /* Call */
  ///////////
  StringObservable? get callObservable => _call;
  StringObservable? _call;
  set call (dynamic v)
  {
    if (_call != null)
    {
      _call!.set(v);
    }
    else if (v != null)
    {
      _call = StringObservable(Binding.toKey(id, 'call'), v, scope: scope);
    }
  }
  String? get call
  {
    return _call?.get();
  }

  TriggerConditionModel(WidgetModel parent, {String? id, dynamic when, dynamic call}) : super(parent, id)
  {
    this.when = when;
    this.call = call;
  }

  static TriggerConditionModel? fromXml(WidgetModel parent, XmlElement e, {String? when})
  {
    String? id = Xml.get(node: e, tag: 'id');

    if (S.isNullOrEmpty(id))
    {
      Log().warning('<TRIGGER> missing required id');
      id = Uuid().v4().toString();
    }

    TriggerConditionModel condition = TriggerConditionModel(
      parent,
      id : id,
      when : Xml.get(node: e, tag: 'when'),
      call : Xml.get(node: e, tag: 'call'),
    );

    return condition;
  }
}