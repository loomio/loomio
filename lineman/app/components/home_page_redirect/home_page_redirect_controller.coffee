angular.module('loomioApp').controller 'HomePageRedirectController', ($router, $rootScope, $location, Records, LmoUrlService) ->
  $rootScope.$broadcast('currentComponent', 'homePageRedirect')

  nextPage =
    if subdomain = $location.$$host.match(/^(.*)\.loomio\.org/)
      Records.groups.findOrFetchForSubdomain(subdomain[1]).then (group) =>
        if group?
          console.log "Navigating to: #{group.key}"
          $router.navigate LmoUrlService.group(group)
        else
          console.log "No subdomain for group found"
          $rootScope.broadCast 'pageError', 'well that sucked.'
    else
      '/dashboard'
  $router.navigate(nextPage)

  return
