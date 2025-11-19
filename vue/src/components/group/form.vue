<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import LmoUrlService from '@/shared/services/lmo_url_service';
import Records  from '@/shared/services/records';
import Flash   from '@/shared/services/flash';
import EventBus   from '@/shared/services/event_bus';
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext';
import { isEmpty, debounce } from 'lodash-es';

export default
{
  props: {
    group: Object
  },

  data() {
    return {
      groupUrl: (AppConfig.root_url + LmoUrlService.group(this.group)),
      tab: 'profile',
      isDisabled: false,
      rules: {
        required(value) {
          return !!value || 'Required.';
        }
      },
      uploading: false,
      progress: 0,
      hostname: AppConfig.theme.canonical_host,
      realGroup: Records.groups.find(this.group.id)
    };
  },

  mounted() {
    this.suggestHandle();
  },

  created() {
    this.suggestHandle = debounce(function() {
      // if group is new, suggest handle whenever name changes
      // if group is old, suggest handle only if handle is empty
      if (this.group.isNew() || isEmpty(this.group.handle)) {
        const parentHandle = this.group.parentId ?
          this.group.parent().handle
        :
          null;
        return Records.groups.getHandle({name: this.group.name, parentHandle}).then(data => {
          return this.group.handle = data.handle;
        });
      }
    }
    , 500);
  },

  methods: {
    submit() {
      if (this.group.groupPrivacy == 'open') {
        this.group.discussionPrivacyOptions = 'public_only';
      } else {
        this.group.discussionPrivacyOptions = 'private_only';
      }

      this.group.parentMembersCanSeeDiscussions = (() => { switch (this.group.groupPrivacy) {
        case 'open':   return true;
        case 'closed': return this.group.parentMembersCanSeeDiscussions;
        case 'secret': return false;
      } })();

      this.group.save().then(data => {
        this.isExpanded = false;
        const groupKey = data.groups[0].key;
        Flash.success(`group_form.messages.group_${this.actionName}`);
        EventBus.$emit('closeModal');
        this.$router.push(`/g/${groupKey}`);
      }).catch(error => {
        Flash.warning('poll_common_form.please_review_the_form');
        console.error(error);
      })
    },

    copyText(text) {
      navigator.clipboard.writeText(text).then(() => Flash.success('common.copied')
      , () => Flash.error('invitation_form.error'));
    },


    expandForm() {
      this.isExpanded = true;
    },

    privacyStringFor(privacy) {
      return this.$t(groupPrivacy(this.group, privacy),
        {parent: this.group.parentName()});
    },

    selectCoverPhoto() {
      return this.$refs.coverPhotoInput.click();
    },

    selectLogo() {
      return this.$refs.logoInput.click();
    },

    uploadCoverPhoto() {
      this.uploading = true;
      Records.groups.remote.onUploadSuccess = response => {
        Records.importJSON(response);
        this.uploading = false;
      };
      Records.groups.remote.upload(`${this.group.id}/upload_photo/cover_photo`, this.$refs.coverPhotoInput.files[0], {}, args => { return this.progress = (args.loaded / args.total) * 100; });
    },

    uploadLogo() {
      this.uploading = true;
      Records.groups.remote.onUploadSuccess = response => {
        Records.importJSON(response);
        this.uploading = false;
      };
      Records.groups.remote.upload(`${this.group.id}/upload_photo/logo`, this.$refs.logoInput.files[0], {}, args => { return this.progress = (args.loaded / args.total) * 100; });
    }
  },

  watch: {
    'group.groupPrivacy'(val) {
      if (this.group.groupPrivacy != 'open' && this.group.membershipGrantedUpon == 'request') {
        this.group.membershipGrantedUpon = 'approval';
      }
    }
  },

  computed: {
    cardTitle() {
      return this.group.parentId ? 'group_form.subgroup_settings' : 'group_form.group_settings'
    },

    membershipGrantedUponOptions() {
      if (this.group.groupPrivacy == 'open') {
        return ['request', 'approval', 'invitation']
      } else {
        return ['approval', 'invitation']
      }
    },

    actionName() {
      if (this.group.isNew()) { return 'created'; } else { return 'updated'; }
    },

    titleLabel() {
      if (this.group.isParent()) {
        return "group_form.group_name";
      } else {
        return "group_form.subgroup_name";
      }
    },

    privacyOptions() {
      if (this.group.parentId && (this.group.parent().groupPrivacy === 'secret')) {
        return ['closed', 'secret'];
      } else {
        return ['open', 'closed', 'secret'];
      }
    },

    privacyStatement() {
      return this.$t(groupPrivacyStatement(this.group),
        {parent: this.group.parentName()});
    },

    groupNamePlaceholder() {
      if (this.group.parentId) {
        return 'group_form.group_name_placeholder';
      } else {
        return 'group_form.organization_name_placeholder';
      }
    },

    groupNameLabel() {
      if (this.group.parentId) {
        return 'group_form.group_name';
      } else {
        return 'group_form.organization_name';
      }
    }
  }
};
</script>

