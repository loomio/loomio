angular.module('loomioApp').controller 'ContactPageController', ($scope, UserAuthService, ContactMessageModel, ContactMessageService, FormService, User) ->
  $scope.message = new ContactMessageModel(name: User.current().name, email: User.current().email)

  FormService.applyForm $scope, ContactMessageService.save, $scope.message
