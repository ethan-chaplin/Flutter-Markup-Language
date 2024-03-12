// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/cupertino.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/fml.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/menu/menu_view.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:provider/provider.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

final bool enableTestPlayground = false;

class StoreView extends StatefulWidget
{
  final MenuModel model = MenuModel(null, 'Applications');
  StoreView();

  @override
  State createState() => _ViewState();
}

class _ViewState extends State<StoreView> with SingleTickerProviderStateMixin implements IModelListener, INavigatorObserver
{
  final bool _visible = false;
  late InputModel appURLInput;

  RoundedRectangleBorder rrbShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  @override
  void initState()
  {
    super.initState();
    appURLInput = InputModel(null, null, hint: phrase.store, value: "", icon: Icons.link, keyboardType: 'url', keyboardInput: 'done');
    Store().registerListener(this);
  }

  @override
  didChangeDependencies()
  {
    // listen to route changes
    NavigationObserver().registerListener(this);
    super.didChangeDependencies();
  }

  @override
  void dispose()
  {
    // stop listening to model changes
    Store().removeListener(this);

    // stop listening to route changes
    NavigationObserver().removeListener(this);

    // Cleanup
    Store().dispose();

    super.dispose();
  }

  @override
  BuildContext getNavigatorContext() => context;

  @override
  Map<String,String>? onNavigatorPop() => null;
  @override
  onNavigatorChange() {}

  @override
  void onNavigatorPush({Map<String?, String>? parameters})
  {
    // reset the theme
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.setTheme(brightness: ThemeModel.defaultBrightness, color: ThemeModel.defaultColor);
  }

  /// Callback to fire the [_ViewState.build] when the [StoreModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    // build menu items
    widget.model.items = [];
    var apps = Store().getApps();
    for (var app in apps)
    {
      var item = MenuItemModel(widget.model, app.id, url: app.url, title: app.title, subtitle: '', icon: app.icon == null ? 'appdaddy' : null, image: app.icon, onTap: () => _launchApp(app), onLongPress: () => removeApp(app));
      widget.model.items.add(item);
    }

    // store menu
    Widget store = MenuView(widget.model);

    Widget noapps = Center(
        child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            child: Text(phrase.clickToConnect, style: TextStyle(color: Theme.of(context).colorScheme.outline))));

    var addButton = FloatingActionButton.extended(
        label: Text(phrase.addApp),
        icon: Icon(Icons.add),
        onPressed: () => addAppDialog(),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        splashColor: Theme.of(context).colorScheme.inversePrimary,
        hoverColor: Theme.of(context).colorScheme.surface,
        focusColor: Theme.of(context).colorScheme.inversePrimary,
        shape: rrbShape);

    var busyButton = FloatingActionButton.extended(
        label: Text(phrase.loadApp),
        onPressed: null,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        splashColor: Theme.of(context).colorScheme.inversePrimary,
        hoverColor: Theme.of(context).colorScheme.surface,
        focusColor: Theme.of(context).colorScheme.inversePrimary,
        shape: rrbShape);

    var busy = Center(child: BusyModel(Store(), visible: Store().busy, observable: Store().busyObservable, modal: true).getView());

    var privacyUri    = Uri(scheme: 'https', host: 'fml.dev' , path: '/privacy.html');
    var privacyText   = Text(phrase.privacyPolicy, style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline));
    var privacyButton = InkWell(child: privacyText, onTap: () => launchUrl(privacyUri));

    var version = Text('${phrase.version} ${FmlEngine.version}', style: TextStyle(color: Colors.black26));

    var text = Column(mainAxisSize: MainAxisSize.min, children: [privacyButton,version]);
    var view = Center(child: apps.isEmpty ? noapps : store);
    var button = Store().busy ? busyButton : addButton;

    var scaffold = Scaffold(floatingActionButton: button, body: SafeArea(child: Stack(children: [view, Positioned(child: text, left: 10, bottom: 10), busy])));

    return WillPopScope(onWillPop: () => quitDialog().then((value) => value as bool), child: scaffold);
  }

  Future<void> addAppDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context)
      {
        return StatefulBuilder(builder: (context, setState)
        {
          return AlertDialog(
            title: Row(children: [Text(phrase.connectAnApplication, style: TextStyle(color: Theme.of(context).colorScheme.primary)), Padding(padding: EdgeInsets.only(left: 20)), BusyView(BusyModel(Store(), visible: Store().busy, observable: Store().busyObservable, size: 14))]),
            content: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: AppForm()),
            contentPadding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 2.0),
            insetPadding: EdgeInsets.zero,
          );
        });
      },
    );
  }

  Future<void> removeApp(ApplicationModel app) async
  {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Application?'),
          content: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: EdgeInsets.only(top: 20), child: Text(app.title ?? "", style: TextStyle(fontSize: 18),),),
              Padding(padding: EdgeInsets.only(bottom: 10), child: Text('(${app.url})', style: TextStyle(fontSize: 14))),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                TextButton(
                    onPressed: () async
                    {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removing ${app.title}'), duration: Duration(milliseconds: 1000)));
                      await Store().delete(app);
                      Navigator.of(context).pop();
                    },
                    child: Text('Remove')
                ),
                Padding(padding: EdgeInsets.only(right: 10),),
              ],),
              // BUTTON.View(storeButton, onPressCallback: () => link(),
              //     child: Padding(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), child: Text(phrase.loadApp, style: TextStyle(fontSize: 17)))
              // ),
            ]),
          ),
          contentPadding: EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 2.0),
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Future<void> quitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${phrase.close} ${phrase.application}?'),
          content: SizedBox(width: MediaQuery.of(context).size.width - 60, height: 80,
            child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(phrase.no)),
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                      // SystemNavigator.pop()
                    },
                    child: Text(phrase.yes)
                ),
              ],),
              // BUTTON.View(storeButton, onPressCallback: () => link(),
              //     child: Padding(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), child: Text(phrase.loadApp, style: TextStyle(fontSize: 17)))
              // ),
            ]),
          ),
          contentPadding: EdgeInsets.fromLTRB(4.0, 20.0, 4.0, 10.0),
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }

  _launchApp(ApplicationModel app) async
  {
    Store().launch(app, context);
  }
}