<template lang="pug">
v-card.group-form(:title="$t(cardTitle)")
  template(v-slot:append)
    dismiss-modal-button(:model="group")

  v-card-subtitle
    v-tabs(v-model="tab" color="primary")
      v-tab(value="profile")
        span(v-t="'group_form.profile'")
      v-tab.group-form__privacy-tab(value="privacy")
        span(v-t="'group_form.privacy'")
      v-tab.group-form__permissions-tab(value="permissions")
        span(v-t="'group_form.permissions'")

  v-tabs-window(style="overflow-y: auto" v-model="tab")
    v-tabs-window-item(value="profile")
      v-overlay(v-model="uploading")
        .d-flex.justify-center.align-center
          v-progress-circular(:size="64" :value="progress")
      .pt-8.px-4
        v-img.group_form__file-select.rounded(cover :aspect-ratio="4/1" :src="realGroup.coverUrl" @click="selectCoverPhoto()")
        group-avatar.group_form__file-select.group_form__logo(:group="realGroup", :size="64" @click="selectLogo()")
        .v-input
          label.v-label.v-label--active.lmo-font-12px
            a(v-t="'group_form.change_cover_image'" @click="selectCoverPhoto()")
            space
            | (2048x512 px)
            space
            span(v-t="'common.or'")
            space
            a(v-t="'group_form.change_logo'" @click="selectLogo()")
            space
            | (256x256 px)
        v-text-field.group-form__name#group-name.mt-4(v-model='group.name', :placeholder="$t(groupNamePlaceholder)", :rules='[rules.required]' maxlength='255', :label="$t(groupNameLabel)")
        div(v-if="!group.parentId || (group.parentId && group.parent().handle)")
          v-text-field.group-form__handle#group-handle(
            v-model='group.handle'
            :hint="$t('group_form.group_handle_placeholder', {host: hostname, handle: group.handle})"
            maxlength='100'
            :label="$t('group_form.handle')"
          )
          validation-errors(:subject="group" field="handle")
        v-spacer

        input.d-none.change-picture-form__file-input(type="file" ref="coverPhotoInput" @change='uploadCoverPhoto' accept="image/png, image/jpeg, image/webp")
        input.d-none.change-picture-form__file-input(type="file" ref="logoInput" @change='uploadLogo' accept="image/png, image/jpeg, image/webp")

        lmo-textarea.group-form__group-description(:model='group' field="description", :placeholder="$t('group_form.description_placeholder')", :label="$t('group_form.description')")
        validation-errors(:subject="group" field="name")

    v-tabs-window-item(value="privacy")
      .mt-8.px-4
        .group-form__section.group-form__privacy
          v-radio-group(v-model='group.groupPrivacy')
            v-radio(
              v-for='privacy in privacyOptions'
              :key="privacy"
              :class="'group-form__privacy-' + privacy"
              :value='privacy'
              :aria-label='privacy'
            )
              template(v-slot:label)
                .group-form__privacy-title
                  strong(v-t="'common.privacy.' + privacy")
                  mid-dot
                  span {{ privacyStringFor(privacy) }}
          validation-errors(:subject="group" field="groupPrivacy")

        p.group-form__privacy-statement.text-medium-emphasis(v-if="group.groupPrivacy != 'secret'") {{privacyStatement}}
        .group-form__section.group-form__joining.lmo-form-group(v-if='group.groupPrivacy != "secret"')
          v-list-subheader(v-t="'group_form.how_do_people_join'")
          v-radio-group(v-model='group.membershipGrantedUpon')
            v-radio(
              v-for="granted in membershipGrantedUponOptions"
              :key="granted"
              :class="'group-form__membership-granted-upon-' + granted"
              :value='granted'
            )
              template(v-slot:label)
                span(v-t="'group_form.membership_granted_upon_' + granted")
        v-text-field(
          v-if="group.groupPrivacy != 'secret' && group.membershipGrantedUpon != 'invitation'"
          read-only
          :label="$t('group_form.share_this_url_with_people_who_want_to_join')"
          v-model="groupUrl"
        )
          template(v-slot:append-inner)
            v-tooltip(location="bottom")
              template(v-slot:activator="{ props }")
                v-btn.shareable-link-modal__copy(v-bind="props" icon variant="tonal" color="info" :title="$t('common.copy')" @click='copyText(groupUrl)' )
                  common-icon(name="mdi-content-copy")
              span(v-t="'invitation_form.copy_to_clipboard'")

        template(v-if="group.groupPrivacy != 'secret' && group.membershipGrantedUpon == 'approval'")
          v-textarea(
            :label="$t('group_form.request_to_join_prompt')"
            counter
            v-model="group.requestToJoinPrompt"
            :placeholder="$t('group_form.default_request_to_join_prompt')")
          validation-errors(:subject='group' field='requestToJoinPrompt')


    v-tabs-window-item(value="permissions")
      .mt-8.px-4.group-form__section.group-form__permissions
        p.text-body-2.pb-4.group-form__privacy-statement.text-medium-emphasis(v-t="'group_form.permissions_explaination'")
        v-checkbox.group-form__parent-members-can-see-discussions(hide-details v-model='group.parentMembersCanSeeDiscussions' v-if='group.parentId && group.privacyIsClosed()')
          template(v-slot:label)
            div
              span(v-t="{path: 'group_form.parent_members_can_see_discussions', args: {parent: group.parent().name}}")
              br
              span.text-caption(v-t="{path: 'group_form.parent_members_can_see_discussions_help', args: {parent: group.parent().name}}")
        v-checkbox.group-form__members-can-add-members(hide-details v-model='group.membersCanAddMembers')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_add_members'")
              br
              span.text-caption(v-t="'group_form.members_can_add_members_help'")
        v-checkbox.group-form__members-can-add-guests(hide-details v-model='group.membersCanAddGuests')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_add_guests'")
              br
              span.text-caption(v-t="'group_form.members_can_add_guests_help'")
        v-checkbox.group-form__members-can-announce(
          :label="$t('group_form.members_can_announce')"
          v-model='group.membersCanAnnounce'
          hide-details
        )
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_announce'")
              br
              span.text-caption(v-t="'group_form.members_can_announce_help'")
        v-checkbox.group-form__members-can-create-subgroups(hide-details v-model='group.membersCanCreateSubgroups' v-if='group.isParent()')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_create_subgroups'")
              br
              span.text-caption(v-t="'group_form.members_can_create_subgroups_help'")
        v-checkbox.group-form__members-can-start-discussions(hide-details v-model='group.membersCanStartDiscussions')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_start_discussions'")
              br
              span.text-caption(v-t="'group_form.members_can_start_discussions_help'")
        v-checkbox.group-form__members-can-edit-discussions(hide-details v-model='group.membersCanEditDiscussions')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_edit_discussions'")
              br
              span.text-caption(v-t="'group_form.members_can_edit_discussions_help'")
        v-checkbox.group-form__members-can-edit-comments(hide-details v-model='group.membersCanEditComments')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_edit_comments'")
              br
              span.text-caption(v-t="'group_form.members_can_edit_comments_help'")
        v-checkbox.group-form__members-can-delete-comments(hide-details v-model='group.membersCanDeleteComments')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_delete_comments'")
              br
              span.text-caption(v-t="'group_form.members_can_delete_comments_help'")
        v-checkbox.group-form__members-can-raise-motions(hide-details v-model='group.membersCanRaiseMotions')
          template(v-slot:label)
            div
              span(v-t="'group_form.members_can_raise_motions'")
              br
              span.text-caption(v-t="'group_form.members_can_raise_motions_help'")
        v-checkbox.group-form__allow-polls-without-discussions(hide-details v-model='group.canStartPollsWithoutDiscussion')
          template(v-slot:label)
            div
              span(v-t="'group_form.allow_polls_without_threads'")
              br
              span.text-caption(v-t="'group_form.allow_polls_without_threads_help'")
        v-checkbox.group-form__admins-can-edit-user-content(hide-details v-model='group.adminsCanEditUserContent')
          template(v-slot:label)
            div
              span(v-t="'group_form.admins_can_edit_user_content'")
              br
              span.text-caption(v-t="'group_form.admins_can_edit_user_content_help'")

  v-card-actions
    help-btn(path="en/user_manual/groups/settings")
    v-spacer
    v-btn.group-form__submit-button(color="primary" variant="tonal" @click='submit()')
      span(v-if='group.isNew() && group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='group.isNew() && !group.isParent()' v-t="'group_form.submit_start_subgroup'")
      span(v-if='!group.isNew()' v-t="'common.action.save_changes'")
</template>

<style lang="sass">
.lmo-font-12px
  font-size: 12px

.group_form__file-select
  cursor: pointer

.group_form__logo
  margin-left: 8px
  margin-top: -104px
  border-radius: 8px

</style>
