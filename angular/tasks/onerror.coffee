module.exports = (err) ->
  console.log(err) || @emit('end')
