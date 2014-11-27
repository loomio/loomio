# angular-file-upload-bower

bower distribution of [angular-file-upload](https://github.com/danialfarid/angular-file-upload).
All issues and pull request must be sumbitted to [angular-file-upload](https://github.com/danialfarid/angular-file-upload)

## Install

Install with `bower`:

```shell
bower install ng-file-upload
```

Add a `<script>` to your `index.html`:

```html
<script src="/bower_components/angular/angular-file-upload-shim.js"></script>
<!--only needed if you support upload progress/abort or non HTML5 FormData browsers.-->
<!-- NOTE: angular.file-upload-shim.js MUST BE PLACED BEFORE angular.js-->
<script src="/bower_components/angular/angular.js"></script>
<script src="/bower_components/angular/angular-file-upload.js"></script>
```
