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
  actions: (pollTemplate, group) ->
    edit_default_template:
      name: 'poll_common.edit_template'
      icon: 'mdi-pencil'
      menu: true
      canPerform: -> !pollTemplate.id && group.adminsInclude(Session.user())
      to: "/poll_templates/new?template_key=#{pollTemplate.key}&group_id=#{group.id}"

    edit_template:
      name: 'poll_common.edit_template'
      icon: 'mdi-pencil'
      menu: true
      canPerform: -> pollTemplate.id && group.adminsInclude(Session.user())
      to: "/poll_templates/#{pollTemplate.id}/edit"

    discard:
      icon: 'mdi-eye-off'
      name: 'common.action.hide'
      menu: true
      canPerform: -> pollTemplate.id && !pollTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: ->
        Records.remote.post('poll_templates/discard', {group_id: group.id, id: pollTemplate.id}).then =>
          EventBus.$emit 'refreshPollTemplates'

    undiscard:
      icon: 'mdi-eye'
      name: 'common.action.unhide'
      menu: true
      canPerform: -> pollTemplate.id && pollTemplate.discardedAt && group.adminsInclude(Session.user())
      perform: ->
        Records.remote.post('poll_templates/undiscard', {group_id: group.id, id: pollTemplate.id}).then =>
          EventBus.$emit 'refreshPollTemplates'

    hide:
      icon: 'mdi-eye-off'
      name: 'common.action.hide'
      menu: true
      canPerform: -> 
        pollTemplate.key && group.adminsInclude(Session.user()) && !group.hiddenPollTemplates.includes(pollTemplate.key)
      perform: ->
        Records.remote.post('poll_templates/hide', {group_id: group.id, key: pollTemplate.key}).then =>
          EventBus.$emit 'refreshPollTemplates'

    unhide:
      icon: 'mdi-eye-off'
      name: 'common.action.unhide'
      menu: true
      canPerform: -> 
        pollTemplate.key && group.adminsInclude(Session.user()) && group.hiddenPollTemplates.includes(pollTemplate.key)
      perform: ->
        Records.remote.post('poll_templates/unhide', {group_id: group.id, key: pollTemplate.key}).then =>
          EventBus.$emit 'refreshPollTemplates'
