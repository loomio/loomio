Loomio.Views.Utils ||= {}

class Loomio.Views.Utils.InfoHelp extends Backbone.View
  initialize: ->
    @popoverShow()

  popoverShow: ->
    isVisible = false
    clickedAway = false
    that = this
    $(@el).each ->
      $(this).popover(html: true, trigger: 'manual', placement: 'top').click((e) ->
        console.log $(this)
        $(this).popover('show')
        isVisible = true
        e.preventDefault()
        that = this
      )
    $(document).click((e) ->
      if(isVisible & clickedAway)
        $(that).popover('hide')
        isVisible = clickedAway = false
      else
        clickedAway = true
    )
