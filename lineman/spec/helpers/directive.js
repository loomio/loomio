window.prepareDirective = function(spec, name, setupFn) {
  return inject(function($compile, $rootScope) {
    spec.$scope = $rootScope.$new();
    if (typeof setupFn === 'function') {
      setupFn();
    }
    spec.$element = $compile('<' + name + '"></' + name + '>')(spec.$scope);
    spec.$scope.$digest()
  })
}