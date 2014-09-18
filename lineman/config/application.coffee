# Exports an object that defines
# *  all of the configuration needed by the projects'
# *  depended-on grunt tasks.
# *
# * You can find the parent object in: node_modules/lineman/config/application.coffee
#
module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "application",
  enableSass: true

  # html5push state simulation
  server:
    pushState: true

    apiProxy:
      enabled: true
      port: 3000
      prefix: 'api'

  loadNpmTasks: ["grunt-angular-templates", "grunt-concat-sourcemap", "grunt-ngmin", "grunt-haml", 'grunt-sass', 'grunt-cucumber', 'grunt-contrib-copy']

  removeTasks:
    common: ["handlebars", "jst", 'less', 'pages:dev']
    dev: ["pages:dev"]
    dist: ['pages:dev']

  prependTasks:
    dist: ["ngmin"] # ngmin should run in dist only
    common: ["haml", "ngtemplates"] # ngtemplates runs in dist and dev

  # swaps concat_sourcemap in place of vanilla concat
  appendTasks:
    common: ["concat_sourcemap"]

  cucumberjs:
    src: 'features/*.feature'
    options:
      steps: 'features/step_definitions'
      coffee: true

  haml:
    dist:
      language: 'coffee'
      target: 'html'
      files: [
        expand: true
        cwd: "app/templates/"
        src: "**/*.haml"
        dest: "generated/templates"
        ext: ".html"
       ,
        expand: true
        cwd: "app/pages/"
        src: "**/*.haml"
        dest: "generated/"
        ext: ".html"
      ]

  copy:
    common:
      files:
        [
          expand: true
          cwd: 'vendor/bower_components/font-awesome/fonts/'
          src: ['*']
          dest: 'generated/fonts'
          flatten: true
        ,
          expand: true
          cwd: 'vendor/bower_components/sass-bootstrap/fonts'
          src: ['*']
          dest: 'generated/fonts'
          flatten: true
        ]

  sass:
    common:
      files:
        'generated/css/main.css': 'app/css/main.scss'

    options:
      includePaths: ['vendor/bower_components/']


  ngtemplates:
    loomioApp:
      src: "generated/templates/**/*.html"
      dest: "generated/angular/template-cache.js"

  # configuration for grunt-ngmin, this happens _after_ concat once, which is the ngmin ideal :)
  ngmin:
    js:
      src: "<%= files.js.concatenated %>"
      dest: "<%= files.js.concatenated %>"

  # generates a sourcemap for js, specs, and css with inlined sources
  # grunt-angular-templates expects that a module already be defined to inject into
  # this configuration orders the template inclusion _after_ the app level module
  concat_sourcemap:
    options:
      sourcesContent: true

    js:
      src: ["<%= files.js.vendor %>", "<%= files.js.app %>", "<%= files.coffee.generated %>", "<%= files.ngtemplates.dest %>"]
      dest: "<%= files.js.concatenated %>"

    spec:
      src: ["<%= files.js.specHelpers %>", "<%= files.coffee.generatedSpecHelpers %>", "<%= files.js.spec %>", "<%= files.coffee.generatedSpec %>"]
      dest: "<%= files.js.concatenatedSpec %>"

    css:
      src: ["<%= files.sass.generatedVendor %>", "<%= files.css.vendor %>", "<%= files.sass.generatedApp %>", "<%= files.css.app %>"]
      dest: "<%= files.css.concatenated %>"

  # configures grunt-watch-nospawn to listen for changes to
  # and recompile angular templates, also swaps lineman default
  # watch target concat with concat_sourcemap
  watch:
    ngtemplates:
      files: "app/templates/**/*.haml"
      tasks: ["haml", "ngtemplates", "concat_sourcemap:js"]

    js:
      files: ["<%= files.js.vendor %>", "<%= files.js.app %>"]
      tasks: ["concat_sourcemap:js"]

    coffee:
      files: "<%= files.coffee.app %>"
      tasks: ["coffee", "concat_sourcemap:js"]

    jsSpecs:
      files: ["<%= files.js.specHelpers %>", "<%= files.js.spec %>"]
      tasks: ["concat_sourcemap:spec"]

    coffeeSpecs:
      files: ["<%= files.coffee.specHelpers %>", "<%= files.coffee.spec %>"]
      tasks: ["coffee", "concat_sourcemap:spec"]

    sass:
      files: ["<%= files.sass.vendor %>", "<%= files.sass.app %>"]
      tasks: ["sass", "concat_sourcemap:css"]

    pages:
      files: "app/pages/**/*.haml"
      tasks: ["haml"]

    webfonts:
      files: "<%= files.webfonts.vendor %>"
      tasks: ["webfonts:dev"]
