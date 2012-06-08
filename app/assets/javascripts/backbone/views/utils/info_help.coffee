Loomio.Views.Utils ||= {}

class Loomio.Views.Utils.InfoHelp extends Backbone.View
  initialize: ->
    @visible = false
    @clickedAway = false
    @selector = []
    @getElClasses()
    @bindShowHandler()
    @bindHideHandler()

  # get all @el classes so we can hide everything on click
  getElClasses: ->
    classes = []
    $(@el).each ->
      classes.push "." + $(this).attr('class')
    classes = _.uniq classes
    @selector = classes.join ", "

  bindShowHandler: ->
    self = this
    $(@el).each ->
      $(this).popover(html: true, trigger: 'manual', placement: 'top').click (e) ->
        $(this).popover('show')
        self.visible = true
        e.preventDefault()

  bindHideHandler: ->
    self = this
    $(document).click (e) ->
      if(self.visible && self.clickedAway)
        $(self.selector).popover('hide')
        self.visible = self.clickedAway = false
      else
        self.clickedAway = true
