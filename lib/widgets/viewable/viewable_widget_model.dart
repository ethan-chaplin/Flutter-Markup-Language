// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/scope/scope_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/constraints/constraint_model.dart';
import 'package:fml/widgets/variable/variable_model.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:collection/collection.dart';

class ViewableWidgetModel extends ConstraintModel
{
  // model holding the tooltip
  TooltipModel? tipModel;

  // holds animations
  List<AnimationModel>? animations;

  // data sourced prototype
  XmlElement? prototype;

  // viewable children
  List<ViewableWidgetModel> get viewableChildren
  {
    List<ViewableWidgetModel> list = [];
    if (children != null){
    for (var child in children!) {
      if (child is ViewableWidgetModel) list.add(child);
    }}
    return list;
  }

  // the flex width
  int? get flexWidth
  {
    // defined width takes precedence over flex
    if (hasBoundedWidth) return null;
    if (!visible) return null;
    return flex ?? (expandHorizontally || canExpandInfinitelyWide ? 1 : null);
  }

  // the flex height
  int? flexHeight()
  {
    // defined height takes precedence over flex
    if (hasBoundedHeight) return null;
    if (!visible) return null;
    return flex ?? (expandVertically || canExpandInfinitelyHigh ? 1 : null);
  }

  // view width
  double? _viewWidth;
  DoubleObservable? _viewWidthObservable;
  set viewWidth(double? v)
  {
    // important this gets before the observable
    _viewWidth = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewWidthObservable != null) _viewWidthObservable!.set(v);
  }
  double? get viewWidth => _viewWidth;

  // view height
  double? _viewHeight;
  DoubleObservable? _viewHeightObservable;
  set viewHeight(double? v)
  {
    // important this gets before the observable
    _viewHeight = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewHeightObservable != null) _viewHeightObservable!.set(v);
  }
  double? get viewHeight => _viewHeight;

  // view global X position
  double? _viewX;
  DoubleObservable? _viewXObservable;
  set viewX(double? v)
  {
    // important this gets before the observable
    _viewX = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewXObservable != null) _viewXObservable!.set(v);
  }
  double? get viewX => _viewX;

  // view global Y position
  double? _viewY;
  DoubleObservable? _viewYObservable;
  set viewY(double? v)
  {
    // important this gets before the observable
    _viewY = v;

    // we handle this slightly different for performance reasons
    // The observable is only created in deserialize if its bound
    if (_viewYObservable != null) _viewYObservable!.set(v);
  }
  double? get viewY => _viewY;

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  set halign(dynamic v)
  {
    if (_halign != null)
    {
      _halign!.set(v);
    }
    else if (v != null)
    {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get halign => _halign?.get();

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  set valign(dynamic v)
  {
    if (_valign != null)
    {
      _valign!.set(v);
    }
    else if (v != null)
    {
      _valign = StringObservable(Binding.toKey(id, 'valign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get valign => _valign?.get();

  // used by the view to determine if it needs to wrap itself
  // in a VisibilityDetector
  bool? _addVisibilityDetector;
  bool get needsVisibilityDetector => _addVisibilityDetector ?? false;

  /// onscreen event string - fires when object is 100 on screen
  StringObservable? _onscreen;
  set onscreen(dynamic v) 
  {
    if (_onscreen != null) 
    {
      _onscreen!.set(v);
    }
    else if (v != null)
    {
      _onscreen = StringObservable(Binding.toKey(id, 'onscreen'), v, scope: scope);

      // create the visibility tag
      visibleArea   = 0;
      visibleHeight = 0;
      visibleWidth  = 0;
    }
  }
  String? get onscreen => _onscreen?.get();

  /// offscreen event string - fires when object is 100 on screen
  StringObservable? _offscreen;
  set offscreen(dynamic v) 
  {
    if (_offscreen != null) 
    {
      _offscreen!.set(v);
    } 
    else if (v != null) 
    {
      _offscreen = StringObservable(Binding.toKey(id, 'offscreen'), v, scope: scope);

      // create the visibility tag
      visibleArea   = 0;
      visibleHeight = 0;
      visibleWidth  = 0;
    }
  }
  String? get offscreen => _offscreen?.get();

  /// visible area - percent of object visible on screen
  DoubleObservable? _visibleArea;
  set visibleArea(dynamic v) 
  {
    if (_visibleArea != null) 
    {
      _visibleArea!.set(v);
    } 
    else if (v != null) 
    {
      _visibleArea = DoubleObservable(Binding.toKey(id, 'visiblearea'), v, scope: scope);
    }
  }
  double? get visibleArea => _visibleArea?.get();

  /// visible Height - percent of objects height visible on screen
  DoubleObservable? _visibleHeight;
  set visibleHeight(dynamic v)
  {
    if (_visibleHeight != null)
    {
      _visibleHeight!.set(v);
    }
    else if (v != null)
    {
      _visibleHeight = DoubleObservable(Binding.toKey(id, 'visibleheight'), v, scope: scope);
    }
  }
  double? get visibleHeight => _visibleHeight?.get();

  /// visible Width - percent of objects width visible on screen
  DoubleObservable? _visibleWidth;
  set visibleWidth(dynamic v)
  {
    if (_visibleWidth != null)
    {
      _visibleWidth!.set(v);
    }
    else if (v != null)
    {
      _visibleWidth = DoubleObservable(Binding.toKey(id, 'visiblewidth'), v, scope: scope);
    }
  }
  double? get visibleWidth => _visibleWidth?.get();

  set margins(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');

      // all
      if (s.length == 1)
      {
        marginTop=s[0];
        marginRight=s[0];
        marginBottom=s[0];
        marginLeft=s[0];
      }

      // top/bottom
      else if (s.length == 2)
      {
        marginTop=s[0];
        marginRight=s[1];
        marginBottom=s[0];
        marginLeft=s[1];
      }

      // top/bottom
      else if (s.length == 3)
      {
        marginTop=s[0];
        marginRight=s[1];
        marginBottom=s[2];
        marginLeft=s[1];
      }

      // top/bottom
      else if (s.length > 3)
      {
        marginTop=s[0];
        marginRight=s[1];
        marginBottom=s[2];
        marginLeft=s[3];
      }
    }
  }

  // margins top
  DoubleObservable? _marginTop;
  set marginTop(dynamic v)
  {
    if (_marginTop != null) {
      _marginTop!.set(v);
    } else if (v != null) {
      _marginTop = DoubleObservable(Binding.toKey(id, 'margintop'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginTop => _marginTop?.get();

  // margins right
  DoubleObservable? _marginRight;
  set marginRight(dynamic v)
  {
    if (_marginRight != null) {
      _marginRight!.set(v);
    } else if (v != null) {
      _marginRight = DoubleObservable(Binding.toKey(id, 'marginright'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginRight => _marginRight?.get();

  // margins bottom
  DoubleObservable? _marginBottom;
  set marginBottom(dynamic v)
  {
    if (_marginBottom != null) {
      _marginBottom!.set(v);
    } else if (v != null) {
      _marginBottom = DoubleObservable(Binding.toKey(id, 'marginbottom'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginBottom => _marginBottom?.get();

  // margins left
  DoubleObservable? _marginLeft;
  set marginLeft(dynamic v)
  {
    if (_marginLeft != null) {
      _marginLeft!.set(v);
    } else if (v != null) {
      _marginLeft = DoubleObservable(Binding.toKey(id, 'marginleft'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get marginLeft => _marginLeft?.get();

  set padding(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');

      // all
      if (s.length == 1)
      {
        paddingTop=s[0];
        paddingRight=s[0];
        paddingBottom=s[0];
        paddingLeft=s[0];
      }

      // top/bottom
      else if (s.length == 2)
      {
        paddingTop=s[0];
        paddingRight=s[1];
        paddingBottom=s[0];
        paddingLeft=s[1];
      }

      // top/bottom
      else if (s.length == 3)
      {
        paddingTop=s[0];
        paddingRight=s[1];
        paddingBottom=s[2];
        paddingLeft=s[1];
      }

      // top/bottom
      else if (s.length > 3)
      {
        paddingTop=s[0];
        paddingRight=s[1];
        paddingBottom=s[2];
        paddingLeft=s[3];
      }
    }
  }

  // paddings top
  DoubleObservable? _paddingTop;
  set paddingTop(dynamic v)
  {
    if (_paddingTop != null) {
      _paddingTop!.set(v);
    } else if (v != null) {
      _paddingTop = DoubleObservable(Binding.toKey(id, 'paddingtop'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingTop => _paddingTop?.get();

  // paddings right
  DoubleObservable? _paddingRight;
  set paddingRight(dynamic v)
  {
    if (_paddingRight != null) {
      _paddingRight!.set(v);
    } else if (v != null) {
      _paddingRight = DoubleObservable(Binding.toKey(id, 'paddingright'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingRight => _paddingRight?.get();

  // paddings bottom
  DoubleObservable? _paddingBottom;
  set paddingBottom(dynamic v)
  {
    if (_paddingBottom != null) {
      _paddingBottom!.set(v);
    } else if (v != null) {
      _paddingBottom = DoubleObservable(Binding.toKey(id, 'paddingbottom'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingBottom => _paddingBottom?.get();

  // paddings left
  DoubleObservable? _paddingLeft;
  set paddingLeft(dynamic v)
  {
    if (_paddingLeft != null) {
      _paddingLeft!.set(v);
    } else if (v != null) {
      _paddingLeft = DoubleObservable(Binding.toKey(id, 'paddingleft'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingLeft => _paddingLeft?.get();

  // visible
  BooleanObservable? _visible;
  set visible(dynamic v) {
    if (_visible != null) {
      _visible!.set(v);
    } else if (v != null) {
      _visible = BooleanObservable(Binding.toKey(id, 'visible'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get visible => _visible?.get() ?? true;

  // enabled
  BooleanObservable? _enabled;

  set enabled(dynamic v) {
    if (_enabled != null) {
      _enabled!.set(v);
    } else if (v != null) {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get enabled => _enabled?.get() ?? true;

  ViewableWidgetModel(WidgetModel? parent, String? id, {Scope? scope}) : super(parent, id, scope: scope);

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // build prototype (options) if defined
    setPrototype();

    // set constraints
    width     = Xml.get(node: xml, tag: 'width');
    height    = Xml.get(node: xml, tag: 'height');
    minWidth  = Xml.get(node: xml, tag: 'minwidth');
    maxWidth  = Xml.get(node: xml, tag: 'maxwidth');
    minHeight = Xml.get(node: xml, tag: 'minheight');
    maxHeight = Xml.get(node: xml, tag: 'maxheight');

    // properties
    visible   = Xml.get(node: xml, tag: 'visible');
    enabled   = Xml.get(node: xml, tag: 'enabled');
    halign    = Xml.get(node: xml, tag: 'halign');
    valign    = Xml.get(node: xml, tag: 'valign');
    flex      = Xml.get(node: xml, tag: 'flex');
    flexfit   = Xml.get(node: xml, tag: 'flexfit');
    onscreen  = Xml.get(node: xml, tag: 'onscreen');
    offscreen = Xml.get(node: xml, tag: 'offscreen');
    var tooltip = Xml.attribute(node: xml, tag: 'tip') ?? Xml.attribute(node: xml, tag: 'tootip');

    // view sizing and position
    // these are treated differently for efficiency reasons
    // we only create the observable if its bound to in the template
    // otherwise we just store the value in a simple double variable
    String? key;
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewwidth')))  _viewWidthObservable  = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewheight'))) _viewHeightObservable = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewx')))      _viewXObservable      = DoubleObservable(key, null, scope: scope);
    if (WidgetModel.isBound(this, key = Binding.toKey(id, 'viewy')))      _viewYObservable      = DoubleObservable(key, null, scope: scope);
    
    // view requires a VisibilityDetector if either onstage or offstage is set or
    // someone is bound to my visibility
    _addVisibilityDetector = visible && (!S.isNullOrEmpty(onscreen) || !S.isNullOrEmpty(offscreen) || WidgetModel.isBound(this, Binding.toKey(id, 'visiblearea')) || WidgetModel.isBound(this, Binding.toKey(id, 'visibleheight')) || WidgetModel.isBound(this, Binding.toKey(id, 'visiblewidth')));

    // set margins. Can be comma separated top,left,bottom,right
    // space around the widget
    var margins = Xml.attribute(node: xml, tag: 'margin') ?? Xml.attribute(node: xml, tag: 'margins');
    this.margins = margins;

    // set padding. Can be comma separated top,left,bottom,right
    // space around the widget's children
    var padding = Xml.attribute(node: xml, tag: 'pad') ?? Xml.attribute(node: xml, tag: 'padding') ?? Xml.attribute(node: xml, tag: 'padd');
    this.padding = padding;

    // tooltip
    List<TooltipModel> tips = findChildrenOfExactType(TooltipModel).cast<TooltipModel>();
    if (tips.isNotEmpty)
    {
      tipModel = tips.first;
      removeChildrenOfExactType(TooltipModel);
    }
    else if (tooltip != null)
    {
      // build tooltip
      XmlElement eTip  = XmlElement(XmlName("TOOLTIP"));

      // build text
      tooltip = tooltip.replaceAll("{this.id}", id);
      XmlElement eText = XmlElement(XmlName("TEXT"));
      eText.attributes.add(XmlAttribute(XmlName("value"), tooltip));
      eTip.children.add(eText);

      var model = WidgetModel.fromXml(this, eTip);
      tipModel = (model is TooltipModel) ? model : null;
    }

    // add animations
    children?.forEach((child)
    {
      if (child is AnimationModel)
      {
        animations ??= [];
        animations!.add(child);
      }
    });

    // remove animations from child list
    if (animations != null) children?.removeWhere((element) => animations!.contains(element));
  }

  AnimationModel? getAnimationModel(String id)
  {
    if (animations == null) return null;
    var models = animations!.where((model) => model.id == id);
    return (models.isNotEmpty) ? models.first : null;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "animate":
        if (animations != null)
        {
          var id = S.item(arguments, 0);
          AnimationModel? animation;
          if (!S.isNullOrEmpty(id))
          {
            var list = animations!.where((animation) => animation.id == id);
            if (list.isNotEmpty) animation = list.first;
          }
          else {
            animation = animations!.first;
          }
          animation?.execute(caller, propertyOrFunction, arguments);
        }
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  // set visibility
  double oldVisibility = 0;
  bool hasGoneOffscreen = false;
  bool hasGoneOnscreen = false;

  void onVisibilityChanged(VisibilityInfo info)
  {
    if (oldVisibility == (info.visibleFraction * 100)) return;

    visibleHeight = info.size.height > 0 ? ((info.visibleBounds.height / info.size.height) * 100) : 0.0;
    visibleWidth  = info.size.width  > 0 ? ((info.visibleBounds.width  / info.size.width)  * 100) : 0.0;
    visibleArea   = info.visibleFraction * 100;

    oldVisibility = visibleArea ?? 0.0;

    if (visibleArea! > 1 && !hasGoneOnscreen)
    {
      if (!S.isNullOrEmpty(_onscreen)) EventHandler(this).execute(_onscreen);
      hasGoneOnscreen = true;
    }
    else if (visibleArea! == 0 && hasGoneOnscreen)
    {
      if (!S.isNullOrEmpty(_offscreen)) EventHandler(this).execute(_offscreen);
      hasGoneOnscreen = false;
    }
  }

  @override
  void dispose()
  {
    // dispose of tip model
    tipModel?.dispose();

    // dispose of animations
    animations?.forEach((animation) => animation.dispose());
    super.dispose();
  }

  Widget getReactiveView(Widget view)
  {
    // wrap in visibility detector?
    if (needsVisibilityDetector) view = VisibilityDetector(key: ObjectKey(this), onVisibilityChanged: onVisibilityChanged, child: view);

    // wrap in tooltip?
    if (tipModel != null) view = TooltipView(tipModel!, view);

    // wrap animations.
    if (animations != null)
    {
      var animations = this.animations!.reversed;
      for (var model in animations) {
        view = model.getAnimatedView(view);
      }
    }
    return view;
  }

  /// this routine creates views for all
  /// of its children
  List<Widget> inflate()
  {
    // process children
    List<Widget> views = [];
    for (var model in viewableChildren) {
      if (model is! ModalModel)
    {
      var view = model.getView();
      if (view != null) views.add(view);
    }
    }
    return views;
  }

  void layoutComplete(Size size, Offset offset)
  {
    // set the view width, height and position
    if (size.width != viewWidth || size.height != viewHeight || offset.dx != viewX || offset.dy != viewY)
    {
      viewWidth  = size.width;
      viewHeight = size.height;
      viewX      = offset.dx;
      viewY      = offset.dy;
    }
  }

  // sets the prototype node
  // several widgets override this method in order to
  // build their own prototypes
  void setPrototype()
  {
    // if the node has a datasource and a single
    // element its considered a prototype
    if (S.isNullOrEmpty(datasource)) return;
    if (children?.length != 1) return;

    // create scope widget with single child
    var e = XmlElement(XmlName("SCOPE"));
    var c = children!.first.element?.copy();
    if (c != null) e.children.add(c);

    prototype = WidgetModel.prototypeOf(e);

    children!.clear();
    children = null;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    if (prototype == null || source.id != datasource) return super.onDataSourceSuccess(source, list);

    // set busy
    busy = true;

    // build chidlren from datasource
    List<WidgetModel> models = [];
    if (list != null)
    {
      int index = 0;
      for (var data in list)
      {
        var model = children?.firstWhereOrNull((child)
        {
          if (child.data == data) return true;
          if (child.data is List && (child.data as List).isNotEmpty && (child.data as List).first == data) return true;
          return false;
        });

        if (model == null)
        {
          // add variable for index
          var prototype = this.prototype!.copy();

          // add index variable
          var variable = XmlElement(XmlName("VAR"));
          variable.attributes.add(XmlAttribute(XmlName("id"), "index"));
          variable.attributes.add(XmlAttribute(XmlName("value"), index.toString()));
          prototype.children.insert(0, variable);

          // build the model
          model = ScopeModel.fromXml(this, prototype, data: data);
          if (model != null)
          {
            models.add(model);
          }
        }
        else
        {
          // set the index
          VariableModel? variable = model.findChildOfExactType(VariableModel,id: "index");
          if (variable != null)
          {
            variable.value = index;
          }
          models.add(model);
        }

        index++;
      }
    }

    // dispose of unused children
    children ??= [];
    for (var child in children!)
    {
      if (!models.contains(child))
      {
        child.dispose();
      }
    }
    children!.clear();
    children!.addAll(models);

    // rebuild form fields
    // this could be done differently
    var form = findAncestorOfExactType(FormModel);
    if (form is FormModel)
    {
      form.setFormFields();
    }

    // notify listeners
    notifyListeners("list", children);

    // clear busy
    busy = false;

    return true;
  }

  Widget? getView() => throw("getView() Not Implemented");
}


