angular.module('loomioApp').config ['$qProvider', ($qProvider) ->
    $qProvider.errorOnUnhandledRejections(false);
]
