AppConfig = require 'shared/services/app_config.coffee'
Raven = require('raven-js');

if AppConfig.sentry_dsn
  Raven.config(AppConfig.sentry_dsn)
       .addPlugin(require('raven-js/plugins/angular'), angular)
       .install();

module.exports = Raven
