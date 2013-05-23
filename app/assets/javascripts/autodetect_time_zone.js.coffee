$ ->
  tz = jstz.determine()

  if typeof(tz) == 'undefined'
    time_zone = 'undefined'
  else
    time_zone = tz.name()

  $.cookie('time_zone', time_zone, { path: "/" })
