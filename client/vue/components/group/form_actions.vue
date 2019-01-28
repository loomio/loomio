<script lang="coffee">
Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ scrollTo }            = require 'shared/helpers/layout'
{ submitForm }          = require 'shared/helpers/form'
{ groupPrivacyConfirm } = require 'shared/helpers/helptext'
{ submitOnEnter }       = require 'shared/helpers/keyboard'

module.exports =
  props:
    group: Object
  # data: ->
  #   expanded: false
    successFn: Function
  methods:
    expandForm: ->
      Vue.set(@group, 'expanded', true) # probably a bad idea
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
      confirmFn: (model)          => @$t groupPrivacyConfirm(model)
      flashSuccess:               => "group_form.messages.group_#{@actionName}"
      successCallback: (response) =>
        group = Records.groups.find(response.groups[0].key)
        EventBus.$emit 'nextStep', group
        @successFn(group)
</script>

<template lang="pug">
  v-card-actions
    div(v-if='group.expanded')
    v-btn.group-form__advanced-link(flat color="accent", v-if='!group.expanded', @click='expandForm()', v-t="'group_form.advanced_settings'")
    v-btn.group-form__submit-button(flat color="primary", @click='submit()')
      span(v-if='group.isNew() && group.isParent()', v-t="'group_form.submit_start_group'")
      span(v-if='group.isNew() && !group.isParent()', v-t="'group_form.submit_start_subgroup'")
      span(v-if='!group.isNew()', v-t="'common.action.update_settings'")
</template>
