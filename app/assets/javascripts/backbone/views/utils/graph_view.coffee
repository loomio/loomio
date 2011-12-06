Tautoko.Views.Utils ||= {}

class Tautoko.Views.Utils.GraphView extends Backbone.View

  initialize: (options)->
    if @options.type == 'pie'
      @buildPie()

  buildPie: ()->
    data = @options.data
    console.log data
    pie = jQuery.jqplot('graph', [data],
      {
        seriesDefaults: {
          renderer: jQuery.jqplot.PieRenderer,
          rendererOptions: {
            sliceMargin:8
          }
        },
        legend: { show:true, location: 'e' }
        grid: { background:'rgba(0,0,0,0)', shadow: false, borderWidth: 0 }

        seriesColors: [ "#90D490", "#D49090", "#F0BB67", "#FF0000", '#ccc']

      }
     )
     $('#graph').bind 'jqplotDataHighlight', (ev, seriesIndex, pointIndex, data)->
       $('#chartpseudotooltip').html(data[1] + '  votes')
       cssObj = {
         'position' : 'absolute',
         'left' : $(ev.currentTarget).offset().left + 230 + 'px',
         'top' : $(ev.currentTarget).offset().top + 35 +'px'
       }
       $('#chartpseudotooltip').css(cssObj).show()

     $('#graph').bind 'jqplotDataUnhighlight', (ev)->
       $('#chartpseudotooltip').html('').hide()

  
