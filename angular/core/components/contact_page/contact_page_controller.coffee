angular.module('loomioApp').controller 'ContactPageController', ($scope, UserAuthService, ContactMessageModel, ContactMessageService, FormService, CurrentUser) ->
  currentUser = CurrentUser
  $scope.message = new ContactMessageModel(name: currentUser.name, email: currentUser.email)

  FormService.applyForm $scope, ContactMessageService.save, $scope.message
