angular.module('loomioApp').factory 'ModalService', ($modal, $rootScope) ->
  new class ModalService
    openModal: (name, options = {}) ->
      return console.log "Invalid modal name: #{name}" unless @modals[name]
      $rootScope.$broadcast 'modalOpened'
      $modal.open
        templateUrl: @modals[name].template
        controller:  @modals[name].controller
        resolve:     @setLocals name, options

    setLocals: (name, options) ->
      locals = {}
      _.each @modals[name].locals, (local) ->
        locals[local] = options[local]
      locals

    modals:
      invitePeople:
        template:   'generated/components/group_page/invitation_modal.html'
        controller: 'InvitationsModalController'
        locals:   ['group']
      startThread: 
        template:   'generated/components/thread_page/discussion_form/discussion_form.html'
        controller: 'DiscussionFormController'
        locals:   ['discussion']
      startGroup:
        template:   'generated/components/group_form/group_form.html'
        controller: 'GroupFormController'
        locals:  ['group']
      groupIntro:
        template:   'generated/components/group_page/group_intro_modal.html'
