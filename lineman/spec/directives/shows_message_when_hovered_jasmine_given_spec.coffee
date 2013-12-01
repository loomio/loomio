describe "directive: shows-message-when-hovered (jasmine-given, coffeescript)", ->

  Given -> module("app")

  Given inject ($rootScope, $compile) ->
    @directiveMessage = 'ralph was here'
    @html = "<div shows-message-when-hovered message='#{@directiveMessage}'></div>"
    @scope = $rootScope.$new()
    @scope.message = @originalMessage = 'things are looking grim'
    @elem = $compile(@html)(@scope)

  describe "when a user mouses over the element", ->
    When -> @elem.triggerHandler('mouseenter')
    Then "the message on the scope is set to the message attribute of the element", ->
      @scope.message == @directiveMessage

  describe "when a users mouse leaves the element", ->
    When -> @elem.triggerHandler('mouseleave')
    Then "the message is reset to the original message", ->
      @scope.message == @originalMessage


