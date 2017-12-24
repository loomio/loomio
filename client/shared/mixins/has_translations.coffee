Session = require 'shared/services/session.coffee'

module.exports = new class HasMentions
  apply: (model) ->
    model.translate = ->
      model.recordStore.translations.fetchTranslation(model, Session.user().locale).then (data) ->
        model.translation = data.translations[0].fields
