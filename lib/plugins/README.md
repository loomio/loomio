# HOWTO: Developing Loomio Plugins

Due to popular demand, we've implemented a simple plugin architecture to allow contributors to supply their own awesome improvements to Loomio. This is a great place to start!

## Setting up a plugin
Every plugin must be a folder within the `/plugins` directory, with a `plugin.rb` file in it. Like so:

```
/plugins
  /kickflip
    plugin.rb
```

As we'll see, other files may go into this directory, but this is the bare minimum for a working plugin.

By default, all folders in the /plugins folder are hidden by `.gitignore`, so if you're hacking on a plugin locally, be sure to add a line to `.gitignore` telling it to reveal the plugin(s) you're working on at the moment.

```
!/plugins/kickflip
```

### Writing your plugin.rb

In your `plugin.rb` file, write a class which inherits from `Plugins::Base` (this will give you access to the setup method). It's also usually a good idea to namespace your plugin within a module, so there aren't naming conflicts.

Within this class, you'll want to write a setup method, like so:

```ruby
module Plugins
  module Kickflip
    class Plugin < Plugins::Base
      setup! :kickflip do |plugin|
        # your plugin code goes here
      end
    end
  end
end
```

This setup method takes the name of your plugin, and a block of actions to perform to set it up.

### Enable and disable plugins via ENV
One of the first things to do with a new plugin is specify how it is enabled.
Within the aforementioned setup block, you can put a line in like so:

```ruby
setup! :kickflip do |plugin|
  plugin.enabled = "KICKFLIP_ENABLED"
end
```

This will look in your ENV for a `KICKFLIP_ENABLED` value, and enable your plugin if that value is present.
To ensure that a plugin is always enabled, you can also set this value to `true`:

```ruby
  plugin.enabled = true
```

### Add new classes
Let's include an external class into our plugin. Inside our plugin folder, we write a `Kickflip` class, into `plugins/kickflip/models/kickflip.rb`:

```ruby
class Kickflip
  def perform
    puts "100 points!"
  end
end
```

Then, in order to include this class, we can write the following line into our setup block:

```ruby
  plugin.use_class 'models/kickflip'
```

We spin up our Loomio instance, and voila!
```
> Kickflip.new.perform
100 points!
```

### Add directories of classes
You can also include entire directories of classes if you don't want to type out every single file

```ruby
  plugin.use_class_directory 'models'
```

A couple things to note:
- This is not recursive, so you'll need to include the class directory of nested folders as well
- There's no guarantee of file order! If you have dependencies within a directory, you'll need to load the dependencies first using `use_class`, then load the rest of the directory:

```ruby
  plugin.use_class 'models/base'
  plugin.use_class_directory 'models'
```

### Extend existing classes
If you want to extend an existing class, you can do so easily! Here we use the `extend_class` command, and pass it a constant. Then we can write additional functionality onto existing classes within a block
(this is executed onto the given class using `class_eval`)

```ruby
  plugin.extend_class User do
    def kickflip
      puts "100 points!"
    end
  end
```
(note that this will overwrite existing methods in the class; be careful!)

```
> User.new.kickflip
100 points!
```

### Listen for Loomio events
Loomio emits all kinds of events as things happen within the app. Most service methods (the files living in `app/services`) will emit events, as well as when new Event instances are created (`app/models/events`). In order to listen to these events, you can use the `use_events` method, which will supply you an instance of our EventBus to apply listeners to.

Parameters passed through these events vary a little based on the event, but the following rules of thumb apply:

**For Service Calls**: (|model, user, params|) The model being worked on is passed through (so, for a discussion service call, the discussion in question would be passed through), followed by the user performing the action, and the parameters passed to the service, if they exist. Again, you can check out the source for the service in question (`app/services`) for more info on what specifically is passed through for each event.

**For Event creation**: (|event, user|) The newly created event is passed through, followed by the user performing the action.


```ruby
  plugin.use_events do |event_bus|
    event_bus.listen('new_motion_event') { |motion| Kickflip.new(motion).perform }
  end
```
Here we listen for whenever a new motion is created, build a new Kickflip with it, and call perform on it.

### Add angular components
Much of the javascript app is written using Angular components, which are made up of three parts:
  - A directive (required)
  - A template (required for element directives)
  - A stylesheet (optional)

