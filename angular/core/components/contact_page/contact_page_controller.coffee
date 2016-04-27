angular.module('loomioApp').controller 'ContactPageController', ($scope, UserAuthService, ContactMessageModel, ContactMessageService, FormService, Session) ->
  $scope.message = new ContactMessageModel(name: Session.current().name, email: Session.current().email)

  FormService.applyForm $scope, ContactMessageService.save, $scope.message
