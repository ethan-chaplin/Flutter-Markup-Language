// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/axis/chart_axis_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:xml/xml.dart';
import '../chart_model.dart';
import 'line_chart_view.dart';
import 'line_series.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class LineChartModel extends ChartPainterModel
{
  ChartAxisModel xaxis = ChartAxisModel(null, null, ChartAxis.X);
  ChartAxisModel yaxis = ChartAxisModel(null, null, ChartAxis.Y);
  num? yMax;
  num? yMin;
  Set<dynamic> uniqueValues = {};
  final List<LineChartSeriesModel> series = [];
  List<LineChartBarData> lineDataList = [];

  @override
  bool get canExpandInfinitelyWide
  {
    if (hasBoundedWidth) return false;
    return true;
  }

  @override
  bool get canExpandInfinitelyHigh
  {
    if (hasBoundedHeight) return false;
    return true;
  }

  LineChartModel(WidgetModel? parent, String? id,
      {
        dynamic type,
        dynamic showlegend,
        dynamic horizontal,
        dynamic animated,
        dynamic selected,
        dynamic legendsize,
      }) : super(parent, id) {
    this.selected         = selected;
    this.animated         = animated;
    this.horizontal       = horizontal;
    this.showlegend       = showlegend;
    this.legendsize       = legendsize;
    this.type             = type?.trim()?.toLowerCase();

    busy = false;
  }

  static LineChartModel? fromTemplate(WidgetModel parent, Template template)
  {
    LineChartModel? model;
    try
    {
      XmlElement? xml = Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      xml ??= template.document!.rootElement;
      model = LineChartModel.fromXml(parent, xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static LineChartModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    LineChartModel? model;
    try
    {
      model = LineChartModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    //* Deserialize */
    super.deserialize(xml);

    /////////////////
    //* Properties */
    /////////////////
    selected        = Xml.get(node: xml, tag: 'selected');
    animated        = Xml.get(node: xml, tag: 'animated');
    horizontal      = Xml.get(node: xml, tag: 'horizontal');
    showlegend      = Xml.get(node: xml, tag: 'showlegend');
    legendsize      = Xml.get(node: xml, tag: 'legendsize');
    type            = Xml.get(node: xml, tag: 'type');

    // Set Series
    this.series.clear();
    List<LineChartSeriesModel> series = findChildrenOfExactType(LineChartSeriesModel).cast<LineChartSeriesModel>();
    for (var model in series)
    {
      // add the series to the list
      this.series.add(model);

      // register listener to the datasource
      IDataSource? source = (scope != null) ? scope!.getDataSource(model.datasource) : null;
      if (source != null) source.register(this);
    }


    // Set Axis
    List<ChartAxisModel> axis = findChildrenOfExactType(ChartAxisModel).cast<ChartAxisModel>();
    for (var axis in axis) {
      if (axis.axis == ChartAxis.X) xaxis = axis;

      if (axis.axis == ChartAxis.Y) yaxis = axis;
      yMax = S.toInt(yaxis.max);
      yMin = S.toInt(yaxis.min);
    }
  }

  /// Contains the data map from the row (point) that is selected
  ListObservable? _selected;
  set selected(dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null, scope: scope, listener: onPropertyChange);
      _selected!.set(v);
    }
  }
  get selected => _selected?.get();

  setSelected(dynamic v)
  {
    if (_selected == null)
    {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null, scope: scope);
      _selected!.registerListener(onPropertyChange);
    }
    _selected?.set(v, notify:false);
  }

  /// If the chart should animate it's series
  BooleanObservable? _animated;
  set animated (dynamic v)
  {
    if (_animated != null)
    {
      _animated!.set(v);
    }
    else if (v != null)
    {
      _animated = BooleanObservable(Binding.toKey(id, 'animated'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get animated => _animated?.get() ?? false;

  /// If the chart should display horizontally
  BooleanObservable? _horizontal;
  set horizontal (dynamic v)
  {
    if (_horizontal != null)
    {
      _horizontal!.set(v);
    }
    else if (v != null)
    {
      _horizontal = BooleanObservable(Binding.toKey(id, 'horizontal'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get horizontal => _horizontal?.get() ?? false;

  /// If not false displays a legend of each [ChartSeriesModel] `id`, you can put top/bottom/left/right to signify a placement
  StringObservable? _showlegend;
  set showlegend (dynamic v)
  {
    if (_showlegend != null)
    {
      _showlegend!.set(v);
    }
    else if (v != null)
    {
      _showlegend = StringObservable(Binding.toKey(id, 'showlegend'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get showlegend => _showlegend?.get() ?? 'bottom';

  /// Sets the font size of the legend labels
  IntegerObservable? _legendsize;
  set legendsize (dynamic v)
  {
    if (_legendsize != null)
    {
      _legendsize!.set(v);
    }
    else if (v != null)
    {
      _legendsize = IntegerObservable(Binding.toKey(id, 'legendsize'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get legendsize => _legendsize?.get();

  /// Called when the databroker returns a successful result
  ///
  /// [ChartModel] overrides [WidgetModel]'s onDataSourceSuccess
  /// to populate the series data from the datasource and
  /// to populate the label data from the datasource data.
  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    try {
      //here if the data strategy is category, we must fold all of the lists together and create a dummy key value map of every unique value, in order
      uniqueValues.clear();
      for (var serie in series) {
        if (serie.datasource == source.id) {
          // build the datapoints for the series, passing in the chart type, index, and data
          serie.iteratePoints(list, plotOnFirstPass: false);
          // add the built x values to a unique list to map to indeces
          if (xaxis.type == ChartAxisType.category) {
            serie.plotPoints(serie.dataList, true, false);
          }
          else if (xaxis.type == ChartAxisType.date) {
            serie.plotPoints(serie.dataList, false, true);
          }
          else {
            serie.plotPoints(serie.dataList, false, false);
          }
          // if(xaxis.type == ChartAxisType.category || xaxis.type == ChartAxisType.date) serie.plotPoints(uniqueValues, true);

          lineDataList.add(LineChartBarData(spots: serie.lineDataPoint,
              isCurved: serie.curved,
              belowBarData: BarAreaData(show: serie.showarea),
              dotData: FlDotData(show: serie.showpoints),
              barWidth: serie.type == 'point' || serie.showline == false ? 0 : serie.stroke ?? 2,
              color: serie.color ?? ColorHelper.fromString('random')));
          serie.xValues.clear();
        }
        uniqueValues.clear();
        notifyListeners('list', null);
      }
    }
    catch(e)
    {
      Log().debug('Series onDataSourceSuccess() error');
      // DialogService().show(type: DialogType.error, title: phrase.error, description: e.message);
    }
    return true;
  }

  @override
  Widget getView({Key? key})
  {
    return getReactiveView(LineChartView(this));
  }
}