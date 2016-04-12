angular.module('loomioApp').controller 'ExplorePageController', (Records, $rootScope) ->
  
  @query = ''

  @search = =>
    Records.groups.fetchExploreGroups(@query).then (object) =>
      @groupIds = _.map object.groups, (group) -> group.id
      @groups = Records.groups.find(@groupIds)
  @search()

  @groupCover = (group) ->
    { 'background-image': "url(#{group.coverUrl()})" }

  @groupDescription = (group) ->
    _.trunc group.description, 100 if group.description

  return
