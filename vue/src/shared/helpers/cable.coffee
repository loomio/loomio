import ActionCable    from 'actioncable'
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import ModalService   from '@/shared/services/modal_service'
import FlashService   from '@/shared/services/flash_service'
import AuthService    from '@/shared/services/auth_service'
import AbilityService from '@/shared/services/ability_service'

import { hardReload } from '@/shared/helpers/window'

export subscribeTo = (model) ->
  switch model.constructor.singular
    when 'group' then subscribeToGroup(model)
    when 'poll'  then subscribeToPoll(model)

export initLiveUpdate = ->
  subscribeToApplication()

  if AbilityService.isLoggedIn()
    subscribeToUser()
    _.each Session.user().groups(), subscribeToGroup
  else
    subscribeToMembership()


subscribeToGroup = (group) ->
  ensureConnection().subscriptions.create { channel: "GroupChannel", group_id: group.id },
    received: (data) ->
      if data.memo?
        switch data.memo.kind
          when 'comment_destroyed'
            if comment = Records.comments.find(data.memo.data.comment_id)
              comment.destroy()
      Records.import(data)

subscribeToUser = ->
  ensureConnection().subscriptions.create { channel: "UserChannel" },
    received: (data) ->
      if data.action? && !AppConfig.loggingOut
        AppConfig.loggingOut = true
        ModalService.open 'ConfirmModal', confirm: ->
          submit:      Session.signOut
          forceSubmit: true
          text:
            title:    "signed_out_modal.title"
            helptext: "signed_out_modal.message"
      Records.import(data)

subscribeToMembership = ->
  return unless (AppConfig.pendingIdentity or {}).type == 'membership'
  ensureConnection().subscriptions.create { channel: "MembershipChannel", token: AppConfig.pendingIdentity.token },
    received: (data) ->
      switch data.action
        when 'accepted' then AuthService.signIn().then -> hardReload()

subscribeToPoll = (poll) ->
  ensureConnection().subscriptions.create { channel: "PollChannel", poll_id: poll.id },
    received: (data) -> Records.import(data)

subscribeToApplication = ->
  ensureConnection().subscriptions.create { channel: "ApplicationChannel" },
    received: (data) ->
      if data.version?
        FlashService.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload

ensureConnection = ->
  AppConfig.cable = AppConfig.cable or ActionCable.createConsumer("/cable")
