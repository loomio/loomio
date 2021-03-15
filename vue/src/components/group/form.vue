<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records  from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import EventBus   from '@/shared/services/event_bus'
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext'
import { groupPrivacyConfirm } from '@/shared/helpers/helptext'
import { isEmpty, some, debounce } from 'lodash'
import { onError } from '@/shared/helpers/form'

export default
  props:
    group: Object

  data: ->
    isDisabled: false
    rules: {
      required: (value) ->
        !!value || 'Required.'
    }
    uploading: false
    progress: 0

  mounted: ->
    @featureNames = AppConfig.features.group
    @suggestHandle()

  created: ->
    @suggestHandle = debounce ->
      # if group is new, suggest handle whenever name changes
      # if group is old, suggest handle only if handle is empty
      if @group.isNew() or isEmpty(@group.handle)
        parentHandle = if @group.parentId
          @group.parent().handle
        else
          null
        Records.groups.getHandle(name: @group.name, parentHandle: parentHandle).then (data) =>
          @group.handle = data.handle
    , 500

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

      @group.save().then (data) =>
        @isExpanded = false
        groupKey = data.groups[0].key
        Flash.success("group_form.messages.group_#{@actionName}")
        EventBus.$emit 'closeModal'
        @$router.push("/g/#{groupKey}")
      .catch onError(@group)


    expandForm: ->
      @isExpanded = true

    privacyStringFor: (privacy) ->
      @$t groupPrivacy(@group, privacy),
        parent: @group.parentName()

    selectCoverPhoto: ->
      @$refs.coverPhotoInput.click()

    selectLogo: ->
      @$refs.logoInput.click()

    uploadCoverPhoto: ->
      @uploading = true
      Records.groups.remote.onUploadSuccess = (response) =>
        Records.import response
        @uploading = false
      Records.groups.remote.upload("#{@group.id}/upload_photo/cover_photo", @$refs.coverPhotoInput.files[0], {}, (args) => @progress = args.loaded / args.total * 100)

    uploadLogo: ->
      @uploading = true
      Records.groups.remote.onUploadSuccess = (response) =>
        Records.import response
        @uploading = false
      Records.groups.remote.upload("#{@group.id}/upload_photo/logo", @$refs.logoInput.files[0], {}, (args) => @progress = args.loaded / args.total * 100)

  computed:
    actionName: ->
      if @group.isNew() then 'created' else 'updated'

    titleLabel: ->
      if @group.isParent()
        "group_form.group_name"
      else
        "group_form.subgroup_name"

    privacyOptions: ->
      if @group.parentId && @group.parent().groupPrivacy == 'secret'
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
  submit-overlay(:value='group.processing')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      .group-form__group-title
        h1.headline(tabindex="-1" v-if='group.parentId', v-t="'group_form.subgroup_settings'")
        h1.headline(tabindex="-1" v-if='!group.parentId', v-t="'group_form.group_settings'")
      dismiss-modal-button(:model="group")
  //- v-card-text
  v-tabs(fixed-tabs)
    v-tab(v-t="'group_form.profile'")
    v-tab.group-form__privacy-tab(v-t="'group_form.privacy'")
    v-tab.group-form__permissions-tab(v-t="'group_form.permissions'")
    v-tab.group-form__thread-defaults-tab(v-t="'common.threads'")

    v-tab-item
      .mt-8.px-4
        .v-input
          label.v-label.v-label--active.lmo-font-12px(v-t="'group_form.click_to_change_image'")
        v-img.group_form__file-select(:src="group.coverUrl()" width="100%"  @click="selectCoverPhoto()")
        group-avatar.group_form__file-select.group_form__logo.white(v-if="!group.parentId" :group="group" size="72px" :on-click="selectLogo" :elevation="4")
        v-text-field.group-form__name#group-name.mt-4(v-model='group.name', :placeholder="$t(groupNamePlaceholder)", :rules='[rules.required]', maxlength='255', :label="$t(groupNameLabel)")
        div(v-if="!group.parentId || (group.parentId && group.parent().handle)")
          v-text-field.group-form__handle#group-handle(v-model='group.handle', :hint="$t('group_form.group_handle_placeholder', {handle: group.handle})" maxlength='100' :label="$t('group_form.handle')")
          validation-errors(:subject="group" field="handle")
        v-spacer

        input.hidden.change-picture-form__file-input(type="file" ref="coverPhotoInput" @change='uploadCoverPhoto')
        input.hidden.change-picture-form__file-input(type="file" ref="logoInput" @change='uploadLogo')

        lmo-textarea.group-form__group-description(:model='group' field="description" :placeholder="$t('group_form.description_placeholder')" :label="$t('group_form.description')")
        validation-errors(:subject="group" field="name")

    v-tab-item
      .mt-8.px-4
        .group-form__section.group-form__privacy
          v-radio-group(v-model='group.groupPrivacy')
            v-radio(v-for='privacy in privacyOptions' :key="privacy" :class="'group-form__privacy-' + privacy" :value='privacy' :aria-label='privacy')
              template(slot='label')
                .group-form__privacy-title
                  strong(v-t="'common.privacy.' + privacy")
                  mid-dot
                  span {{ privacyStringFor(privacy) }}
        p.group-form__privacy-statement.text--secondary {{privacyStatement}}
        .group-form__section.group-form__joining.lmo-form-group(v-if='group.privacyIsOpen()')
          v-subheader(v-t="'group_form.how_do_people_join'")
          v-radio-group(v-model='group.membershipGrantedUpon')
            v-radio(v-for="granted in ['request', 'approval']" :key="granted" :class="'group-form__membership-granted-upon-' + granted" :value='granted')
              template(slot='label')
                span(v-t="'group_form.membership_granted_upon_' + granted")

    v-tab-item
      .mt-8.px-4.group-form__section.group-form__permissions
        p.group-form__privacy-statement.text--secondary(v-t="'group_form.permissions_explaination'")
        //- v-checkbox.group-form__allow-public-threads(hide-details v-model='group["allowPublicThreads"]' :label="$t('group_form.allow_public_threads')" v-if='group.privacyIsClosed() && !group.isSubgroupOfSecretParent()')
        v-checkbox.group-form__parent-members-can-see-discussions(hide-details v-model='group["parentMembersCanSeeDiscussions"]' v-if='group.parentId && group.privacyIsClosed()')
          template(v-slot:label)
            div
              span(v-t="{path: 'group_form.parent_members_can_see_discussions', args: {parent: group.parent().name}}")
              br
              span.caption(v-t="{path: 'group_form.parent_members_can_see_discussions_help', args: {parent: group.parent().name}}")
        v-checkbox.group-form__members-can-add-members(hide-details v-model='group["membersCanAddMembers"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_add_members'")
              br
              span.caption(v-t="'group_form.members_can_add_members_help'")
        v-checkbox.group-form__members-can-add-guests(hide-details v-model='group["membersCanAddGuests"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_add_guests'")
              br
              span.caption(v-t="'group_form.members_can_add_guests_help'")
        v-checkbox.group-form__members-can-announce(hide-details v-model='group["membersCanAnnounce"]' :label="$t('group_form.members_can_announce')")
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_announce'")
              br
              span.caption(v-t="'group_form.members_can_announce_help'")
        v-checkbox.group-form__members-can-create-subgroups(hide-details v-model='group["membersCanCreateSubgroups"]' v-if='group.isParent()')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_create_subgroups'")
              br
              span.caption(v-t="'group_form.members_can_create_subgroups_help'")
        v-checkbox.group-form__members-can-start-discussions(hide-details v-model='group["membersCanStartDiscussions"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_start_discussions'")
              br
              span.caption(v-t="'group_form.members_can_start_discussions_help'")
        v-checkbox.group-form__members-can-edit-discussions(hide-details v-model='group["membersCanEditDiscussions"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_edit_discussions'")
              br
              span.caption(v-t="'group_form.members_can_edit_discussions_help'")
        v-checkbox.group-form__members-can-edit-comments(hide-details v-model='group["membersCanEditComments"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_edit_comments'")
              br
              span.caption(v-t="'group_form.members_can_edit_comments_help'")
        v-checkbox.group-form__members-can-delete-comments(hide-details v-model='group["membersCanDeleteComments"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_delete_comments'")
              br
              span.caption(v-t="'group_form.members_can_delete_comments_help'")
        v-checkbox.group-form__members-can-raise-motions(hide-details v-model='group["membersCanRaiseMotions"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_raise_motions'")
              br
              span.caption(v-t="'group_form.members_can_raise_motions_help'")
        v-checkbox.group-form__admins-can-edit-user-content(hide-details v-model='group["adminsCanEditUserContent"]')
          template(v-slot:label)
            div
              span(v-t="'group_form.admins_can_edit_user_content'")
              br
              span.caption(v-t="'group_form.admins_can_edit_user_content_help'")

    v-tab-item
      .mt-8.px-4
        .group-form__section.group-form__defaults
          p.text--secondary(v-t="'group_form.thread_defaults_help'")
          v-card-subtitle(v-t="'thread_arrangement_form.sorting'")
          v-radio-group(v-model="group.newThreadsNewestFirst")
            v-radio(:value="false")
              template(v-slot:label)
                strong(v-t="'thread_arrangement_form.earliest'")
                space
                | -
                space
                span(v-t="'thread_arrangement_form.earliest_description'")

            v-radio(:value="true")
              template(v-slot:label)
                strong(v-t="'thread_arrangement_form.latest'")
                space
                | -
                space
                span(v-t="'thread_arrangement_form.latest_description'")

          v-subheader(v-t="'thread_arrangement_form.replies'")
          v-radio-group(v-model="group.newThreadsMaxDepth")
            v-radio(:value="1")
              template(v-slot:label)
                strong(v-t="'thread_arrangement_form.linear'")
                space
                | -
                space
                span(v-t="'thread_arrangement_form.linear_description'")
            v-radio(:value="2")
              template(v-slot:label)
                strong(v-t="'thread_arrangement_form.nested_once'")
                space
                | -
                space
                span(v-t="'thread_arrangement_form.nested_once_description'")
            //- v-radio(:value="3")
            //-   template(v-slot:label)
            //-     strong(v-t="'thread_arrangement_form.nested_twice'")
            //-     space
            //-     | -
            //-     space
            //-     span(v-t="'thread_arrangement_form.nested_twice_description'")

  v-card-actions
    v-spacer
    v-btn.group-form__submit-button(color="primary" @click='submit()')
      span(v-if='group.isNew() && group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='group.isNew() && !group.isParent()' v-t="'group_form.submit_start_subgroup'")
      span(v-if='!group.isNew()' v-t="'common.action.update_settings'")
</template>
<style lang="sass">
.lmo-font-12px
  font-size: 12px

.group_form__file-select
  cursor: pointer

.group_form__logo
  margin-left: 8px
  margin-top: -30px
  border-radius: 8px

</style>
