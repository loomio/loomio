angular.module('loomioApp').controller 'ExplorePageController', (Records, $rootScope) ->
  
  @query = null

  @search = =>
    Records.groups.fetchExploreGroups(@query).then (object) =>
      @groupIds = _.map object.groups, (group) -> group.id
      @groups = Records.groups.find(@groupIds)
  @search()

  @groupCover = (group) ->
    { 'background-image': "url(#{group.coverUrl()})" }

  return
