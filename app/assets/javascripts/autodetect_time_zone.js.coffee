$ ->
  tz = jstz.determine()
  time_zone = if tz is undefined then 'undefined' else tz.name()
  document.cookie = "time_zone="+time_zone+"; path=/;"
