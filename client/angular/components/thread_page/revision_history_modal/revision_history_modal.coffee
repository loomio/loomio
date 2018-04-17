angular.module('loomioApp').factory 'RevisionHistoryModal', ->
  templateUrl: 'generated/components/thread_page/revision_history_modal/revision_history_modal.html'
  controller:['$scope', 'model', ($scope,  model) ->
    $scope.model = model
    $scope.type = model.constructor.singular
    $scope.versionNumber = 0
    $scope.numberOfVersions = ->
      $scope.getVersionIndex().length

    $scope.mockVersionIndex = ["v1","v2","v3"]

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

    $scope.setNextRevision = ->
      if !$scope.isNewest()
        index = $scope.getVersionIndex()
        $scope.currentIndex += 1;
        $scope.version = $scope.getVersion(index[$scope.currentIndex])

    $scope.setPreviousRevision = ->
      if ! $scope.isOldest()
        index = $scope.getVersionIndex()
        $scope.currentIndex -= 1;
        $scope.version = $scope.getVersion(index[$scope.currentIndex])

    $scope.setOldestRevision = ->
      index = $scope.getVersionIndex()
      $scope.currentIndex = 0;
      $scope.version = $scope.getVersion(index[$scope.currentIndex])

    $scope.setLatestRevision = ->
      index = $scope.getVersionIndex()
      $scope.currentIndex = index.length-1;
      $scope.version = $scope.getVersion(index[$scope.currentIndex])

    $scope.initScope = do ->
      $scope.title =  _.capitalize $scope.type + " Revision History"
      $scope.currentIndex = 0;
      $scope.setLatestRevision();
  ]
