Session       = require 'shared/services/session.coffee'
FlashService  = require 'shared/services/flash_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').factory 'RemoveMembershipForm', ['$rootScope', ($rootScope) ->
  templateUrl: 'generated/components/remove_membership_form/remove_membership_form.html'
  controller: ['$scope', 'membership', ($scope, membership) ->
    $scope.membership = membership

    $scope.submit = ->
      $scope.membership.destroy().then ->
        FlashService.success 'memberships_page.messages.remove_member_success', name: $scope.membership.userName()
        $scope.$close()
        if $scope.membership.user() == Session.user()
          LmoUrlService.goTo "/dashboard"
      , ->
        $rootScope.$broadcast 'pageError', 'cantDestroyMembership', $scope.membership
        $scope.$close()
  ]
]
