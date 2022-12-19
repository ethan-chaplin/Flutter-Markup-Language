// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/widgets/drawer/item/drawer_item_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class DrawerModel extends DecoratedWidgetModel implements IViewableWidget
{
  //////////
  /* Side */
  //////////
  StringObservable? _side;
  set side (dynamic v)
  {
    if (_side != null)
    {
      _side!.set(v);
    }
    else if (v != null)
    {
      _side = StringObservable(Binding.toKey(id, 'side'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get side => _side?.get();

  //////////////////
  /* Curved Edges */
  //////////////////
  BooleanObservable? _rounded;
  set rounded (dynamic v)
  {
    if (_rounded != null)
    {
      _rounded!.set(v);
    }
    else if (v != null)
    {
      _rounded = BooleanObservable(Binding.toKey(id, 'rounded'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get rounded => _rounded?.get() ?? false;

  //////////////////
  /* Edge Handles */
  //////////////////
  BooleanObservable? _handle;
  set handle (dynamic v)
  {
    if (_handle != null)
    {
      _handle!.set(v);
    }
    else if (v != null)
    {
      _handle = BooleanObservable(Binding.toKey(id, 'handle'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get handle => _handle?.get() ?? false;

  DrawerItemModel? top;
  DrawerItemModel? bottom;
  DrawerItemModel? left;
  DrawerItemModel? right;
  bool? handleLeft;
  bool? handleRight;
  bool? handleTop;
  bool? handleBottom;
  double? sizeLeft;
  double? sizeRight;
  double? sizeTop;
  double? sizeBottom;
  String? idLeft;
  String? idRight;
  String? idTop;
  String? idBottom;

  DrawerModel(WidgetModel parent, String? id, {
    dynamic side,
    dynamic rounded,
    dynamic handle,
    dynamic handleLeft,
    dynamic handleRight,
    dynamic handleTop,
    dynamic handleBottom,
    dynamic sizeLeft,
    dynamic sizeRight,
    dynamic sizeTop,
    dynamic sizeBottom,
    dynamic idLeft,
    dynamic idRight,
    dynamic idTop,
    dynamic idBottom,
  }) : super(parent, id) {
    this.side = side;
    this.rounded = rounded;
    this.handle = handle;
    this.handleLeft = handleLeft;
    this.handleRight = handleRight;
    this.handleTop = handleTop;
    this.handleBottom = handleBottom;
    this.sizeLeft = sizeLeft;
    this.sizeRight = sizeRight;
    this.sizeTop = sizeTop;
    this.sizeBottom = sizeBottom;
    this.idLeft = idLeft;
    this.idRight = idRight;
    this.idTop = idTop;
    this.idBottom = idBottom;
  }

  // I built this to replace fromXml so that we can take in multiple <DRAWER> elements
  // and consolidate them into a single DRAWER.Model that handles them all (important)
  static DrawerModel? fromXmlList(WidgetModel parent, List<XmlElement> elements)
  {
    DrawerModel? model;
    try
    {
      bool handleLeft = false;
      bool handleRight = false;
      bool handleTop = false;
      bool handleBottom = false;
      double? sizeLeft;
      double? sizeRight;
      double? sizeTop;
      double? sizeBottom;
      String? idLeft;
      String? idRight;
      String? idTop;
      String? idBottom;

      XmlElement xml = XmlElement(XmlName.fromString('DRAWER')); // create a single drawer element
      elements.forEach((e)
      {
        XmlElement x = e.copy();
        String? side = x.getAttribute('side') ?? null; // determine side from each drawer in template
        String? size = x.getAttribute('size') ?? null;
        String? id   = x.getAttribute('id') ?? null;
        bool? handle = S.toBool(x.getAttribute('handle'));
        if (!S.isNullOrEmpty(side))
        {
          XmlElement drawer = XmlElement(XmlName(side?.toUpperCase() ?? 'left'.toUpperCase())); // create a sidedrawer from template

            drawer.attributes.add(XmlAttribute(XmlName.fromString('id'), id!));

            // Assign ids
            if (side == 'left')
            {
              idLeft = id;
              if (handle == true) handleLeft = true;
            }
            else if (side == 'right')
            {
              idRight = id;
              if (handle == true) handleRight = true;
            }
            else if (side == 'top')
            {
              idTop = id;
              if (handle == true) handleTop = true;
            }
            else if (side == 'bottom')
            {
              idBottom = id;
              if (handle == true) handleBottom = true;
            }

            // Assign sides
            if (!S.isNullOrEmpty(size))
            {
              drawer.attributes.add(XmlAttribute(XmlName.fromString('size'), size!));
                   if (side == 'left')   sizeLeft = S.toDouble(size);
              else if (side == 'right')  sizeRight = S.toDouble(size);
              else if (side == 'top')    sizeTop = S.toDouble(size);
              else if (side == 'bottom') sizeBottom = S.toDouble(size);
            }


          List<XmlElement> nodes = [];
          x.children.forEach((node)
          {
            if (node.nodeType == XmlNodeType.ELEMENT) nodes.add(node.copy() as XmlElement);
          });

          drawer.children.addAll(nodes);
          xml.children.add(drawer);
        }
        else
        {
          Log().error('Unable to parse a drawer attributes', caller: 'drawer.Model => Model.fromXmlList()');
        }
      });

      // Create View Model
      model = DrawerModel(parent, Xml.get(node: xml, tag: 'id'), handleLeft: handleLeft, handleRight: handleRight, handleTop: handleTop, handleBottom: handleBottom, sizeLeft: sizeLeft, sizeRight: sizeRight, sizeTop: sizeTop, sizeBottom: sizeBottom, idLeft: idLeft, idRight: idRight, idTop: idTop, idBottom: idBottom);

      // Deserialize
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().error('Unable to parse a drawer element', caller: 'drawer.Model => Model.fromXmlList()');
      Log().exception(e,  caller: 'drawer.Model');
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

    ///////////////////
    /* Build Drawers */
    ///////////////////
    // This grabs the deserializes xml generated from fromXmlList()
    element = Xml.getChildElement(node: xml, tag: "TOP");
    if (element != null) top = DrawerItemModel.fromXml(this, element, DrawerPositions.top);

    element = Xml.getChildElement(node: xml, tag: "BOTTOM");
    if (element != null) bottom = DrawerItemModel.fromXml(this, element, DrawerPositions.bottom);

    element = Xml.getChildElement(node: xml, tag: "LEFT");
    if (element != null) left = DrawerItemModel.fromXml(this, element, DrawerPositions.left);

    element = Xml.getChildElement(node: xml, tag: "RIGHT");
    if (element != null) right = DrawerItemModel.fromXml(this, element, DrawerPositions.right);

    // properties
    this.side    = Xml.get(node: xml, tag: 'side');
    this.rounded = Xml.get(node: xml, tag: 'rounded');
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  bool drawerExists(String drawer) {
    if (drawer == 'top') {
      return top != null;
    }
    else if (drawer == 'bottom') {
      return bottom != null;
    }
    else if (drawer == 'left') {
      return left != null;
    }
    else if (drawer == 'right') {
      return right != null;
    }
    else {
      Log().warning('No matching drawer type of: $drawer', caller: 'Drawer.model -> drawerExists(String drawer)');
     return false;
    }
  }

  Widget getView({Key? key}) => DrawerView(this, Container());
}