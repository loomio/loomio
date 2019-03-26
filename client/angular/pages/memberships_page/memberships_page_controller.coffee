Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
FlashService   = require 'shared/services/flash_service'
ModalService   = require 'shared/services/modal_service'

{ scrollTo } = require 'shared/helpers/layout'

$controller = ($routeParams, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { titleKey: 'memberships_page.members', page: 'membershipsPage'}

  @init = (group) =>
    return if @group? or !group?
    if AbilityService.canViewMemberships(group)
      @group = group
      Records.memberships.fetchByGroup(@group.key, per: @group.membershipsCount).then ->
        scrollTo("[data-username=#{$routeParams.username}]") if $routeParams.username?
    else
      EventBus.broadcast $rootScope, 'pageError', { status: 403 }, group

  @fetchMemberships = =>
    Records.memberships.fetchByNameFragment(@fragment, @group.key) if @fragment

  @canAdministerGroup = ->
    AbilityService.canAdministerGroup(@group)

  @canAddMembers = ->
    AbilityService.canAddMembers(@group)

  @canRemoveMembership = (membership) ->
    AbilityService.canRemoveMembership(membership)

  @canToggleAdmin = (membership) ->
    @canAdministerGroup(membership) and
    (!membership.admin or @canRemoveMembership(membership))

  @toggleAdmin = (membership) ->
    method = if membership.admin then 'makeAdmin' else 'removeAdmin'
    Records.memberships[method](membership).then ->
      FlashService.success "memberships_page.messages.#{_.snakeCase method}_success", name: membership.userName()

  @openRemoveForm = (membership) ->
    ModalService.open 'RemoveMembershipForm', membership: -> membership

  @invitePeople = ->
    ModalService.open 'InvitationModal', group: => @group

  filteredMemberships = =>
    if @fragment
      _.filter @group.memberships(), (membership) =>
        _.includes membership.userName().toLowerCase(), @fragment.toLowerCase()
    else
      @group.memberships()

  @memberships = ->
    _.sortBy filteredMemberships(), (membership) -> membership.userName()

  @name = (membership) ->
    membership.userName()

  Records.groups.findOrFetchById($routeParams.key).then @init, (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  return

$controller.$inject = ['$routeParams', '$rootScope']
angular.module('loomioApp').controller 'MembershipsPageController', $controller
