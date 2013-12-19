module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "files",
  ngtemplates:
    dest: "generated/angular/template-cache.js"

  css:
    app: ['app/css/main.css']
    vendor: ['vendor/bower_components/ionicons/css/iconicons.css']

  js:
    vendor: ["vendor/bower_components/underscore/underscore.js"
             "vendor/bower_components/jquery/jquery.js"
             "vendor/bower_components/angular/angular.js"
             "vendor/bower_components/angular-route/angular-route.js"
             "vendor/js/**/*.js"]

    app: ["app/js/app.js"
          "app/js/**/*.js"]
