module.exports = new class HasMentions
  apply: (model, field) ->
    methodName = "cooked#{_.capitalize(field)}"
    fieldName  = "#{methodName}Value"
    model[methodName] = ->
      cooked = model[field]
      if model["#{field}Format"] == "md"
        _.each model.mentionedUsernames, (username) ->
          cooked = cooked.replace(///@#{username}///g, "[[@#{username}]]")
      cooked
