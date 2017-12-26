AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').config ($compileProvider) ->
  # disable angular debug stuff in production
  $compileProvider.debugInfoEnabled(false) if AppConfig.environment == 'production'
