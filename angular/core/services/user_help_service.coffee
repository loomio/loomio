angular.module('loomioApp').factory 'UserHelpService', (CurrentUser) ->
  new class UserHelpService

    helpLocale: ->
      switch CurrentUser.locale
        when 'es', 'an', 'ca', 'gl' then 'es'
        when 'zh-TW'                then 'zh'
        when 'ar'                   then 'ar'
        else 'en'

    helpLink: ->
      "https://loomio.gitbooks.io/manual/content/#{@helpLocale()}/index.html"
