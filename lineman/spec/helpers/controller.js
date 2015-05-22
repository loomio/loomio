window.prepareController = function(spec, name, setupFn) {
  return inject(function($rootScope, $controller) {
    spec.$scope = $rootScope.$new()
    $controller('ThreadPageController', { $scope: spec.$scope });
    if (typeof setupFn === 'function') { setupFn(spec.$scope); }
    spec.$scope.$digest()
  })
}
