'use strict'

App = angular.module 'blogReader', []
 
App.controller "FeedCtrl", ["$scope", "$http", ($scope, $http) ->
  url = "//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=50&callback=JSON_CALLBACK&q=http://blog.loomio.org/feed/"
  
  $http.jsonp(url).success((data, status, headers, config) ->
    console.log data
    $scope.feed = {items: data.responseData.feed.entries}
  ).error (data, status, headers, config) ->
    console.error "Error fetching feed:", data
  return

]
