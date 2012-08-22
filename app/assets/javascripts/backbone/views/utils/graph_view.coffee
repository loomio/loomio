Loomio.Views.Utils ||= {}

class Loomio.Views.Utils.GraphView extends Backbone.View

  initialize: (options)->
    if @options.type == 'pie'
      @buildPie()

  buildPie: ()->
    data = @options.data
    pie = jQuery.jqplot(@options.id_string, [data],
      {
        title: {
          show: false,
        },
        gridPadding: {top:0, right:1, bottom:1, left:1}
        seriesDefaults: {
          renderer: jQuery.jqplot.PieRenderer,
          rendererOptions: {
            sliceMargin: @options.gap
            padding: @options.padding
            diameter: @options.diameter
            shadowOffset: @options.shadow
          }
        },
        legend: { show: @options.legend , location: 'e'}
        grid: { background:'rgba(0,0,0,0)', shadow: false, borderWidth: 0 }

        seriesColors: [ "#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc']

      }
     )
