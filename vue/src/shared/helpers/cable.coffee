import ActionCable    from 'actioncable'
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import AuthService    from '@/shared/services/auth_service'
import AbilityService from '@/shared/services/ability_service'

import { hardReload } from '@/shared/helpers/window'
import { each } from 'lodash-es'

export subscribeTo = (model) ->
  switch model.constructor.singular
    when 'group' then subscribeToGroup(model)
    when 'poll'  then subscribeToPoll(model)

export initLiveUpdate = ->
  subscribeToApplication()

  if Session.isSignedIn()
    subscribeToUser()
    each Session.user().groups(), subscribeToGroup
  else
    subscribeToMembership()

subscribeToGroup = (group) ->
  ensureConnection().subscriptions.create { channel: "GroupChannel", group_id: group.id },
    received: (data) ->
      Records.import(data)

subscribeToUser = ->
  ensureConnection().subscriptions.create { channel: "UserChannel" },
    received: (data) ->
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
        Flash.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload

ensureConnection = ->
  AppConfig.cable = AppConfig.cable or ActionCable.createConsumer("/cable")
