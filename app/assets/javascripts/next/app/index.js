'use strict';

var app = angular.module('Application', ['ngRoute']);

app.controller('MainController', function($scope) {
    $scope.text = 'Hello World!';
});
