Tautoko.Views.Utils ||= {}

class Tautoko.Views.Utils.GraphView extends Backbone.View

  initialize: (options)->
    if @options.type == 'pie'
      @buildPie()

  buildPie: ()->
    data = @options.data
    pie = jQuery.jqplot(@options.id_string, [data],
      {
        seriesDefaults: {
          renderer: jQuery.jqplot.PieRenderer,
          rendererOptions: {
            sliceMargin:8
            padding: 10
          }
        },
        legend: { show: @options.legend, location: 'e' }
        grid: { background:'rgba(0,0,0,0)', shadow: false, borderWidth: 0 }

        seriesColors: [ "#90D490", "#F0BB67", "#D49090", "#FF0000", '#ccc']

      }
     )
     #$('#' + @options.id_string).bind 'jqplotDataHighlight', (ev, seriesIndex, pointIndex, data)=>
       #$(@options.tooltip_selector).html(data[2] + " : " +data[1] + '  votes')
       #$container = $(ev.currentTarget).closest('.pie')
       #cssObj = {
         #'position' : 'absolute',
         #'left' : $container.offset().left + $container.width() / 2 - 77 +"px",
         #'top' : $container.offset().top
       #}
       #$(@options.tooltip_selector).css(cssObj).show()

     #$('#' + @options.id_string).bind 'jqplotDataUnhighlight', (ev)=>
       #$(@options.tooltip_selector).html('').hide()

     #conditional or extract out
     $('#expand_' + @options.id_string.split('_')[1]).hide()
     $("#motion_" + @options.motion_id).bind 'click', (e)=>
       e.stopPropagation()
       $container = $(e.currentTarget).closest('.motion')
       if $container.hasClass('last')
         cssObj = {
           'position' : 'absolute',
           'left' : $container.offset().left - 475 / 2 + 'px',#460 = span8
           'top' : $container.offset().top - 2 +'px',
           'z-index' : '100'
         }
        else
         cssObj = {
           'position' : 'absolute',
           'left' : $container.offset().left - 2 + 'px',
           'top' : $container.offset().top - 2 + 'px',
           'z-index' : '100'
         }
       $('#expand_' + @options.id_string.split('_')[1]).css(cssObj).toggle()
  
