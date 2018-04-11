module.exports =
  buttonStyle: (selected) ->
    obj = {color: 'default-grey-900'}
    if selected
      obj['border-color'] = 'default-accent-300'
    else
      obj['border-color'] = 'default-grey-200'
    obj
