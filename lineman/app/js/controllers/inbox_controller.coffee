angular.module('loomioApp').controller 'InboxController', ($scope, InboxService, UserAuthService) ->

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned

  $scope.openInbox = ->
    UserAuthService.inboxPinned = true
    console.log UserAuthService.inboxPinned

  $scope.closeInbox = ->
    UserAuthService.inboxPinned = false
    console.log UserAuthService.inboxPinned

  #$scope.images = [1, 2, 3, 4, 5, 6, 7, 8];
  #$scope.moreImages = ->
    #console.log 'more images'
    #_.times 8, ->
      #last = $scope.images[$scope.images.length - 1]
      #$scope.images.push(last + 1)

  InboxService.fetchPage 1, (discussions) ->
    $scope.discussions = discussions

  #$scope.discussions = []
  #$scope.getNextPage = ->
    #console.log 'get next page'
    #InboxService.fetchPage nextPage, (discussions) ->
      #console.log "fetched page: #{nextPage}"
      #_.each discussions, (discussion) ->
        #$scope.discussions.push discussion
      #nextPage = nextPage + 1

  #$scope.logDiscussions = ->
    #console.log $scope.discussions.length

