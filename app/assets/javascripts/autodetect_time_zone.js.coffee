$ ->
  tz = jstz.determine();

  if typeof(tz) == 'undefined'
    time_zone = 'undefined';
  else 
    time_zone = tz.name(); 

  $('input[name=javascript_time_zone]').val(time_zone)
