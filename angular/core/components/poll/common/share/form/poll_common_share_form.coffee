angular.module('loomioApp').directive 'pollCommonShareForm', ($translate, $location, AppConfig, FormService, Records, Session, FlashService, AbilityService, KeyEventService, LmoUrlService, ModalService, AddCommunityModal) ->
  scope: {poll: '=', back: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/form/poll_common_share_form.html'
