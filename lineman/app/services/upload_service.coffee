angular.module('loomioApp').factory 'UploadService', (FlashService)->
  new class UploadService

    upload: (files, action, successMessage, callback) ->
      if _.any files
        action(files[0]).then ->
          FlashService.success successMessage if successMessage?
          callback()                          if typeof callback is 'function'
