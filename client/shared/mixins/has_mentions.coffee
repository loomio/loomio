module.exports = new class HasMentions
  apply: (model, field) ->
    methodName = "cooked#{_.capitalize(field)}"
    fieldName  = "#{methodName}Value"
    model[methodName] = ->
      if @[fieldName]
        @[fieldName]
      else
      cooked = model[field]
      _.each model.mentionedUsernames, (username) ->
        cooked = cooked.replace(///@#{username}///g, "[[@#{username}]]")
      @[fieldName] = cooked
