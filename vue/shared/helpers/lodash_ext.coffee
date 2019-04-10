module.exports =
  mod: (num, mod) ->
    if num >= 0
      num % mod
    else
      mod - (-num % mod)
