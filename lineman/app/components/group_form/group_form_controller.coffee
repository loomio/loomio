angular.module('loomioApp').controller 'GroupFormController', ($location, Records, FormService) ->

  @group = Records.groups.initialize()

  @onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  FormService.applyForm @, @group

  return