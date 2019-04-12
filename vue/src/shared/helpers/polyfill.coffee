if !String::startsWith
  Object.defineProperty String.prototype, 'startsWith', value: (search, pos) ->
    @substr(if !pos or pos < 0 then 0 else +pos, search.length) == search
