angular.module('loomioApp').factory 'UserHelpService', ($sce, User) ->
  new class UserHelpService

    helpLocale: ->
      switch User.current().locale
        when 'es', 'an', 'ca', 'gl' then 'es'
        when 'zh-TW'                then 'zh'
        when 'ar'                   then 'ar'
        else 'en'

    helpLink: ->
      "https://loomio.gitbooks.io/manual/content/#{@helpLocale()}/index.html"

    helpVideo: ->
      switch User.current().locale
        when 'es', 'an', 'ca', 'gl' then "https://www.youtube.com/embed/BT9f0Nj0zB8"
        else "https://www.youtube.com/embed/CoYYNthNxOY"

    helpVideoUrl: ->
      $sce.trustAsResourceUrl(@helpVideo())
