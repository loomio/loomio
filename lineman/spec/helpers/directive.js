window.prepareDirective = function(spec, name, options, setupFn) {
  return inject(function($compile, $rootScope) {
    parent = $rootScope.$new();
    if (typeof setupFn === 'function') { setupFn(parent); }

    var attributes = '';
    for(var key in options) {
      if (options.hasOwnProperty(key)) {
        attributes += ' ' + key + '="' + options[key] + '"';
      }
    }

    spec.$element = $compile(angular.element('<' + name + attributes + '></' + name + '>'))(parent);
    parent.$digest()

    spec.$scope = parent.$$childTail
  })
}