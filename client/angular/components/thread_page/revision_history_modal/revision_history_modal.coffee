angular.module('loomioApp').factory 'RevisionHistoryModal', ->
  templateUrl: 'generated/components/thread_page/revision_history_modal/revision_history_modal.html'
  controller:['$scope', 'model', ($scope,  model) ->
    $scope.model = model
    $scope.type = model.constructor.singular

    $scope.mockVersionIndex = [
      {id: "v1", createdAt: "two years ago"}
      {id: "v2"}
      {id: "v3"}
    ]

    $scope.mockVersions = {
      "v1" :{
        user: $scope.model.author(),
        createdAt: $scope.model.createdAt,
        itemId:$scope.model.id,
        itemType:'comment',
        changes:{
          'body':['the world is a mix of all sorts of rambling people, some of those without doubt the most interesting you will ever meet, there are those that when you first meet that they seem quite normal but once you get to know them are actually rather extraordinary ', 'the world is full of all sorts of crazy people, some of those are the most interesting you will ever meet, there are those that when you first meet that they seem quite normal but once you get to know them are actually rather extraordinary']
        }
      },
      "v2":{
        user: $scope.model.author(),
        createdAt: $scope.model.createdAt,
        itemId:$scope.model.id,
        itemType:'comment',
        changes:{
          'body':['hello', 'hello world']
        }
      },
      "v3":{
        user: $scope.model.author(),
        createdAt: $scope.model.createdAt,
        itemId:$scope.model.id,
        itemType:'comment',
        changes:{
          'body':['hello', 'hello world']
        }
      },
    }

    $scope.getVersionIndex = ->
      $scope.mockVersionIndex

    $scope.getVersion = (id) ->

      $scope.mockVersions[id]

    $scope.isOldest = ->
      $scope.currentIndex == 0;

    $scope.isNewest = ->
      $scope.currentIndex == $scope.getVersionIndex().length - 1

    $scope.refreshItems = ->
      #create the revision history modal depending on the kind of thing we are viewing the history of
      # goal is to create an array of items which are the blocks of text with the changes from the last version
      # optionally there is a heading to say which part of the item is being changed

    $scope.setNextRevision = ->
      index = $scope.getVersionIndex()
      $scope.currentIndex += 1;
      $scope.version = $scope.getVersion(index[$scope.currentIndex].id)

    $scope.setPreviousRevision = ->
      index = $scope.getVersionIndex()
      $scope.currentIndex -= 1;
      $scope.version = $scope.getVersion(index[$scope.currentIndex].id)

    $scope.setOldestRevision = ->
      index = $scope.getVersionIndex()
      $scope.currentIndex = 0;
      $scope.version = $scope.getVersion(index[$scope.currentIndex].id)

    $scope.setLatestRevision = ->
      index = $scope.getVersionIndex()
      $scope.currentIndex = index.length-1;
      $scope.version = $scope.getVersion(index[$scope.currentIndex].id)

    $scope.initScope = do ->
      $scope.title =  _.capitalize $scope.type + " Revision History"
      $scope.currentIndex = 0;
      $scope.setLatestRevision()
  ]
