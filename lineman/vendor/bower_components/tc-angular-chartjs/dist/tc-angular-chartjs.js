/**
 * tc-angular-chartjs - v1.0.9 - 2014-10-14
 * Copyright (c) 2014 Carl Craig <carlcraig@3c-studios.com>
 * Dual licensed with the Apache-2.0 or MIT license.
 */
(function() {
    "use strict";
    angular.module("tc.chartjs", []).directive("tcChartjs", TcChartjs).directive("tcChartjsLine", TcChartjsLine).directive("tcChartjsBar", TcChartjsBar).directive("tcChartjsRadar", TcChartjsRadar).directive("tcChartjsPolararea", TcChartjsPolararea).directive("tcChartjsPie", TcChartjsPie).directive("tcChartjsDoughnut", TcChartjsDoughnut).directive("tcChartjsLegend", TcChartjsLegend).factory("TcChartjsFactory", TcChartjsFactory);
    function TcChartjs(TcChartjsFactory) {
        return new TcChartjsFactory();
    }
    TcChartjs.$inject = [ "TcChartjsFactory" ];
    function TcChartjsLine(TcChartjsFactory) {
        return new TcChartjsFactory("line");
    }
    TcChartjsLine.$inject = [ "TcChartjsFactory" ];
    function TcChartjsBar(TcChartjsFactory) {
        return new TcChartjsFactory("bar");
    }
    TcChartjsBar.$inject = [ "TcChartjsFactory" ];
    function TcChartjsRadar(TcChartjsFactory) {
        return new TcChartjsFactory("radar");
    }
    TcChartjsRadar.$inject = [ "TcChartjsFactory" ];
    function TcChartjsPolararea(TcChartjsFactory) {
        return new TcChartjsFactory("polararea");
    }
    TcChartjsPolararea.$inject = [ "TcChartjsFactory" ];
    function TcChartjsPie(TcChartjsFactory) {
        return new TcChartjsFactory("pie");
    }
    TcChartjsPie.$inject = [ "TcChartjsFactory" ];
    function TcChartjsDoughnut(TcChartjsFactory) {
        return new TcChartjsFactory("doughnut");
    }
    TcChartjsDoughnut.$inject = [ "TcChartjsFactory" ];
    function TcChartjsFactory() {
        return function(chartType) {
            var directive = {
                restrict: "A",
                scope: {
                    data: "=chartData",
                    options: "=chartOptions",
                    type: "@chartType",
                    legend: "=chartLegend",
                    chart: "=chart"
                },
                link: link
            };
            return directive;
            function link($scope, $elem, $attrs) {
                var ctx = $elem[0].getContext("2d");
                var chart = new Chart(ctx);
                var chartObj;
                var showLegend = false;
                var autoLegend = false;
                var exposeChart = false;
                var legendElem = null;
                for (var attr in $attrs) {
                    if (attr === "chartLegend") {
                        showLegend = true;
                    } else if (attr === "chart") {
                        exposeChart = true;
                    } else if (attr === "autoLegend") {
                        autoLegend = true;
                    }
                }
                $scope.$watch("data", function(value) {
                    if (value) {
                        if (chartObj) {
                            chartObj.destroy();
                        }
                        if (chartType) {
                            chartObj = chart[cleanChartName(chartType)]($scope.data, $scope.options);
                        } else if ($scope.type) {
                            chartObj = chart[cleanChartName($scope.type)]($scope.data, $scope.options);
                        } else {
                            throw "Error creating chart: Chart type required.";
                        }
                        if (showLegend) {
                            $scope.legend = chartObj.generateLegend();
                        }
                        if (autoLegend) {
                            if (legendElem) {
                                legendElem.remove();
                            }
                            angular.element($elem[0]).after(chartObj.generateLegend());
                            legendElem = angular.element($elem[0]).next();
                        }
                        if (exposeChart) {
                            $scope.chart = chartObj;
                        }
                    }
                }, true);
            }
            function cleanChartName(type) {
                var typeLowerCase = type.toLowerCase();
                switch (typeLowerCase) {
                  case "line":
                    return "Line";

                  case "bar":
                    return "Bar";

                  case "radar":
                    return "Radar";

                  case "polararea":
                    return "PolarArea";

                  case "pie":
                    return "Pie";

                  case "doughnut":
                    return "Doughnut";

                  default:
                    return type;
                }
            }
        };
    }
    function TcChartjsLegend() {
        var directive = {
            restrict: "A",
            scope: {
                legend: "=chartLegend"
            },
            link: link
        };
        return directive;
        function link($scope, $elem) {
            $scope.$watch("legend", function(value) {
                if (value) {
                    $elem.html(value);
                }
            }, true);
        }
    }
})();