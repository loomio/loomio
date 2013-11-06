#add_comment
#LoomioApp.directive 'add-comment', ->
  #restrict: 'E'
  #scope:
    #discussionId: '='
  #template: '/assets/discussion/add_comment.html'
  #replace: true
  #link: (scope, element, attrs) ->
    #scope.expand = ->
      #scope.isExpanded = true

    #scope.collapse = ->
      #scope.isExpanded = false

