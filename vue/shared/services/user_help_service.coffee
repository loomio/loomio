Session = require 'shared/services/session'

module.exports = new class UserHelpService
  helpLocale: ->
    'en'
    # switch Session.user().locale
    #   when 'es', 'an', 'ca', 'gl' then 'es'
    #   when 'zh-TW'                then 'zh'
    #   when 'ar'                   then 'ar'
    #   when 'fr'                   then 'fr'
    #   else 'en'

  helpLink: ->
    "https://help.loomio.org/#{@helpLocale()}/"
