angular.module('loomioApp').factory 'UserHelpService', ($sce, Session) ->
  new class UserHelpService

    helpLocale: ->
      switch Session.user().locale
        when 'es', 'an', 'ca', 'gl' then 'es'
        when 'zh-TW'                then 'zh'
        when 'ar'                   then 'ar'
        else 'en'

    helpLink: ->
      "https://loomio.gitbooks.io/manual/content/#{@helpLocale()}/index.html"

    helpVideo: ->
      switch Session.user().locale
        when 'es', 'an', 'ca', 'gl' then "https://www.youtube.com/embed/BT9f0Nj0zB8"
        else "https://www.youtube.com/embed/KS-_g437VD4"

    helpVideoUrl: ->
      $sce.trustAsResourceUrl(@helpVideo())

    tenTipsArticleLink: ->
      switch Session.user().locale
        when 'es', 'an', 'ca', 'gl' then "http://blog.loomio.org/2015/08/17/10-consejos-para-tomar-decisiones-con-loomio/"
        when 'fr'                   then "http://blog.loomio.org/2015/08/25/10-conseils-pour-prendre-de-grandes-decisions-grace-a-loomio/"
        else "https://blog.loomio.org/2015/09/10/10-tips-for-making-great-decisions-with-loomio/"

    nineWaysArticleLink: ->
      switch Session.user().locale
        when 'es', 'an', 'ca', 'gl' then "http://blog.loomio.org/2015/08/17/9-formas-de-utilizar-propuestas-en-loomio-para-convertir-conversaciones-en-accion/"
        when 'fr'                   then "https:////blog.loomio.org/2015/08/25/9-manieres-dutiliser-loomio-pour-transformer-une-conversation-en-actes/"
        else "https://blog.loomio.org/2015/09/18/9-ways-to-use-a-loomio-proposal-to-turn-a-conversation-into-action/"
