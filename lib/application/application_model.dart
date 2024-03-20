// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:fml/config/config_model.dart';
import 'package:fml/fml.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/hive/stash.dart';
import 'package:fml/mirror/mirror.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/observable/scope_manager.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template_manager.dart';
import 'package:fml/token/token.dart';
import 'package:fml/user/user_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:provider/provider.dart';
import 'package:fml/theme/theme.dart';

class ApplicationModel extends WidgetModel {
  static const String myId = "APPLICATION";

  static String tableName = "APP";

  // key of this application record in
  // the HIVE database.
  late String _dbKey;

  late Future<bool> initialized;
  bool started = false;

  // Active user
  late UserModel _user;
  UserModel get user => _user;

  // used for social media
  FirebaseApp? firebase;

  ScopeManager scopeManager = ScopeManager();

  // mirrors
  Mirror? mirror;
  bool get cacheContent => (mirror != null);

  // secure?
  bool get secure => scheme == "https" || scheme == "wss";

  // forces pages to repaint every visit
  bool get autoRefresh => toBool(settings("REFRESH")) ?? false;
  bool get singlePage => toBool(settings('SINGLE_PAGE_APPLICATION')) ?? false;

  late String url;

  // application title
  String? title;

  // application icon
  String? icon;
  String? iconLight;
  String? iconDark;

  // theme settings
  Brightness get brightness =>
      toEnum(settings('BRIGHTNESS')?.toLowerCase().trim(), Brightness.values) ??
      FmlEngine.defaultBrightness;
  Color get color =>
      toColor(settings('COLOR') ??
          settings('PRIMARY_COLOR') ??
          settings('COLOR_SCHEME')) ??
      FmlEngine.defaultColor;
  String get font => settings('FONT') ?? FmlEngine.defaultFont;

  // default page transition
  PageTransitions? transition;

  // application icons position
  // on the store display (future use for multi-page and ordering)
  String? page;
  int? order;

  // config
  String? config;
  ConfigModel? _config;
  bool get hasConfig => _config != null;

  // application stash
  late Stash _stash;
  late Scope stash;

  // jwt - json web token
  Jwt? get jwt => _user.jwt;

  String? _scheme;
  String? get scheme => _scheme;

  String? _host;
  String? get host => _host;

  String? _domain;
  String? get domain => _domain;

  String? _startPage;
  String? get startPage => _startPage;

  Map<String, String>? _queryParameters;
  Map<String, String>? get queryParameters => _queryParameters;

  // fml version support
  int? fmlVersion;

  String get homePage => settings("HOME_PAGE") ?? "main.xml";
  String? get loginPage => settings("LOGIN_PAGE");
  String? get errorPage => settings("ERROR_PAGE");

  Map<String, String?>? get configParameters => _config?.parameters;

  ApplicationModel(WidgetModel parent,
      {String? key,
      required this.url,
      this.title,
      this.icon,
      this.iconLight,
      this.iconDark,
      this.transition,
      this.page,
      this.order,
      String? jwt})
      : super(parent, myId, scope: Scope(id: myId)) {
    // parse to url into its parts
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return;

    // set database key
    _dbKey = key ?? url;

    // no scheme provided
    if (!uri.hasScheme) uri = Uri.tryParse("https://${uri.url}");
    if (uri == null) return;

    _scheme = uri.scheme;
    _host = uri.host;

    // set the start page
    String? fragment = uri.hasFragment ? uri.fragment : null;
    if (fragment != null && fragment.toLowerCase().contains(".xml")) {
      var myUri = Uri.tryParse(fragment);
      if (myUri != null) {
        _queryParameters = myUri.hasQuery ? myUri.queryParameters : null;
        _startPage = myUri.removeQuery().url;
      }
    } else {
      _queryParameters = uri.queryParameters;
    }

    // base domain
    _domain = uri
        .removeFragment()
        .removeQuery()
        .replace(userInfo: null)
        .removeEmptySegments()
        .url;

    // active user
    _user = UserModel(this, jwt: jwt);

    // load the config
    initialized = initialize();
  }

  // initializes the app
  @override
  Future<bool> initialize() async {
    // build stash
    stash = Scope(id: 'STASH');
    if (domain != null) _stash = await Stash.get(domain!);
    for (var entry in _stash.map.entries) {
      stash.setObservable(entry.key, entry.value);
    }

    // add SYSTEM scope
    scopeManager.add(System().scope!);

    // add THEME scope
    scopeManager.add(System.theme.scope!);

    // add STASH scope
    scopeManager.add(stash);

    // add USER scope
    scopeManager.add(_user.scope!);

    // add GLOBAL alias to this scope
    scopeManager.add(scope!, alias: "GLOBAL");

    // build config
    var config = await _getConfig(true);
    if (config != null) _config = config;

    // get global template
    // get global.xml
    if (domain != null) {
      var uri = Uri.tryParse(domain!)?.setPage("global.xml");
      if (uri != null) {
        var template =
            await TemplateManager().fetch(url: uri.url, refresh: true);

        // deserialize the returned template
        if (template.document != null && !template.isAutoGeneratedErrorPage) {
          deserialize(template.document!.rootElement);
        }
      }
    }

    return true;
  }

  String? settings(String key) {
    if (_config == null) return null;
    if (_config!.settings.containsKey(key)) return _config!.settings[key];
    return null;
  }

  // refreshes the config file settings
  Future<bool> refresh() async {
    var model = await _getConfig(true);
    if (model != null) _config = model;
    return true;
  }

