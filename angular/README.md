# The Loomio 1.0 Angular app

Welcome to the Loomio 1.0 angular app! Here's a few things to know when working around here:

Before doing anything, run `npm install` in this folder. This will provide you with all the dependencies you need to run Loomio locally.

We build our frontend assets using [gulp](http://gulpjs.com/). Valid commands are:

- `gulp dev`: Build all assets and rebuild once changes are made (best for use while developing on Loomio)
- `gulp protractor`: Build all assets and run the [Protractor](https://angular.github.io/protractor/) tests.
- `gulp protractor:now`: Run all tests without building assets (If you haven't made any changes to the app, this is the way to go.)
- `gulp compile`: Build all assets and place them in the `public` folder

Asset building should take ~10 seconds at the first run, and ~3-6 seconds on subsequent builds.
