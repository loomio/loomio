AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').config ['$translateProvider', ($translateProvider) ->
  $translateProvider.useUrlLoader('/api/v1/translations')
                    .useSanitizeValueStrategy('escapeParameters')
                    .preferredLanguage(AppConfig.currentUserLocale || 'en')
]
