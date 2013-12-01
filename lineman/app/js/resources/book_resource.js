angular.module("app").factory("BookResource", function($q, $resource) {
  return $resource('/books');
});
