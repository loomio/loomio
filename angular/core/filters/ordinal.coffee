angular.module('loomioApp').filter 'ordinal', ->
  (integer) ->
    return "#{integer}th" if _.inRange parseInt(integer), 11, 14
    switch parseInt(integer) % 10
      when 1 then "#{integer}st"
      when 2 then "#{integer}nd"
      when 3 then "#{integer}rd"
      else        "#{integer}th"
