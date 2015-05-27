# Exports an object that defines
# *  all of the configuration needed by the projects'
# *  depended-on grunt tasks.
# *
# * You can find the parent object in: node_modules/lineman/config/application.coffee
#
module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "application",
  enableSass: true
  #enableAssetFingerprint: true

  server:
    apiProxy:
      enabled: true
      port: 3000

  loadNpmTasks: ["grunt-angular-templates", "grunt-concat-sourcemap", "grunt-ng-annotate", "grunt-haml", 'grunt-sass', 'grunt-cucumber', 'grunt-contrib-copy', 'grunt-exec']

  removeTasks:
    #dist: ['uglify']
    common: ["handlebars", "jst", 'less', 'pages', 'concat_sourcemap', 'pages:dev']

  prependTasks:
    dist: ["ngAnnotate"]
    common: ["haml", "ngtemplates", "exec:updateScss"]

  appendTasks:
    common: ["concat_sourcemap:css", "concat_sourcemap:app", "concat_sourcemap:vendor", "concat_sourcemap:spec"]

  uglify:
    options:
      mangle: false
    js:
      files:
        "dist/js/vendor.js": "generated/js/vendor.js"

  haml:
    dist:
      files: [
        expand: true
        cwd: "app/"
        src: "**/*.haml"
        dest: "generated/"
        ext: ".html"
      ]

  copy:
    dev:
      files:
        [
          expand: true
          cwd: 'vendor/bower_components/components-font-awesome/fonts'
          src: ['*.*']
          dest: 'generated/fonts'
        ]
    dist:
      files:
        [
          expand: true
          cwd: 'vendor/bower_components/components-font-awesome/fonts'
          src: ['*.*']
          dest: 'dist/fonts'
        ]

  exec:
    updateScss:
      command: 'ruby print_scss_includes.rb > modules.scss'
      cwd: 'app/css'

  sass:
    dist:
      files:
        'generated/css/main.css': 'app/css/main.scss'

    options:
      includePaths: ['vendor/bower_components/']

  ngtemplates:
    loomioApp:
      src: "generated/**/*.html"
      dest: "<%= files.ngtemplates.dest %>"

  # configuration for grunt-ngmin, this happens _after_ concat once, which is the ngmin ideal :)
  ngAnnotate:
    js:
      src: "<%= files.js.concatenated %>"
      dest: "<%= files.js.concatenated %>"

  # generates a sourcemap for js, specs, and css with inlined sources
  # grunt-angular-templates expects that a module already be defined to inject into
  # this configuration orders the template inclusion _after_ the app level module
  concat_sourcemap:
    options:
      sourcesContent: true

    css:
      src: ["<%= files.css.app %>", "<%= files.css.vendor %>"]
      dest: "generated/css/app.css"

    vendor:
      src: ["<%= files.js.vendor %>"]
      dest: "generated/js/vendor.js"

    app:
      src: ["<%= files.js.app %>", "<%= files.coffee.generated %>", "generated/angular/template-cache.js"]
      dest: "<%= files.js.concatenated %>"

    spec:
      src: ["<%= files.js.specHelpers %>", "<%= files.coffee.generatedSpecHelpers %>", "<%= files.js.spec %>", "<%= files.coffee.generatedSpec %>"]
      dest: "<%= files.js.concatenatedSpec %>"

  # configures grunt-watch-nospawn to listen for changes to
  # and recompile angular templates, also swaps lineman default
  # watch target concat with concat_sourcemap
  watch:
    ngtemplates:
      files: "app/**/*.haml"
      tasks: ["haml", "ngtemplates", "concat_sourcemap:app"]

    coffee:
      files: "<%= files.coffee.app %>"
      tasks: ["coffee", "concat_sourcemap:app"]

    appjs:
      files: ["<%= files.js.app %>"]
      tasks: ["concat_sourcemap:app"]

    vendorjs:
      files: ["<%= files.js.vendor %>"]
      tasks: ["concat_sourcemap:vendor"]

    jsSpecs:
      files: ["<%= files.js.specHelpers %>", "<%= files.js.spec %>"]
      tasks: ["concat_sourcemap:spec"]

    coffeeSpecs:
      files: ["<%= files.coffee.specHelpers %>", "<%= files.coffee.spec %>"]
      tasks: ["coffee", "concat_sourcemap:spec"]

    sass:
      files: ["<%= files.sass.vendor %>", "<%= files.sass.app %>"]
      tasks: ["exec:updateScss", "sass", "concat_sourcemap:css"]

    webfonts:
      files: "<%= files.webfonts.vendor %>"
      tasks: ["copy"]
