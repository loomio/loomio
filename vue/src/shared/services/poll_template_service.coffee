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

    add_favourite:
      icon: 'mdi-star'
      name: 'common.action.add_favourite'
      menu: true
      canPerform: -> group.adminsInclude(Session.user())
      to: "/p/new?template_id=#{pollTemplate.id}"

    remove_favourite:
      icon: 'mdi-star'
      name: 'common.action.remove_favourite'
      menu: true
      canPerform: -> group.adminsInclude(Session.user())
      to: "/p/new?template_id=#{pollTemplate.id}"
