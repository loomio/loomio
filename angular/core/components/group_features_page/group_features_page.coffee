angular.module('loomioApp').controller 'GroupFeaturesPageController', ($rootScope, $routeParams, $location, Records, FormService, AbilityService, LmoUrlService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupFeaturesPage', skipScroll: true }

  @newFeature = {}

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    if AbilityService.isSiteAdmin()
      @group = group
      @features = _.map group.features, (key, value) ->
        key: key
        value: value

      @submit = FormService.submit @, @group,
        submitFn: @group.updateFeatures
        flashSuccess: 'group_features_page.features_updated'
        prepareFn: =>
          features = {}
          _.each @features, (feature) -> features[feature.key] = feature.value
          @group.features = features
    else
      $location.path LmoUrlService.group(group)
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @removeFeature = (feature) ->
    _.pull @features, feature

  @addFeature = ->
    @features.push @newFeature
    @newFeature = {}

  @canAddFeature = ->
    @newFeature.key and
    @newFeature.value and
    !_.contains _.pluck(@features, 'key'), @newFeature.key

  return
