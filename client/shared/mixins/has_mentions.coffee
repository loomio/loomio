module.exports = new class HasMentions
  apply: (model, field) ->
    model["cooked#{_.capitalize(field)}" = ->
      _.each model.mentionedUsernames, (username) ->
        model[field] = model[field].replace(///@#{username}///g, "[[@#{username}]]")
      model[field]
