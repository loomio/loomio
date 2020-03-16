<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records  from '@/shared/services/records'
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext'
import { groupPrivacyConfirm } from '@/shared/helpers/helptext'
import Flash   from '@/shared/services/flash'
import { isEmpty, compact } from 'lodash'
import { onError } from '@/shared/helpers/form'
import openModal from '@/shared/helpers/open_modal'

export default
  props:
    parentId: Number
    close:
      type: Function
      default: ->
  data: ->
    group: null
    rules: {
      required: (value) -> !!value || 'Required.'
    }
    uploading: false
    progress: 0

  created: ->
    @group = Records.groups.build
      name: @$route.params.name
      parentId: @parentId
      customFields:
        pending_emails: compact((@$route.params.pending_emails || "").split(','))

  mounted: ->
    @suggestHandle()

  methods:
    submit: ->
      allowPublic = @group.allowPublicThreads
      @group.discussionPrivacyOptions = switch @group.groupPrivacy
        when 'open'   then 'public_only'
        when 'closed' then (if allowPublic then 'public_or_private' else 'private_only')
        when 'secret' then 'private_only'

      @group.parentMembersCanSeeDiscussions = switch @group.groupPrivacy
        when 'open'   then true
        when 'closed' then @group.parentMembersCanSeeDiscussions
        when 'secret' then false

      @group.save()
      .then (data) =>
        groupKey = data.groups[0].key
        Flash.success "group_form.messages.group_#{@actionName}"
        Records.groups.findOrFetchById(groupKey, {}, true).then (group) =>
          @close()
          @$router.push("/g/#{groupKey}")
          if group.isParent() && AppConfig.features.app.require_group_survey
            openModal
              component: 'GroupSurvey'
              props:
                group: group
      .catch onError(@group)

    suggestHandle: ->
      # if group is new, suggest handle whenever name changes
      # if group is old, suggest handle only if handle is empty
      if @group.isNew() or isEmpty(@group.handle)
        parentHandle = if @group.parent()
          @group.parent().handle
        else
          null
        Records.groups.getHandle(name: @group.name, parentHandle: parentHandle).then (data) =>
          @group.handle = data.handle

    privacyStringFor: (privacy) ->
      @$t groupPrivacy(@group, privacy),
        parent: @group.parentName()

  computed:
    actionName: ->
      if @group.isNew() then 'created' else 'updated'

    titleLabel: ->
      if @group.isParent()
        "group_form.group_name"
      else
        "group_form.subgroup_name"

    privacyOptions: ->
      if @group.isSubgroup() && @group.parent().groupPrivacy == 'secret'
        ['closed', 'secret']
      else
        ['open', 'closed', 'secret']

    privacyStatement: ->
      @$t groupPrivacyStatement(@group),
        parent: @group.parentName()

    groupNamePlaceholder: ->
      if @group.parentId
        'group_form.group_name_placeholder'
      else
        'group_form.organization_name_placeholder'

    groupNameLabel: ->
      if @group.parentId
        'group_form.group_name'
      else
        'group_form.organization_name'
</script>

<template lang="pug">
v-card.group-form
  v-overlay(:value="uploading")
    v-progress-circular(size="64" :value="progress")
  //- submit-overlay(:value='group.processing')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      .group-form__group-title
        h1.headline(v-if='group.parentId', v-t="'group_form.start_subgroup_heading'")
        h1.headline(v-if='!group.parentId', v-t="'group_form.start_organization_heading'")
      dismiss-modal-button(:close='close')
  v-card-text
    v-text-field.group-form__name#group-name(v-model='group.name', :placeholder="$t(groupNamePlaceholder)", :rules='[rules.required]', maxlength='255', :label="$t(groupNameLabel)" @keyup="suggestHandle()")
    validation-errors(:subject="group", field="name")

    div(v-if="!group.parent() || (group.parent() && group.parent().handle)")
      v-text-field.group-form__handle#group-handle(v-model='group.handle', :placeholder="$t('group_form.group_handle_placeholder')" maxlength='100' :label="$t('group_form.handle')")
      validation-errors(:subject="group", field="handle")

    .group-form__section.group-form__privacy
      v-radio-group(v-model='group.groupPrivacy')
        v-radio(v-for='privacy in privacyOptions' :key="privacy" :class="'md-checkbox--with-summary group-form__privacy-' + privacy" :value='privacy' :aria-label='privacy')
          template(slot='label')
            .group-form__privacy-title
              strong(v-t="'common.privacy.' + privacy")
              mid-dot
              span {{ privacyStringFor(privacy) }}
    p.group-form__privacy-statement.body-2 {{privacyStatement}}
    .group-form__section.group-form__joining.lmo-form-group(v-if='group.privacyIsOpen()')
      v-subheader(v-t="'group_form.how_do_people_join'")
      v-radio-group(v-model='group.membershipGrantedUpon')
        v-radio(v-for="granted in ['request', 'approval']" :key="granted" :class="'group-form__membership-granted-upon-' + granted" :value='granted')
          template(slot='label')
            span(v-t="'group_form.membership_granted_upon_' + granted")

  v-card-actions
    v-spacer
    v-btn.group-form__submit-button(:loading="group.processing" color="primary" @click='submit()')
      span(v-if='group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='!group.isParent()' v-t="'group_form.submit_start_subgroup'")
</template>
