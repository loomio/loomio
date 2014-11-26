describe('btfMarkdown', function () {
  var $compile,
      $rootScope;

  beforeEach(module('ngSanitize'));
  beforeEach(module('btford.markdown'));

  beforeEach(inject(function (_$compile_, _$rootScope_) {
    $compile = _$compile_;
    $rootScope = _$rootScope_;
  }));

  it('should work as an element', function () {
    var elt = angular.element('<btf-markdown>*hi*</btf-markdown>');
    $compile(elt)($rootScope);
    expect(elt.html()).toBe('<p><em>hi</em></p>');
  });

  it('should work as an attribute', function () {
    var elt = angular.element('<div btf-markdown>*hi*</div>');
    $compile(elt)($rootScope);
    expect(elt.html()).toBe('<p><em>hi</em></p>');
  });

  it('should work as an attribute with property', function () {
    var elt = angular.element('<div btf-markdown="hey"></div>');
    $compile(elt)($rootScope);
    expect(elt.html()).toBe('');

    $rootScope.hey = "*hi*";
    $rootScope.$apply();
    expect(elt.html()).toBe('<p><em>hi</em></p>');
  });

  it('should sanitize input', function () {
    var elt = angular.element('<btf-markdown><script>window.hacked = true;</script></btf-markdown>');
    $compile(elt)($rootScope);
    expect(elt.html()).toBe('<p>window.hacked = true;</p>');
    expect(window.hacked).toBeUndefined();
  });

});

describe('markdownConverterProvider', function () {
  var $compile,
      $rootScope;

  // module that adds config
  angular.module('testModule', []).
    config(function (markdownConverterProvider) {
      markdownConverterProvider.config({
        extensions: ['twitter']
      });
    });

  beforeEach(module('ngSanitize'));
  beforeEach(module('btford.markdown'));
  beforeEach(module('testModule'));

  beforeEach(inject(function (_$compile_, _$rootScope_) {
    $compile = _$compile_;
    $rootScope = _$rootScope_;
  }));

  it('should allow extensions', function () {
    var elt = angular.element('<btf-markdown>@briantford</btf-markdown>');
    $compile(elt)($rootScope);
    expect(elt.html()).toBe('<p><a href="http://twitter.com/briantford">@briantford</a></p>');
  })
})
