# angular-markdown-directive [![Build Status](https://travis-ci.org/btford/angular-markdown-directive.png)](https://travis-ci.org/btford/angular-markdown-directive)

Bower Component for a simple AngularJS Markdown directive using [Showdown](https://github.com/coreyti/showdown). Based on [this excellent tutorial](http://blog.angularjs.org/2012/05/custom-components-part-1.html) by [@johnlinquist](https://twitter.com/johnlindquist).


## Usage
1. `bower install angular-markdown-directive`
2. Include `angular-sanitize.js`. It should be located at `bower_components/angular-sanitize/`.
3. Include `showdown.js`. It should be located at `bower_components/showdown/`.
4. Include `markdown.js` provided by this component into your app.
5. Add `btford.markdown` as a module dependency to your app.
6. Insert the `btf-markdown` directive into your template:

```html
<btf-markdown>
  #Markdown directive
  *It works!*
</btf-markdown>
```

You can also bind the markdown input to a scope variable:

```html
<div btf-markdown="markdown">
</div>
<!-- Uses $scope.markdown -->
```

Or include a markdown file:

```html
<div btf-markdown ng-include="'README.md'">
</div>
<!-- Uses content from README.md -->
```


## Options

You can configure the `markdownConverterProvider`:

```javascript
angular.module('myApp', [
  'ngSanitize',
  'btford.markdown'
]).
config(['markdownConverterProvider', function (markdownConverterProvider) {
  // options to be passed to Showdown
  // see: https://github.com/coreyti/showdown#extensions
  markdownConverterProvider.config({
    extensions: ['twitter']
  });
}])
```


## License
MIT
