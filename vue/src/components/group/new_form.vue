<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records  from '@/shared/services/records';
import EventBus  from '@/shared/services/event_bus';
import Session  from '@/shared/services/session';
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext';
import { groupPrivacyConfirm } from '@/shared/helpers/helptext';
import Flash   from '@/shared/services/flash';
import { isEmpty, debounce } from 'lodash-es';
import openModal from '@/shared/helpers/open_modal';
import { I18n } from '@/i18n';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default
{
  mixins: [WatchRecords, UrlFor],
  props: {
    group: Object
  },

  data() {
    return {
      rules: {
        required(value) { return !!value || 'Required.'; }
      },
      hostname: AppConfig.theme.canonical_host,
      parentGroups: [],
      loadingHandle: false
    };
  },

  created() {
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: records => {
        this.parentGroups = [{value: null, title: this.$t('common.none')}];
        this.parentGroups = this.parentGroups.concat(Session.user().parentGroups().
          filter(g => AbilityService.canCreateSubgroups(g)).
          map(g => ({
          value: g.id,
          title: g.name
        }))
        );
      }
    });

    this.suggestHandle = debounce(function() {
      // if group is new, suggest handle whenever name changes
      // if group is old, suggest handle only if handle is empty
      if (this.group.isNew() || isEmpty(this.group.handle)) {
        this.loadingHandle = true;
        const parentHandle = this.group.parentId ? this.group.parent().handle : null;
        Records.groups.getHandle({name: this.group.name, parentHandle}).then(data => {
          this.group.handle = data.handle;
          this.loadingHandle = false;
        });
      }
    } , 250);
  },

  mounted() {
    return this.suggestHandle();
  },

  watch: {
    'group.parentId'() {
      this.group.handle = '';
      this.group.name = '';
    }
  },

  methods: {
    submit() {
      this.group.discussionPrivacyOptions = (() => { switch (this.group.groupPrivacy) {
        case 'open':   return 'public_only';
        case 'closed': return 'private_only';
        case 'secret': return 'private_only';
      } })();

      this.group.parentMembersCanSeeDiscussions = (() => { switch (this.group.groupPrivacy) {
        case 'open':   return true;
        case 'closed': return this.group.parentMembersCanSeeDiscussions;
        case 'secret': return false;
      } })();

      this.group.save().then(data => {
        const groupKey = data.groups[0].key;
        Flash.success(`group_form.messages.group_${this.actionName}`);
        Records.groups.findOrFetchById(groupKey, {}, true).then(group => {
          EventBus.$emit('closeModal');
          this.$router.push(`/g/${groupKey}`);
          if (!this.group.parentId) { Records.users.saveExperience('hideOnboarding', false) }
        });
      }).catch(error => true);
    },

    privacyStringFor(privacy) {
      return this.$t(groupPrivacy(this.group, privacy),
        {parent: this.group.parentName()});
    }
  },

  computed: {
    categoryItems() {
      // ['board', 'community', 'coop', 'membership', 'nonprofit', 'party', 'professional', 'self_managing', 'union', 'other'].map (category) ->
      return ['board', 'membership', 'self_managing', 'other'].map(category => ({
        title: I18n.global.t('group_survey.categories.'+category),
        value: category
      }));
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
        return 'group_form.subgroup_name_placeholder';
      } else {
        return 'group_form.organization_name_placeholder';
      }
    },

    groupNameLabel() {
      if (this.group.parentId) {
        return 'group_form.subgroup_name';
      } else {
        return 'group_form.group_name';
      }
    },

    submitIsDisabled() {
      return !this.group.name || (this.group.parentId && !this.group.parent().subscription.allow_subgroups) || (!this.group.parentId && !this.group.category)
    },

    showUpgradeAlert() {
      return (this.group.parentId && !this.group.parent().subscription.allow_subgroups)
    }
  }
};
</script>

<template lang="pug">
v-card.group-form(:title="group.parentId ? $t('group_form.start_subgroup_heading') : $t('group_form.start_group_heading')")
  .px-4
    p.text-medium-emphasis.pb-8
      span(v-if='!group.parentId')
        span(v-t="'group_form.new_group_explainer'")
        space
        help-link(path="user_manual/groups/starting_a_group")
      span(v-else)
        span(v-t="'group_form.new_subgroup_explainer'")
        space
        help-link(path="user_manual/groups/subgroups")

    v-select.group-form__parent-group(v-if="parentGroups.length > 1" v-model='group.parentId' :items="parentGroups" :label="$t('group_form.parent_group')")
    v-alert.mb-4(v-if="showUpgradeAlert" color="error" variant="tonal")
      span(v-html="$t('group_form.upgrade_for_subgroups', {parent: group.parent().name})")
    v-text-field.group-form__name#group-name(
      v-model='group.name'
      :placeholder="$t(groupNamePlaceholder)"
      :rules='[rules.required]'
      maxlength='255'
      :label="$t(groupNameLabel)"
      @keyup="suggestHandle()")
    validation-errors(:subject="group", field="name")

    div(v-if="!group.parentId || (group.parentId && group.parent().handle)")
      v-text-field.group-form__handle#group-handle(:loading="loadingHandle" v-model='group.handle' :hint="$t('group_form.group_handle_placeholder', {host: hostname, handle: group.handle})" maxlength='100' :label="$t('group_form.handle')")
      validation-errors(:subject="group", field="handle")

    v-select.group-form__category-select(v-if='!group.parentId' v-model="group.category" :items="categoryItems" :label="$t('group_survey.describe_other')")

    lmo-textarea.group-form__group-description(
      :model='group'
      field="description"
      :placeholder="$t('group_form.new_description_placeholder')"
      :label="$t('group_form.description')")

    div(v-if="group.parentId")
      .group-form__section.group-form__privacy
        v-radio-group(v-model='group.groupPrivacy' :label="$t('common.privacy.privacy')")
          v-radio(v-for='privacy in privacyOptions' :key="privacy" :class="'md-checkbox--with-summary group-form__privacy-' + privacy" :value='privacy' :aria-label='privacy')
            template(v-slot:label)
              .group-form__privacy-title
                strong.text-high-emphasis(v-t="'common.privacy.' + privacy")
                mid-dot.text-medium-emphasis
                span.text-medium-emphasis {{ privacyStringFor(privacy) }}

      p.group-form__privacy-statement.text-body-small.text-medium-emphasis {{privacyStatement}}
      .group-form__section.group-form__joining.lmo-form-group(v-if='group.privacyIsOpen()')
        v-list-subheader(v-t="'group_form.how_do_people_join'")
        v-radio-group(v-model='group.membershipGrantedUpon')
          v-radio(v-for="granted in ['request', 'approval']" :key="granted" :class="'group-form__membership-granted-upon-' + granted" :value='granted')
            template(v-slot:label)
              span(v-t="'group_form.membership_granted_upon_' + granted")

    div.pt-2(v-if="!group.parentId")
      span.text-medium-emphasis
        //- common-icon(name="mdi-lock-outline")
        span(v-t="'common.privacy.privacy'")
        span :
        space
        span(v-t="'common.privacy.secret'")
      p.text-body-small.text-medium-emphasis
        span(v-t="'group_form.secret_by_default'")

  v-card-actions.ma-2
    v-spacer
    v-btn.group-form__submit-button(
      :loading="group.processing"
      color="primary"
      @click='submit()'
      variant="elevated"
      :disabled="submitIsDisabled"
    )
      span(v-if='group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='!group.isParent()' v-t="'group_form.submit_start_subgroup'")
</template>
