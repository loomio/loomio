<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records  from '@/shared/services/records'
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext'
import { submitForm }          from '@/shared/helpers/form'
import { groupPrivacyConfirm } from '@/shared/helpers/helptext'
import { submitOnEnter }       from '@/shared/helpers/keyboard'
import GroupModalMixin from '@/mixins/group_modal'

export default
  mixins: [GroupModalMixin]
  props:
    group: Object
    close: Function
  data: ->
    isDisabled: false
    rules: {
      required: (value) ->
        !!value || 'Required.'
    }
    submit: null
    uploading: false
    progress: 0
  mounted: ->
    @submit = submitForm @, @group,
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
      successCallback: (data) =>
        @isExpanded = false
        groupKey = data.groups[0].key
        Records.groups.findOrFetchById(groupKey, {}, true).then (group) =>
          @closeModal()
          @$router.push("/g/#{groupKey}")
          setTimeout => @openGroupWizard(group)
  methods:
    expandForm: ->
      @isExpanded = true

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
</script>

<template lang="pug">
v-card.group-form
  v-overlay(:value="uploading")
    v-progress-circular(size="64" :value="progress")
  submit-overlay(:value='group.processing')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      .group-form__group-title
        h1.headline(v-if='group.parentId', v-t="'group_form.start_subgroup_heading'")
        h1.headline(v-if='!group.parentId', v-t="'group_form.start_group_heading'")
        //- h1.headline(v-if='!group.isNew()', v-t="'group_form.edit_group_heading'")
      dismiss-modal-button(:close='close')
  v-card-text
    v-text-field.group-form__name#group-name(v-model='group.name', :placeholder="$t('group_form.group_name_placeholder')", :rules='[rules.required]', maxlength='255', :label="$t('group_form.group_name')")
    validation-errors(:subject="group", field="name")

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
    v-btn.group-form__submit-button(color="primary" @click='submit()')
      span(v-if='group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='!group.isParent()' v-t="'group_form.submit_start_subgroup'")
</template>