These allow us to have modular pieces of functionality which can be called upon anywhere in our app. You can check out the existing ones in core in `lineman/app/components`. A kickflip component might look like this:

```
/plugins
  /components
    /kickflip
      kickflip.coffee
      kickflip.haml
      kickflip.scss  
```
(note that our component folder must be named the same as our .coffee, .haml, and .scss files, and they must be nested in a `components` folder to function properly #opinionated)

To tell the plugin to use your component, put a line in our `plugin.rb` like this:

```
  plugin.use_component :kickflip
```

This will make your component available within the app.

### Add routes to the angular app

If you're adding an entirely new page to Loomio, you'll need to add a route in order to allow us to
navigate to your new page properly. To do this, use the `use_client_route` command

```ruby
plugin.use_client_route '/kickflips', :kickflip_page
```

In the above, `kickflip_page` is simply a component, same as you'd write in the `use_component` command.
So now we can simply write our controller code as normal:

```
/plugins
  /components
    /kickflip_page
      kickflip_page.haml
      kickflip_page.scss
      kickflip_page.coffee
```

For examples on how to write page controllers (which are subtly different from regular components), check out [thread_page_controller.coffee](https://github.com/loomio/loomio/blob/master/angular/core/components/thread_page/thread_page_controller.coffee) or [group_page_controller.coffee](https://github.com/loomio/loomio/blob/master/angular/core/components/group_page/group_page_controller.coffee) in the core Loomio repo.

_NB: you don't need to call `use_component` as well, calling `use_client_route` will do this for you!)_

### Attach components to outlets in the Angular interface
Now that the component is loaded into our angular app, how to make it appear on the interface?

There are several outlets in the loomio angular interface which you can attach components to. They look like this:

```haml
  %outlet{name: "before-motion-description"}
```
(hint: searching the repo for `%outlet` will give you a list of all current outlets. They're really harmless to add too, so if you find a place where you'd like to have an outlet but there's not one, send us a PR!)

In order to attach a plugin to an outlet, we simply need to specify the name of the outlet in our `use_component` line, like this:

```ruby
  plugin.use_component :kickflip, outlet: :before_motion_description
```

And voila! Custom code almost anywhere you'd like in the angular interface.

### Add other angular code
If you want to make an angular something which isn't a component (like a filter or a factory), you can do so using `plugin.use_asset`

```coffee
  # services/kickflip_filter.coffee
  angular.module('loomioApp').filter 'kickflipFilter', ->
    (text) ->
      "#{text} for 100 points!!"
```

```ruby
  plugin.use_asset 'services/kickflip_filter.coffee'
```

NB: We only support coffeescript at the moment, but in the future we'll allow plugin authors to write their client side code in ES6, TypeScript, vanilla javascript, even Clojure!

### Add database migrations
If you need a spot in the database to store all the cool stuff your plugin is doing, we can make a new table using the `use_database_table` command like this:

```ruby
  plugin.use_database_table :kickflip do |table|
    table.belongs_to :skater
    table.integer :point_value
    table.timestamps
  end
```
Note that that `do` block can accept anything you'd put in a typical `create_table` block in a migration

Also note that while you can add new tables to the schema, we don't support modifying the existing tables in Loomio core via plugin.

### Add routes
If your plugin needs to communicate between the client and server side, you'll want to set up a route.

We can do this using the `use_route` command:

```ruby
  plugin.use_route :get,    '/kickflips/:id', 'kickflips#show'
  plugin.use_route :post,   '/kickflips',     'kickflips#create'
  plugin.use_route :delete, '/kickflips/:id', 'kickflips#destroy'
```

The above will create three routes which will call the `show`, `create`, and `destroy` method on `KickflipsController`, respectively.

### Adding translations to your plugin
If you're writing templates, it may be that you wish to include translatable strings in them. We support a super easy way of including yml translations with your plugin.

Given a template like this:
```
  .kickflip-template
    100 points!
```

we can change our "100 points" into a translatable string like so:
```
  .kickflip{translate: 'kickflip.one_hundred_points'}
```
(NB: it's a good idea to namespace your translations with your plugin name, to avoid conflicts)

Then, we can create a yml file in our plugin

```yml
  # plugins/kickflip/config/locales/kickflip.en.yml
  en:
    kickflip:
      one_hundred_points: "100 points!"
```

and translate it in another file:
```yml
  # plugins/kickflip/config/locales/kickflip.de.yml
  de:
    kickflip:
      one_hundred_points: "100 Punkte!"
```

Now, we can tell our plugin to load those translations with the `use_translations` method in our config:

```ruby
  plugin.use_translations("config/locales", :kickflip)
```
where 'config/locales' is the folder relative to the plugin root, and 'kickflip' is the name of our locale files.

### Installing existing plugins onto your instance

Adding existing plugins to your instance is as easy as editing the `plugins/plugins.yml` file to include the repo you're looking for. That file looks something like this:

```yml
# plugins/plugins.yml
kickflip:
  repo: gdpelican/kickflip
  version: my_branch
```

Note that 'repo' will be the thing which is passed to `git clone`, while 'version' will be passed to `git checkout` (this allows for branch names, tag names, and individual commits.) The  default is 'master'.

NB: You'll need to add some github credentials to your environment to allow for git cloning! To do so, edit your `.env` file to include the following variables:

```yml
#.env
GITHUB_USERNAME=my_username
GITHUB_PASSWORD=my_password
```

##### Marking a plugin as an experiment

On Loomio.org, we have plugins that we'd like to try out in a production environment,
but might not be ready for all of our users to see just yet. To enable this, we've
added the ability to mark some plugins as 'experimental', which means they will
only be loaded for groups who have opted in to see our mad science.

In order to mark a plugin as an experiment, simply add the line `experimental: true`
to the plugin's entry in `plugins.yml`, like so:

```yaml
kickflip:
  repo:         loomio/kickflip
  branch:       master
  experimental: true
```

###### Constraining a plugin to certain subscription levels

We also have plugins which we only want to appear for our paying customers. In order to do this on your instance,
you can provide the config with a list of 'plans', like so:

```yaml
kickflip:
  repo:     loomio/kickflip
  plans:
    - standard
    - plus
```

This will be compared to the 'plan' field of the group's subscription when deciding whether to display the plugin or not.

###### How this works:

Most of our plugin outlets have a group passed into them, like this:
```haml
%outlet{name: "my-cool-outlet", group: "theGroup"}
```

If an outlet has a group associated with it, it will load experimental plugins for that group
_only if_ that group has opted into experiments (ie, `group.enable_experiments` is true)

More succinctly:
- If the outlet has a group with enable_experiments == true, it will load all components
- If the outlet has a group with enable_experiments == false, it will load only non-experimental plugin components
- If the outlet has no group, it will load all plugin components

###### But be careful!

Note that this affects _only_ the loading of components into plugin outlets. If you create an
experimental plugin, and it changes the way the API works, or user permissions, or how a class
behaves, those changes will take place across the entire instance.

### Add user permissions

For most of the actions that occur in Loomio, you'll want to ensure that the current user is able to perform that action. We use [cancan](), and store our permissions in the `app/models/ability.rb` file.

Unfortunately, overwriting this file directly isn't an option, but you can add new abilities by overriding the `add_additional_abilties` method, like so:

```ruby
plugin.extend_class Ability do
  def add_additional_abilties
    can :perform, Kickflip { |skater| skater.has_mad_skillz? }
  end
end
```

### Add tests
The official Loomio plugins will all have just the right amount of tests, and so can you!

Putting regular rspec tests into the `spec` folder will allow you to run tests for your plugins by executing `bundle exec rspec plugins` from the root folder.

```
/plugins
  /kickflip
    /spec
      /models
        kickflip_spec.rb
```

```ruby
# kickflip_spec.rb
describe Kickflip do
  it 'passes a test' do
    expect(true).to eq true
  end
end
```

`plugins` here is merely a path to run tests in, so you can be more specific with the files or individual specs you'd like to run, just like with the specs in core.

```bash
  bundle exec rspec plugins/kickflip/spec/models/kickflip_spec.rb:3
```

### Add factories

We use [FactoryGirl](https://github.com/thoughtbot/factory_girl) for our unit testing, which allows us to easily create minimum viable models to test with.

If you've created a new model, and want to test it (you do!) then it's a good idea to set up a factory
for it. This allows you to use things like `let(:kickflip) { create(:kickflip) }` in your tests, same
way we do in the core codebase.

To define a factory, use the `use_factory` command.

```ruby
plugin.use_factory(:kickflip) do
  user
  reaction "That was sweet!"
end
```

Note that this supports any syntax which would normally go into a `factory` block for FactoryGirl.
