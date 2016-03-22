# Using development

See [Setup a Loomio development environment](setup_development_environment.md) for a step by step guide to setting up your computer to develop on Loomio. If you are familiar with the process of running rails apps you can just fork and clone the repo, `bundle install` then `rake db:setup`.

## Installing the frontend dependencies

The new javascript frontend is a [linemanjs](http://linemanjs.com/) project. Lineman is a bit behind current best practice, it'll likely be removed eventually. This is what you need to know:

You'll need bower and lineman installed:

  `$ npm install -g bower`  
  `$ npm install -g lineman`

Fetch the npm and bower dependencies:

  from within loomio/lineman/
  `$ npm install`  
  `$ bower install`

## Trying the new user interface in development mode
Run the rails development server

  `$ rails s`  

Then start lineman from the loomio/lineman folder  

  `$ lineman run`

We have links that can setup some fake data and log you in:

  http://localhost:8000/development/start_discussion

See the app/controllers/development_controller.rb for more.

My ‘my dev env is totally b0rked’ checklist:

- restart lineman
- restart rails
- run bower install
- run npm install
- weep
- actually look at the error message in lineman/browser console


## Updating to the latest loomio code
update your fork from loomio master.
assuming you're working on a branch: new-feature

```
g co master
g pull loomio master
g co new-feature
g merge master
```

We regularly change and update the node modules and bower dependencies.
If you just updated and things are broken then you need to

```
cd lineman
npm install
bower install
```

## Testing
We have rspec and cucumber tests on the rails app.

### Rspec and Cucumber for the rails app
We unit test the rails app with rspec, and have intregration tests of
the rails based UI in cucumber.

We also unit and e2e test the new javascript frontend.

### Jasmine and Protractor for the frontend

You can run the frontend unit tests with

  `$ lineman spec`

### Running e2e tests

If you don't have them already, install protractor and webdriver-manager:

  `$ npm install -g protractor`  
  `$ webdriver-manager update --standalone`  

Protractor e2e tests require rails, lineman and webdriver-manager to be
running at the same time:

  Start webdriver-manager from anywhere
  `$ webdriver-manager start`  

  Start rails from the loomio folder
  `$ rails s`

  Start lineman from loomio/lineman
  `$ lineman run`  

  Run the tests themselves from loomio/lineman
  `$ lineman grunt spec-e2e`

stub:
  start rails, lineman
  hit localhost:8000/development/setup_discussion
  list other development routes and what they are good for


## Halp! My environment is broken!

What to do when your developer environment breaks:

- restart lineman
- restart rails
- bundle install; npm install; bower install
- weep softly
- look at the actual error message in rails console or lineman run terminal windows.
