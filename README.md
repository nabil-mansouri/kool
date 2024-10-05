# food

An uber eats like application written using flutter.
The app embed a google map like GPS for the driver.
The project has only been test on an android simulator
It needs to configure firebase for iOS.

## Generate Json

``` flutter packages pub run build_runner build```

## Tests

Run test using:
```flutter run -t test/widget_test.dart```

Test covers:

- RestaurantService: firebase access, transformations (from and to firebase), queries filters, sorting, pagination (radius increases)...
- Restaurant Workflow: list restaurants, fetch detail, navigation redirects...

It is also possible to generate demo data's, to do so , uncomment the line below in test file:

```//demo();```

## Functionnality

It also let see the restaurants products grouped by category.

## Architecture

### 'commons' folder

Contains some firebase abstract class (DAO and cursor)

### 'multiflow' folder

It is a library to externalize. It lets:

- Create a redux-like multi-store (with reducer and actions)
- Create future actions (like redux-thunk)
- Create workflow (like redux sage) using some effects: wait , takeevery, fork...
- Create store listener (to listen state changed)
- It contains a navigation connector that let send navigation or listen navigation changed from the store
- It contains also a stateful widget that lets update children according states changes 

Stores and workflows could be organized as trees:
- to enable listen changes from children instead of roots
- to enable more modularity (compose stores and workflow from different module)

TODO
- add dart doc
- externalize and publish the package

Tips:
- to run only one group add 'solo' flag

### 'restaurant' folder

It contains the restaurant module that lets:
- explore restaurant by geolocation and filters (and sorts)
- explore products by restaurant and categories

The module exposes:
- widgets (UI component for restaurant module)
- store (Store and workflow related to restaurants)
- domains (domain objet and service related to restaurant data)


### 'users' folder (not implemented)

It contains the user module that lets:
- manage subscription
- manage authentication
- manage user profile


### 'commerce' folder (not implemented)

It contains the ecommerce module that lets:
- manage cart
- manage orders
- manage bills
