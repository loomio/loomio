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
     $("#" + "expand_" + @options.motion_id).hide()
