import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash          from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import StanceService  from '@/shared/services/stance_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import i18n           from '@/i18n'
import { hardReload } from '@/shared/helpers/window'
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

export default new class PollTemplateService
  actions: (discussionTemplate, group) ->
    edit_default_template:
      name: 'poll_common.edit_template'
      icon: 'mdi-pencil'
      menu: true
      canPerform: -> !discussionTemplate.id && group.adminsInclude(Session.user())
      to: ->
        "/thread_templates/new?template_key=#{discussionTemplate.key}&group_id=#{group.id}&return_to=#{Session.returnTo()}"

    edit_template:
      name: 'poll_common.edit_template'
      icon: 'mdi-pencil'
      menu: true
      canPerform: -> discussionTemplate.id && group.adminsInclude(Session.user())
      to: ->
        "/thread_templates/#{discussionTemplate.id}?&return_to=#{Session.returnTo()}"

    move:
      name: 'common.action.move'
      icon: 'mdi-arrow-up-down'
      menu: true
      canPerform: -> !discussionTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: -> EventBus.$emit('sortThreadTemplates')

    discard:
      icon: 'mdi-eye-off'
      name: 'common.action.hide'
      menu: true
      canPerform: -> discussionTemplate.id && !discussionTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: ->
        Records.remote.post('discussion_templates/discard', {group_id: group.id, id: discussionTemplate.id})

    undiscard:
      icon: 'mdi-eye'
      name: 'common.action.unhide'
      menu: true
      canPerform: -> discussionTemplate.id && discussionTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: ->
        Records.remote.post('discussion_templates/undiscard', {group_id: group.id, id: discussionTemplate.id})

    destroy:
      icon: 'mdi-delete'
      name: 'common.action.delete'
      menu: true
      canPerform: -> discussionTemplate.id && group.adminsInclude(Session.user())
      perform: -> 
        openModal
          component: 'ConfirmModal',
          props:
            confirm:
              submit: ->
                discussionTemplate.destroy().then ->
                  EventBus.$emit('closeModal')
              text:
                title: 'common.are_you_sure'
                helptext: 'thread_template.confirm_delete'
                submit: 'common.action.delete'

    hide:
      icon: 'mdi-eye-off'
      name: 'common.action.hide'
      menu: true
      canPerform: -> 
        !discussionTemplate.id && discussionTemplate.key && !discussionTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: ->
        Records.remote.post('discussion_templates/hide', {group_id: group.id, key: discussionTemplate.key})

    unhide:
      icon: 'mdi-eye'
      name: 'common.action.unhide'
      menu: true
      canPerform: -> 
        !discussionTemplate.id && discussionTemplate.key && discussionTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: ->
        Records.remote.post('discussion_templates/unhide', {group_id: group.id, key: discussionTemplate.key})
