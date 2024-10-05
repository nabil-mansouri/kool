import 'package:flutter/material.dart';
import 'multiflow/multiflow.dart';
import 'commerce/commerce.dart';
import 'restaurants/restaurants.dart';
import "navigation/navigation.dart";
import 'store.dart';

class AppRestaurant extends StatelessWidget {
  final Store<GlobalState> store;
  final RouteObserverStore routeObserver;
  static withDefaultStore() {
    Store<GlobalState> store = getRootStore();
    return AppRestaurant(store);
  }

  AppRestaurant(Store<GlobalState> store)
      : this.store = store,
        routeObserver = RouteObserverStore(store);
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: StoreNavigation(
            routeObserver: routeObserver,
            child: MaterialApp(
                title: "KOOL",
                navigatorObservers: [routeObserver],
                initialRoute: GlobalRoutes.SPLASHSCREEN,
                routes: {
                  GlobalRoutes.SPLASHSCREEN: (context) => SplashScreen(),
                  GlobalRoutes.RESTAURANTS_LIST: (context) =>
                      RestaurantListScreen(),
                  GlobalRoutes.RESTAURANTS_DETAIL: (context) =>
                      RestaurantDetailScreen(),
                  GlobalRoutes.RESTAURANTS_SEARCH: (context) =>
                      RestaurantSearchContainer(),
                  GlobalRoutes.RESTAURANTS_SEARCH_INITIAL: (context) =>
                      RestaurantListEmptyScreen(),
                  GlobalRoutes.NAVIGATION: (context) => NavigationPageWidget(),
                  CartRoutes.CART_SELECT: (context) => CartSelectionScreen(),
                  CartRoutes.CART_SHOW: (context) => RestaurantPaymentScreen()
                },
                theme: ThemeData(
                    primarySwatch: Colors.teal, accentColor: Colors.amber))));
  }
}

abstract class TabScreen extends StatelessWidget {
  Widget buildIcon(BuildContext context, IconData data) {
    var primary = Theme.of(context).primaryColor as MaterialColor;
    var color = primary.shade600;
    if (!this.isSelected(data)) {
      color = primary.shade100;
    }
    return IconButton(
      color: color,
      splashColor: Colors.white54,
      disabledColor: Colors.white10,
      icon: Icon(data),
      onPressed: () {
        GlobalActions store = StoreProvider.getStore(context, GlobaleStore);
        if (!this.isSelected(data)) {
          this.onSelect(store, data);
        }
      },
    );
  }

  onSelect(GlobalActions actions, IconData data) {
    if (data == Icons.menu) {
      actions.goToRestaurantList();
    } else if (data == Icons.search) {
      actions.goToRestaurantSearch();
    } else if (data == Icons.account_circle) {
      actions.goToNavigation();
    }
  }

  build(context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: this.body(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            this.buildIcon(context, Icons.menu),
            this.buildIcon(context, Icons.search),
            this.buildIcon(context, Icons.history),
            this.buildIcon(context, Icons.account_circle)
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
              onPressed: () => print("press"),
              tooltip: 'yeah',
              child: Icon(Icons.tag_faces),
            ),*/
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  bool isSelected(IconData icon);
  Widget body();
}

class RestaurantListScreen extends TabScreen {
  body() {
    return RestaurantListContainer();
  }

  isSelected(IconData data) {
    return Icons.menu == data;
  }
}

class RestaurantListEmptyScreen extends TabScreen {
  body() {
    return RestaurantListEmptyPositionContainer();
  }

  isSelected(IconData data) {
    return Icons.menu == data;
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.teal,
      body: new Center(
        child: Text("KOOL",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white70)),
      ),
    );
  }
}
//TODO
//utiliser theme
//faire apres vente
//faire ajout produit
//revoir design
//fetch resto: ne pas attendre que le curseur termine => envoyer via un stream
//IOS
