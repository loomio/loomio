angular.module('loomioApp').controller 'HomePageRedirectController', ($router, $rootScope, $location, Records, LmoUrlService) ->
  $rootScope.$broadcast('currentComponent', 'homePageRedirect')

  if subdomain = $location.$$host.match(/^(.*)\.loomio\.org/)
    Records.groups.findOrFetchForSubdomain(subdomain[1]).then (group) =>
      if group?
        console.log "Navigating to: #{group.key}"
        subdomainGroup = LmoUrlService.group(group)
      else
        console.log "No subdomain for group found"

  $router.navigate(subdomainGroup or '/dashboard')

  return
