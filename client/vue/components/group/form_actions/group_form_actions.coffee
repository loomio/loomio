Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'
I18n     = require 'shared/services/i18n'

{ scrollTo }            = require 'shared/helpers/layout'
{ submitForm }          = require 'shared/helpers/form'
{ groupPrivacyConfirm } = require 'shared/helpers/helptext'
{ submitOnEnter }       = require 'shared/helpers/keyboard'

module.exports =
  props:
    group: Object
  data: ->
    expanded: false
  methods:
    expandForm: ->
      @expanded = true
      scrollTo '.group-form__permissions', container: '.group-modal md-dialog-content'
  computed:
    actionName: ->
      if @group.isNew() then 'created' else 'updated'
  created: ->
    @submit = submitForm @, @group,
      skipClose: true
      prepareFn: =>
        allowPublic = @group.allowPublicThreads
        @group.discussionPrivacyOptions = switch @group.groupPrivacy
          when 'open'   then 'public_only'
          when 'closed' then (if allowPublic then 'public_or_private' else 'private_only')
          when 'secret' then 'private_only'

        @group.parentMembersCanSeeDiscussions = switch @group.groupPrivacy
          when 'open'   then true
          when 'closed' then @group.parentMembersCanSeeDiscussions
          when 'secret' then false
      confirmFn: (model)          -> I18n.t groupPrivacyConfirm(model)
      flashSuccess:               => "group_form.messages.group_#{@actionName}"
      successCallback: (response) =>
        group = Records.groups.find(response.groups[0].key)
        EventBus.emit @, 'nextStep', group
  template:
    """
    <div class="lmo-md-actions">
      <div v-if="expanded"></div>
      <button
        md-button
        type="button"
        v-if="!expanded"
        @click="expandForm()"
        v-t="'group_form.advanced_settings'"
        class="md-accent group-form__advanced-link"
      ></button>
      <button
        md-button
        @click="submit()"
        class="md-primary md-raised group-form__submit-button"
      >
        <span
          v-if="group.isNew() && group.isParent()"
          v-t="'group_form.submit_start_group'"
        ></span>
        <span
          v-if="group.isNew() && !group.isParent()"
          v-t="'group_form.submit_start_subgroup'"
        ></span>
        <span
          v-if="!group.isNew()"
          v-t="'common.action.update_settings'"
        ></span>
      </button>
    </div>
    """
