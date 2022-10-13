import 'package:example/example_page.dart';
import 'package:example/home_page.dart';
import 'package:flutter/material.dart';

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ExampleApp> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routeInformationParser = AppRouteInformationParser();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Example app',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.home();
    }

    // Handle '/examples/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'examples') return AppRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = remaining;
      // if (id == null) return AppRoutePath.unknown();
      return AppRoutePath.details(id);
    }

    // Handle unknown routes
    return AppRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath path) {
    if (path.isUnknown) {
      return const RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return const RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/examples/${path.id}');
    }
    return null;
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String? _selectedExample;
  bool show404 = false;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath get currentConfiguration {
    if (show404) {
      return AppRoutePath.unknown();
    }
    return _selectedExample == null ? AppRoutePath.home() : AppRoutePath.details(_selectedExample);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('HomePage'),
          child: HomePage(chooseExample: (id) {
            _handleExampleTapped(id);
          }),
        ),
        if (show404)
          MaterialPage(key: const ValueKey('UnknownPage'), child: UnknownScreen())
        else if (_selectedExample != null)
          MaterialPage(
              key: const ValueKey('ExamplePage'),
              child: Builder(
                builder: (BuildContext context) {
                  return ExamplePage(id: _selectedExample);
                },
              ))
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedBook to null
        _selectedExample = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path.isUnknown) {
      _selectedExample = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id == null) {
        show404 = true;
        return;
      }

      _selectedExample = path.id;
    } else {
      _selectedExample = null;
    }

    show404 = false;
  }

  void _handleExampleTapped(String id) {
    _selectedExample = id;
    notifyListeners();
  }
}

class AppRoutePath {
  final String? id;
  final bool isUnknown;

  AppRoutePath.home()
      : id = null,
        isUnknown = false;
  AppRoutePath.details(this.id) : isUnknown = false;
  AppRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;
  bool get isDetailsPage => id != null;
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('404!'),
      ),
    );
  }
}
