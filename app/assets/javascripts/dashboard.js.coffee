$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $('.motion-sparkline').sparkline('html', { type: 'pie', height: '26px', width: '26px', sliceColors: [ "#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc'], disableTooltips: 'true' })