class AppForm extends StatefulWidget
{
  AppForm();

  @override
  AppFormState createState()
  {
    return AppFormState();
  }
}

class AppFormState extends State<AppForm>
{
  final   _formKey  = GlobalKey<FormState>();
  String  errorText = '';
  String? title;
  String? url;
  bool unreachable = false;

  var urlController = TextEditingController();

  // busy
  BooleanObservable busy = BooleanObservable(null, false);

  String? _validateTitle(title)
  {
    this.title = null;
    errorText = '';

    // missing title
    if (isNullOrEmpty(title))
    {
      errorText = "Title must be supplied";
      return errorText;
    }

    // assign url
    this.title = title;

    return null;
  }

  String? _validateUrl(url)
  {
    this.url = null;
    errorText = '';

    // missing url
    if (unreachable)
    {
      errorText = "Site unreachable or is missing config.xml";
      return errorText;
    }

    // missing url
    if (isNullOrEmpty(url))
    {
      errorText = phrase.missingURL;
      return errorText;
    }

    var uri = Uri.tryParse(url);

    // invalid url
    if (uri == null)
    {
      errorText = 'The address in not a valid web address';
      return errorText;
    }

    // missing scheme
    if (!uri.hasScheme)
    {
      uri = Uri.parse('https://${uri.url}');
      urlController.text = uri.toString();
    }

    // missing host
    if (isNullOrEmpty(uri.authority))
    {
      errorText = 'Missing host in address';
      return errorText;
    }

    // already defined
    if (Store().find(url: uri.toString()) != null)
    {
      errorText = 'You are already connected to this application';
      return errorText;
    }

    // assign url
    this.url = url;

    return null;
  }

  Future _addApp() async
  {
    // validate the form
    unreachable = false;
    busy.set(true);
    bool ok = _formKey.currentState!.validate();
    if (ok)
    {
      ApplicationModel app = ApplicationModel(System(),url: url!, title: title);
      await app.initialized;
      if (app.hasConfig)
      {
        Store().add(app);
        Navigator.of(context).pop();
      }
      else
      {
        unreachable = true;
        _formKey.currentState!.validate();
      }
    }
    busy.set(false);
  }

  @override
  Widget build(BuildContext context)
  {
    var name =  TextFormField(validator: _validateTitle, decoration: InputDecoration(labelText: "Application Name", labelStyle: TextStyle(color: Colors.grey, fontSize: 12), fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide())));

    var url = TextFormField(controller: urlController, validator: _validateUrl, keyboardType: TextInputType.url, decoration: InputDecoration(labelText: "Application Address (https://mysite.com)", labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
        fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide())));

    var cancel = TextButton(child: Text(phrase.cancel),  onPressed: () => Navigator.of(context).pop());

    var connect =  TextButton(child: Text(phrase.connect), onPressed: _addApp);

    List<Widget> layout = [];

    // form fields
    layout.add(Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(url);
    layout.add(Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(name);

    // buttons
    var buttons = Padding(padding: const EdgeInsets.only(top: 10.0, bottom: 10),child: Align(alignment: Alignment.bottomCenter, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancel,connect])));
    layout.add(buttons);

    var b = BusyModel(Store(), visible: (busy.get() ?? false), observable: busy, modal: false).getView();
    var form = Form(key: _formKey, child: Column(children: layout, mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start));

    return Stack(fit: StackFit.passthrough, children: [form,b]);
  }
}
