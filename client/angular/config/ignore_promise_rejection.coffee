angular.module('loomioApp').config ['$qProvider', ($qProvider) ->
  # if something is driving you totally nuts, try commenting this for more errors
  $qProvider.errorOnUnhandledRejections(false);
]
