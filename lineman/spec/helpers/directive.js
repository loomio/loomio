window.prepareDirective = function(spec, name, setupFn) {
  return inject(function($compile, $rootScope) {
    parent = $rootScope.$new();
    if (typeof setupFn === 'function') { setupFn(parent); }
    spec.$element = $compile(angular.element('<' + name + ' discussion="discussion"></' + name + '>'))(parent);
    parent.$digest()

    spec.$scope = parent.$$childTail
  })
}