module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "files",
  ngtemplates:
    dest: "generated/angular/template-cache.js"

  sass:
    main:  ['app/css/*.scss']
    app:   ['app/components/**/*.scss']

  css:
    app:    ['generated/css/main.css']
    vendor: ['vendor/bower_components/components-font-awesome/css/font-awesome.css']

  coffee:
    app: "app/**/*.coffee"

  js:
    vendor: ["vendor/bower_components/lodash/lodash.js",
             "vendor/bower_components/moment/moment.js",
             "vendor/bower_components/ng-file-upload/angular-file-upload-shim.js",
             "vendor/bower_components/angular/angular.js",
             "vendor/bower_components/angular-mocks/angular-mocks.js",
             "vendor/bower_components/angular-sanitize/angular-sanitize.js",
             "node_modules/loomio-angular-router/dist/router.es5.js",
             "vendor/bower_components/angular-translate/angular-translate.js",
             "vendor/bower_components/angular-translate-loader-url/angular-translate-loader-url.js",
             "node_modules/angular-ui-bootstrap/ui-bootstrap.js",
             "node_modules/angular-ui-bootstrap/ui-bootstrap-tpls.js",
             "vendor/bower_components/marked/lib/marked.js",
             "vendor/bower_components/angular-marked/angular-marked.js",
             "vendor/bower_components/ng-file-upload/angular-file-upload.js",
             "vendor/bower_components/ment.io/dist/mentio.js",
             "vendor/bower_components/angular-moment/angular-moment.js",
             "vendor/js/private_pub.js",
             "vendor/bower_components/angular-animate/angular-animate.js",
             "vendor/bower_components/lokijs/src/lokijs.js",
             "vendor/bower_components/angular-inview/angular-inview.js",
             "vendor/bower_components/angular-gravatar/build/angular-gravatar.js",
             "vendor/bower_components/angular-gravatar/build/md5.js",
             "vendor/bower_components/angular-truncate/src/truncate.js",
             "vendor/bower_components/angular-scroll/angular-scroll.js",
             "vendor/bower_components/svg.js/dist/svg.js",
             "vendor/bower_components/jstimezonedetect/jstz.js",
             "node_modules/angular_record_store/dist/standalone.js",
             "vendor/bower_components/angular-elastic/elastic.js",
             "vendor/bower_components/checklist-model/checklist-model.js",
             "vendor/bower_components/angular-clipboard/angular-clipboard.js"]
