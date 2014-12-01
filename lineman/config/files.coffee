module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "files",
  ngtemplates:
    dest: "generated/angular/template-cache.js"

  css:
    app: ['app/css/main.css']
    vendor: ['vendor/bower_components/components-font-awesome/css/font-awesome.css',
             'vendor/bower_components/angular-bootstrap-datetimepicker/src/css/datetimepicker.css']

  js:
    vendor: ["vendor/bower_components/lodash/dist/lodash.js",
             "vendor/bower_components/moment/moment.js",
             "vendor/bower_components/jquery/dist/jquery.js",
             "vendor/bower_components/ng-file-upload/angular-file-upload-shim.js"
             "vendor/bower_components/angular/angular.js",
             "vendor/bower_components/angular-sanitize/angular-sanitize.js",
             "vendor/bower_components/angular-route/angular-route.js",
             "vendor/bower_components/angular-bootstrap-datetimepicker/src/js/datetimepicker.js",
             "vendor/bower_components/angular-translate/angular-translate.js",
             "vendor/bower_components/angular-translate-loader-url/angular-translate-loader-url.js",
             "vendor/bower_components/angular-bootstrap/ui-bootstrap.js",
             "vendor/bower_components/angular-bootstrap/ui-bootstrap-tpls.js",
             "vendor/bower_components/showdown/src/showdown.js",
             "vendor/bower_components/angular-markdown-directive/markdown.js",
             "vendor/bower_components/ng-file-upload/angular-file-upload.js",
             "vendor/bower_components/Chart.js/Chart.js",
             "vendor/bower_components/tc-angular-chartjs/dist/tc-angular-chartjs.js",
             "vendor/bower_components/ngInfiniteScroll/build/ng-infinite-scroll.js",
             "vendor/bower_components/ment.io/dist/mentio.js",
             "vendor/js/private_pub.js",
             "vendor/bower_components/angular-animate/angular-animate.js",
             "vendor/bower_components/lokijs/src/lokijs.js"]
    app: ["app/js/app.js"
          "app/js/**/*.js"]

  #webfonts:
    #vendor: ['vendor/bower_components/components-font-awesome/fonts/FontAwesome.otf',
             #'vendor/bower_components/components-font-awesome/fonts/fontawesome-webfont.eot',
             #'vendor/bower_components/components-font-awesome/fonts/fontawesome-webfont.svg',
             #'vendor/bower_components/components-font-awesome/fonts/fontawesome-webfont.ttf',
             #'vendor/bower_components/components-font-awesome/fonts/fontawesome-webfont.woff']
    #root: 'fonts'