  // converts versions of 0.0.0 to a number
  static int? toVersionNumber(String? version) {
    if (version == null) return null;
    try {
      version = version.replaceAll("+", "");
      List versionCells = version.split('.');
      versionCells = versionCells.map((i) => int.parse(i)).toList();
      return versionCells[0] * 100000 +
          versionCells[1] * 1000 +
          versionCells[2];
    } catch (e) {
      return null;
    }
  }

  // loads the config
  Future<ConfigModel?> _getConfig(bool refresh) async {
    ConfigModel? model;

    /// parse the config
    if (config != null) {
      var e = Xml.tryParse(config);
      if (e != null) model = await ConfigModel.fromXml(null, e.rootElement);
    }

    // get config from url
    if (domain != null && (refresh || model == null)) {
      model = await ConfigModel.fromUrl(null, domain!);
    }

    // model created?
    if (model != null) {
      // set fml version support level
      fmlVersion = toVersionNumber(model.settings["FML_VERSION"]);

      // get the icon
      icon =
          await _getIcon(model.settings["APP_ICON"] ?? model.settings["ICON"]);
      iconLight = await _getIcon(
          model.settings["APP_ICON_LIGHT"] ?? model.settings["ICON_LIGHT"]);
      iconDark = await _getIcon(
          model.settings["APP_ICON_DARK"] ?? model.settings["ICON_DARK"]);

      // default transition
      transition = toEnum(model.settings["TRANSITION"], PageTransitions.values);

      // mirror?
      var mirrorApi = model.settings["MIRROR_API"];
      if (mirrorApi != null && !FmlEngine.isWeb && scheme != "file") {
        Uri? uri = URI.parse(mirrorApi, domain: domain);
        if (uri != null) {
          mirror = Mirror(uri.url);
          mirror!.execute();
        }
      }

      // set the config
      _config = model;

      // save to hive
      await upsert();

      notifyListeners("config", null);
    }
    return model;
  }

  Future<String?> _getIcon(String? icon) async {
    if (icon == null) return null;

    Uri? uri = URI.parse(icon, domain: domain);
    if (uri == null) return null;

    var data = await URI.toUriData(uri.url);
    return data?.toString();
  }

  Future<bool> stashValue(String key, dynamic value) async {
    bool ok = true;
    try {
      // key must be supplied
      if (isNullOrEmpty(key)) return ok;

      if (value == null) {
        _stash.map.remove(key);
        _stash.upsert();
        Binding? binding = Binding.fromString('$key.value');
        if (binding != null) {
          stash.observables.remove(stash.getObservable(binding)?.key);
        }
        return ok;
      }

      // write application stash entry
      _stash.map[key] = value;

      // save to the hive
      await _stash.upsert();

      // set observable
      stash.setObservable(key, value);
    } catch (e) {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  Future<bool> clearStash() async {
    bool ok = true;
    try {
      // clear rthe stash map
      _stash.map.clear();

      // save to the hive
      await _stash.upsert();
    } catch (e) {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  void launch(bool notifyOnThemeChange) {
    // set stash values
    for (var entry in _stash.map.entries) {
      stash.setObservable(entry.key, entry.value);
    }

    // start all datasources
    if (datasources != null) {
      for (var datasource in datasources!) {
        if (datasource.autoexecute != false) {
          datasource.start();
        }
        datasource.initialized = true;
      }
    }

    // set the theme
    if (context != null) {
      var notifier = Provider.of<ThemeNotifier>(context!, listen: false);
      notifier.setTheme(
          brightness: brightness,
          color: color,
          font: font,
          notify: notifyOnThemeChange);
    }
  }

  void close() {
    // start all datasources
    if (datasources != null) {
      for (var datasource in datasources!) {
        datasource.stop();
      }
    }
  }

  @override
  void dispose() {
    // close the app
    close();

    // dispose of all children
    super.dispose();
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> map = {};
    map["key"] = _dbKey;
    map["url"] = url;
    map["title"] = title;
    map["icon"] = icon;
    map["icon_light"] = iconLight;
    map["icon_dark"] = iconDark;
    map["transition"] = fromEnum(transition);
    map["page"] = page;
    map["order"] = order;
    map["config"] = _config?.xml;
    map["jwt"] = jwt;
    return map;
  }

  static Future<ApplicationModel?> _fromMap(dynamic map) async {
    ApplicationModel? app;
    if (map is Map<String, dynamic>) {
      app = ApplicationModel(System(),
          key: fromMap(map, "key"),
          url: fromMap(map, "url"),
          title: fromMap(map, "title"),
          icon: fromMap(map, "icon"),
          iconLight: fromMap(map, "icon_light"),
          iconDark: fromMap(map, "icon_dark"),
          transition:
              toEnum(fromMap(map, "transition"), PageTransitions.values),
          page: fromMap(map, "page"),
          order: fromMapAsInt(map, "order"),
          jwt: fromMap(map, "jwt"));
      await app.initialized;
    }
    return app;
  }

  // inserts a new app into the local hive
  Future<bool> insert() async {
    var exception = await Database().insert(tableName, _dbKey, _toMap());
    return (exception == null);
  }

  // updates the app in the local hive
  Future<bool> upsert() async {
    var exception = await Database().upsert(tableName, _dbKey, _toMap());
    return (exception == null);
  }

  // delete an app from the local hive
  Future<bool> delete() async {
    var exception = await Database().delete(tableName, _dbKey);
    return (exception == null);
  }

  static Future<List<ApplicationModel>> loadAll() async {
    List<ApplicationModel> apps = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName);
    for (var entry in entries) {
      ApplicationModel? app = await _fromMap(entry);
      if (app != null) apps.add(app);
    }
    return apps;
  }

  Future<bool> logon(Jwt? jwt) async {
    if (jwt != null) _user.logon(jwt);
    return true;
  }

  Future<bool> logoff() async {
    _user.logoff();
    return true;
  }
}
