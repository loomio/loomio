<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash  from '@/shared/services/flash';
import { I18n } from '@/i18n';
import { compact } from 'lodash-es';
import { ContainerMixin, HandleDirective } from 'vue-slicksort';

import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, UrlFor],
  directives: {
    handle: HandleDirective
  },

  props: {
    discussionTemplate: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      pollTemplateItems: [],
      selectedPollTemplate: null,
      pollTemplates: [],
      recipientAudienceItems: [{title: 'None', value: null}, {title: I18n.global.t('announcement.audiences.everyone_in_the_group'), value: 'group'}]
    };
  },

  created() {
    this.pollTemplates = this.discussionTemplate.pollTemplates();
    Records.pollTemplates.fetchByGroupId(this.discussionTemplate.groupId);

    this.watchRecords({
      collections: ["pollTemplates"],
      query: records => this.updatePollTemplateItems()
    });
  },

  computed: {
    breadcrumbs() {
      return compact([this.discussionTemplate.group().parentId && this.discussionTemplate.group().parent(), this.discussionTemplate.group()]).map(g => {
        return {
          title: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    }
  },

  methods: {
    validate(field) {
      return [ () => this.discussionTemplate.errors[field] === undefined || this.discussionTemplate.errors[field][0] ]
    },
    discardDraft() {
      if (confirm(I18n.global.t('formatting.confirm_discard'))) {
        EventBus.$emit('resetDraft', 'discussionTemplate', this.discussionTemplate.id, 'description', this.discussionTemplate.description);
        EventBus.$emit('resetDraft', 'discussionTemplate', this.discussionTemplate.id, 'processIntroduction', this.discussionTemplate.processIntroduction);
      }
    },
    updatePollTemplateItems() {
      this.pollTemplateItems = [{title: I18n.global.t('thread_template.add_proposal_or_poll_template'), value: null}].concat(
        Records.pollTemplates.find({groupId: this.discussionTemplate.group().id}).filter( pt => {
          return !this.pollTemplates.includes(pt);
        }).map(pt => ({
          title: pt.processName,
          value: pt.id || pt.key
        }))
      );
    },

    submit() {
      this.discussionTemplate.pollTemplateKeysOrIds = this.pollTemplates.map(pt => pt.keyOrId());
      this.discussionTemplate.save().then(data => {
        Flash.success("thread_template.thread_template_saved");
        this.$router.push(this.$route.query.return_to || ('/thread_templates/?group_id=' + this.discussionTemplate.groupId));
      }).catch(error => {
        this.$refs.form.validate();
        Flash.error('common.check_for_errors_and_try_again');
      });
    },

    pollTemplateSelected(keyOrId) {
      this.pollTemplates.push(Records.pollTemplates.find(keyOrId));
      setTimeout(() => {
        this.selectedPollTemplate = null;
        this.updatePollTemplateItems();
      });
    },

    removePollTemplate(pollTemplate) {
      this.pollTemplates.splice(this.pollTemplates.indexOf(pollTemplate), 1);
      this.updatePollTemplateItems();
    }
  }
};

</script>
<template lang="pug">
v-form(ref="form" @submit.prevent="submit")
  .d-flex
    v-breadcrumbs.px-0.py-4(color="anchor" :items="breadcrumbs")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    v-spacer
  v-card.thread-template-form(:title="discussionTemplate.id ? $t('discussion_form.edit_thread_template') : $t('discussion_form.new_thread_template')")
    template(v-slot:append)
      v-btn.back-button(v-if="$route.query.return_to" variant="flat" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
        common-icon(name="mdi-close")

    v-card-text
      v-text-field(
         v-model="discussionTemplate.processName"
        :label="$t('poll_common_form.process_name')"
        :hint="$t('poll_common_form.process_name_hint')"
        :rules="validate('processName')"
      )

      v-text-field(
         v-model="discussionTemplate.processSubtitle"
        :label="$t('poll_common_form.process_subtitle')"
        :hint="$t('poll_common_form.process_subtitle_hint')"
        :rules="validate('processSubtitle')"
      )

      lmo-textarea(
        :model='discussionTemplate'
        field="processIntroduction"
        :placeholder="$t('poll_common_form.process_introduction_hint')"
        :label="$t('poll_common_form.process_introduction')"
      )

      v-divider.my-4

      v-text-field.thread-template-form-fields__title(
        :label="$t('thread_template.default_title_label')"
        :hint="$t('thread_template.default_title_hint')"
        v-model='discussionTemplate.title'
        maxlength='250'
        :rules="validate('title')"
      )

      v-text-field.thread-template-form-fields__title-placeholder(
        :hint="$t('thread_template.title_placeholder_hint')"
        :label="$t('thread_template.title_placeholder_label')"
        :placeholder="$t('thread_template.title_placeholder_placeholder')"
        v-model='discussionTemplate.titlePlaceholder'
        :rules="validate('titlePlaceholder')"
        maxlength='250'
      )

      tags-field(:model="discussionTemplate")

      lmo-textarea(
        :model='discussionTemplate'
        field="description"
        :placeholder="$t('thread_template.example_description_placeholder')"
        :label="$t('thread_template.example_description_label')"
      )

      v-select.mt-4(v-model="discussionTemplate.recipientAudience" :label="$t('discussion_form.invite')" :items="recipientAudienceItems")

      v-divider.my-4

      .text-subtitle-1.py-2.text-medium-emphasis(v-t="'thread_template.decision_templates'")
      p.text-caption(v-t="'thread_template.decision_templates_help'")
      .decision-tools-card__poll-types
        sortable-list(v-model:list="pollTemplates" :useDragHandle="true" append-to=".decision-tools-card__poll-types"  lock-axis="y" axis="y")
          sortable-item(v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key")
            v-list
              v-list-item.decision-tools-card__poll-type(
                :class="'decision-tools-card__poll-type--' + template.pollType"
              )
                v-list-item-title
                  span {{ template.processName }}
                v-list-item-subtitle {{ template.processSubtitle }}
                template(v-slot:append)
                  .handle(v-handle style="cursor: grab")
                    common-icon(name="mdi-drag-vertical")
                  v-btn(icon variant="flat" @click="removePollTemplate(template)" :title="$t('common.action.remove')")
                    common-icon(name="mdi-close")
      v-select.mt-4(
        variant="solo"
        v-model="selectedPollTemplate"
        :items="pollTemplateItems"
        @update:modelValue="pollTemplateSelected"
      )
      v-divider.my-4

      .text-subtitle-1.py-2.text-medium-emphasis(v-t="'thread_arrangement_form.sorting'")
      v-radio-group(v-model="discussionTemplate.newestFirst")
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

      .text-subtitle-1.py-2.text-medium-emphasis(v-t="'thread_arrangement_form.replies'")
      v-radio-group(v-model="discussionTemplate.maxDepth")
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
        v-radio(:value="3")
          template(v-slot:label)
            strong(v-t="'thread_arrangement_form.nested_twice'")
            space
            | -
            space
            span(v-t="'thread_arrangement_form.nested_twice_description'")

      v-checkbox(v-model="discussionTemplate.public" :label="$t('thread_template.share_in_template_gallery')")

      //- .d-flex.justify-space-between.my-4.mt-4.thread-template-form-actions
    v-card-actions
      v-spacer
      v-btn.mr-2(
        @click="discardDraft"
        v-t="'common.reset'"
      )
      v-btn.thread-template-form__submit(
        variant="elevated"
        color="primary"
        @click='submit()'
        :loading="discussionTemplate.processing"
      )
        span(v-t="'common.action.save'")

</template>
