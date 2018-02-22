AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').config ['$qProvider', ($qProvider) ->
  # disable angular debug stuff in production
  $qProvider.errorOnUnhandledRejections(false);
]
