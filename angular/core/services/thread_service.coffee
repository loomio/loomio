angular.module('loomioApp').factory 'ThreadService', (Session, Records, ModalService, MuteExplanationModal, FlashService) ->
  new class ThreadService

    mute: (thread) ->
      if !Session.user().hasExperienced("mutingThread")
        Records.users.saveExperience("mutingThread")
        Records.users.updateProfile(Session.user()).then ->
          ModalService.open MuteExplanationModal, thread: -> thread
      else
        previousVolume = thread.volume()
        thread.saveVolume('mute').then =>
          FlashService.success "discussion.volume.mute_message",
            name: thread.title
          , 'undo', => @unmute(thread, previousVolume)

    unmute: (thread, previousVolume = 'normal') ->
      thread.saveVolume(previousVolume).then =>
        FlashService.success "discussion.volume.unmute_message",
          name: thread.title
        , 'undo', => @mute(thread)
