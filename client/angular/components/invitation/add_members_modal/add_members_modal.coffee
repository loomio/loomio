AppConfig      = require 'shared/services/app_config.coffee'
Records        = require 'shared/services/records.coffee'
FlashService   = require 'shared/services/flash_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ applyLoadingFunction } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').factory 'AddMembersModal', ->
  templateUrl: 'generated/components/invitation/add_members_modal/add_members_modal.html'
  controller: ['$scope', 'group', ($scope, group) ->
    $scope.isDisabled = false
    $scope.group = group
    $scope.loading = true
    $scope.selectedIds = []

    $scope.load = ->
      Records.memberships.fetchByGroup(group.parent().key, {per: group.parent().membershipsCount})
    applyLoadingFunction($scope, 'load')
    $scope.load()

    $scope.members = ->
      _.filter group.parent().members(), (user)->
        !user.isMemberOf(group)

    $scope.select = (member) ->
      if $scope.isSelected(member)
        _.pull $scope.selectedIds, member.id
      else
        $scope.selectedIds.push member.id

    $scope.isSelected = (member) ->
      _.contains $scope.selectedIds, member.id

    $scope.canAddMembers = ->
      $scope.members().length > 0

    $scope.reopenInvitationsForm = ->
       ModalService.open 'InvitationModal', group: -> $scope.group

    $scope.submit = ->
      $scope.isDisabled = true
      Records.memberships.addUsersToSubgroup
        groupId: $scope.group.id,
        userIds: $scope.selectedIds
      .then (data) ->
        if data.memberships.length == 1
          user = Records.users.find(_.first($scope.selectedIds))
          FlashService.success('add_members_modal.user_added_to_subgroup', name: user.name)
        else
          FlashService.success('add_members_modal.users_added_to_subgroup', count: data.memberships.length)
        $scope.$close()
      .finally ->
        $scope.isDisabled = false
  ]
