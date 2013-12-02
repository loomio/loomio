module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "files",
  ngtemplates:
    dest: "generated/angular/template-cache.js"

  js:
    vendor: ["vendor/bower_components/underscore/underscore.js"
             "vendor/bower_components/jquery/jquery.js"
             "vendor/bower_components/angular/angular.js"
             "vendor/bower_components/angular-route/angular-route.js"
             "vendor/js/**/*.js"]

    app: ["app/js/app.js"
          "app/js/**/*.js"]
