## Setting Up a Controller

Changing the URL may also change which template is displayed on
screen. Templates, however, are usually only useful if they have some
source of information to display.

In Ember.js, a template retrieves information to display from a
controller.

Two built-in controllers—`Ember.ObjectController` and
`Ember.ArrayController`—make it easy for a controller to present a
model's properties to a template, along with any additional
display-specific properties.

To tell one of these controllers which model to present, set its
`content` property in the route handler's `setupControllers` hook.

```js
App.Route.map(function(match) {
  match('/posts/:post_id').to('post');
});

App.PostRoute = Ember.Route.extend({
  setupControllers: function(controller, model) {
    controller.set('content', model);
  }
});
```

The `setupControllers` hook receives the route handler's associated
controller as its first argument. In this case, the `PostRoute`'s
`setupControllers` receives the application's instance of
`App.PostController`.

As a second argument, it receives the route handler's model. For more
information, see [Specifying a Route's Model][1].

[1]: /guides/routing/specifying-a-routes-model

The default `setupControllers` hook sets the `content` property of the
associated controller to the route handler's model.

If you want to configure a controller other than the controller
associated with the route handler, use the `controllerFor` method:

```js
App.PostRoute = Ember.Route.extend({
  setupControllers: function(controller, model) {
    this.controllerFor('topPost').set('content', model);
  }
});
```
