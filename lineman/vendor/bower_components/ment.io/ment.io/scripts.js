'use strict';

angular.module('mentio-demo', ['mentio', 'ngRoute'])

    .config(function($routeProvider) {
        $routeProvider
            .when('/', {
                templateUrl: 'examples.html',
                tab: 'examples',
                title: 'Ment.io examples'
            })
            .when('/documentation', {
                templateUrl: 'documentation.html',
                tab: 'documentation',
                title: 'Ment.io Documentation'
            })
            .when('/examples', {
                templateUrl: 'examples.html',
                tab: 'examples',
                title: 'Ment.io examples'
            });
    })

    .run(function ($rootScope) {
        $rootScope.$on('$routeChangeSuccess', function (event, current) {
            if (current.$$route) {
                $rootScope.title = current.$$route.title;
                $rootScope.tab = current.$$route.tab;
            }
        });
    })

    .controller('mentio-demo-ctrl', function ($scope, $rootScope, $http, $q, $sce, $timeout, mentioUtil) {

        $scope.macros = {
            'brb': 'Be right back',
            'omw': 'On my way',
            '(smile)' : '<img src="http://a248.e.akamai.net/assets.github.com/images/icons/emoji/smile.png"' +
                ' height="20" width="20">'
        };

        // shows the use of dynamic values in mentio-id and mentio-for to link elements
        $scope.myIndexValue = "5";

        $scope.searchProducts = function(term) {
            var prodList = [];

            return $http.get('productdata.json').then(function (response) {
                angular.forEach(response.data, function(item) {
                    if (item.title.toUpperCase().indexOf(term.toUpperCase()) >= 0) {
                        prodList.push(item);
                    }
                });

                $scope.products = prodList;
                return $q.when(prodList);
            });
        };

        $scope.searchPeople = function(term) {
            var peopleList = [];
            return $http.get('peopledata.json').then(function (response) {
                angular.forEach(response.data, function(item) {
                    if (item.name.toUpperCase().indexOf(term.toUpperCase()) >= 0) {
                        peopleList.push(item);
                    }
                });
                $scope.people = peopleList;
                return $q.when(peopleList);
            });
        };

        $scope.searchSimplePeople = function(term) {
            return $http.get('simplepeopledata.json').then(function (response) {
                $scope.simplePeople = [];
                angular.forEach(response.data, function(item) {
                    if (item.label.toUpperCase().indexOf(term.toUpperCase()) >= 0) {
                        $scope.simplePeople.push(item);
                    }
                });
            });
        };

        $scope.getProductText = function(item) {
            return '[~<strong>' + item.sku + '</strong>]';
        };

        $scope.getProductTextRaw = function(item) {
            var deferred = $q.defer();
            /* the select() function can also return a Promise which ment.io will handle
            propertly during replacement */
                    // simulated async promise              
            $timeout(function() {
                deferred.resolve('#' + item.sku);
            }, 500);
            return deferred.promise;
        };

        $scope.getPeopleText = function(item) {
            return '[~<i>' + item.name + '</i>]';
        };

        $scope.getPeopleTextRaw = function(item) {
            return '@' + item.name;
        };

        $scope.resetDemo = function() {
            // finally enter content that will raise a menu after everything is set up
            $timeout(function() {
                var html = "Try me @ or add a macro like brb, omw, (smile)";
                var htmlContent = document.querySelector('#htmlContent');
                if (htmlContent) {
                    var ngHtmlContent = angular.element(htmlContent);
                    ngHtmlContent.html(html);
                    ngHtmlContent.scope().htmlContent = html;
                    // select right after the @
                    mentioUtil.selectElement(htmlContent, [0], 8);
                    ngHtmlContent.scope().$apply();
                }
            }, 0);
        };

        $rootScope.$on('$routeChangeSuccess', function (event, current) {
            $scope.resetDemo();
        });
 
        $scope.theTextArea = 'Type an # and some text';
        $scope.theTextArea2 = 'Type an @';
        $scope.searchSimplePeople('');
        $scope.resetDemo();
    })

    .directive('contenteditable', ['$sce', function($sce) {
        return {
            restrict: 'A', // only activate on element attribute
            require: '?ngModel', // get a hold of NgModelController
            link: function(scope, element, attrs, ngModel) {
                function read() {
                    var html = element.html();
                    // When we clear the content editable the browser leaves a <br> behind
                    // If strip-br attribute is provided then we strip this out
                    if (attrs.stripBr && html === '<br>') {
                        html = '';
                    }
                    ngModel.$setViewValue(html);
                }

                if(!ngModel) return; // do nothing if no ng-model

                // Specify how UI should be updated
                ngModel.$render = function() {
                    if (ngModel.$viewValue !== element.html()) {
                        element.html($sce.getTrustedHtml(ngModel.$viewValue || ''));
                    }
                };

                // Listen for change events to enable binding
                element.on('blur keyup change', function() {
                    scope.$apply(read);
                });
                read(); // initialize
            }
        };
    }])
    .filter('words', function () {
        return function (input, words) {
            if (isNaN(words)) {
                return input;
            }
            if (words <= 0) {
                return '';
            }
            if (input) {
                var inputWords = input.split(/\s+/);
                if (inputWords.length > words) {
                    input = inputWords.slice(0, words).join(' ') + '\u2026';
                }
            }
            return input;
        };
    });
