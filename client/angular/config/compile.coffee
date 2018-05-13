AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').config ['$compileProvider', ($compileProvider) ->
  # disable angular debug stuff in production
  $compileProvider.debugInfoEnabled(false) if AppConfig.environment == 'production'
]
