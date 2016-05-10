angular.module('loomioApp').controller 'ContactPageController', ($scope, UserAuthService, ContactMessageModel, ContactMessageService, FormService, Session) ->
  $scope.message = new ContactMessageModel(name: Session.user().name, email: Session.user().email)

  FormService.applyForm $scope, ContactMessageService.save, $scope.message
