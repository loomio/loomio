<script setup lang="js">
import { ref, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { I18n } from '@/i18n';
import { compact } from 'lodash-es';
import { HandleDirective } from 'vue-slicksort';
import { useWatchRecords } from '@/composables/useWatchRecords';

const vHandle = HandleDirective;

const props = defineProps({
  discussionTemplate: {
    type: Object,
    required: true
  }
});

const router = useRouter();
const route = useRoute();

// url_for mixin functionality
const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

// watch_records composable
const { watchRecords } = useWatchRecords();

// Template refs
const form = ref(null);

// Data
const pollTemplateItems = ref([]);
const selectedPollTemplate = ref(null);
const pollTemplates = ref([]);
const recipientAudienceItems = ref([
  {title: 'None', value: null},
  {title: I18n.global.t('announcement.audiences.everyone_in_the_group'), value: 'group'}
]);

// Computed
const breadcrumbs = computed(() => {
  return compact([
    props.discussionTemplate.group().parentId && props.discussionTemplate.group().parent(),
    props.discussionTemplate.group()
  ]).map(g => {
    return {
      title: g.name,
      disabled: false,
      to: urlFor(g)
    };
  });
});

// Methods
const validate = (field) => {
  return [ () => props.discussionTemplate.errors[field] === undefined || props.discussionTemplate.errors[field][0] ];
};

const discardDraft = () => {
  if (confirm(I18n.global.t('formatting.confirm_discard'))) {
    EventBus.$emit('resetDraft', 'discussionTemplate', props.discussionTemplate.id, 'description', props.discussionTemplate.description);
    EventBus.$emit('resetDraft', 'discussionTemplate', props.discussionTemplate.id, 'processIntroduction', props.discussionTemplate.processIntroduction);
  }
};

const updatePollTemplateItems = () => {
  pollTemplateItems.value = [{title: I18n.global.t('discussion_template.add_poll_template'), value: null}].concat(
    Records.pollTemplates.find({groupId: props.discussionTemplate.group().id}).filter(pt => {
      return !pollTemplates.value.includes(pt);
    }).map(pt => ({
      title: pt.processName,
      value: pt.id || pt.key
    }))
  );
};

const submit = () => {
  props.discussionTemplate.setErrors();
  form.value.resetValidation();
  props.discussionTemplate.pollTemplateKeysOrIds = pollTemplates.value.map(pt => pt.keyOrId());
  props.discussionTemplate.save().then(data => {
    Flash.success("discussion_template.discussion_template_saved");
    router.push(route.query.return_to || ('/discussion_templates/?group_id=' + props.discussionTemplate.groupId));
  }).catch(error => {
    form.value.validate();
    Flash.serverError(error, ['processName', 'processSubtitle', 'title']);
  });
};

const pollTemplateSelected = (keyOrId) => {
  pollTemplates.value.push(Records.pollTemplates.find(keyOrId));
  setTimeout(() => {
    selectedPollTemplate.value = null;
    updatePollTemplateItems();
  });
};

const removePollTemplate = (pollTemplate) => {
  pollTemplates.value.splice(pollTemplates.value.indexOf(pollTemplate), 1);
  updatePollTemplateItems();
};

// created logic (runs immediately in script setup)
pollTemplates.value = props.discussionTemplate.pollTemplates();
Records.pollTemplates.fetchByGroupId(props.discussionTemplate.groupId);

watchRecords({
  collections: ["pollTemplates"],
  query: records => updatePollTemplateItems()
});

</script>
<template lang="pug">
v-form(ref="form" @submit.prevent="submit")
  .d-flex
    v-breadcrumbs.px-0.py-4(color="anchor" :items="breadcrumbs")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    v-spacer
  v-card.discussion-template-form(:title="discussionTemplate.id ? $t('discussion_form.edit_discussion_template') : $t('discussion_form.new_discussion_template')")
    template(v-slot:append)
      v-btn.back-button(v-if="$route.query.return_to" variant="flat" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
        common-icon(name="mdi-close")

    v-card-text
      v-text-field(
         v-model="discussionTemplate.processName"
        :label="$t('poll_common_form.process_name')"
        :placeholder="$t('discussion_template.process_name_placeholder')"
        :hint="$t('poll_common_form.process_name_hint')"
        :rules="validate('processName')"
      )

      v-text-field(
         v-model="discussionTemplate.processSubtitle"
        :label="$t('poll_common_form.process_subtitle')"
        :placeholder="$t('discussion_template.process_subtitle_placeholder')"
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
      v-select(
        v-model="discussionTemplate.defaultToDirectDiscussion"
        :label="$t('common.group')"
        :items="[{title: discussionTemplate.group().name, value: false}, {title: $t('discussion_form.none_direct_discussion'), value: true}]")

      v-text-field.discussion-template-form-fields__title(
        :label="$t('discussion_template.default_title_label')"
        :placeholder="$t('discussion_template.default_title_placeholder')"
        :hint="$t('discussion_template.default_title_hint')"
        v-model='discussionTemplate.title'
        maxlength='250'
        :rules="validate('title')"
      )

      v-text-field.discussion-template-form-fields__title-placeholder(
        :hint="$t('discussion_template.title_placeholder_hint')"
        :label="$t('discussion_template.title_placeholder_label')"
        :placeholder="$t('discussion_template.title_placeholder_placeholder')"
        v-model='discussionTemplate.titlePlaceholder'
        :rules="validate('titlePlaceholder')"
        maxlength='250'
      )

      tags-field(:model="discussionTemplate")

      lmo-textarea(
        :model='discussionTemplate'
        field="description"
        :placeholder="$t('discussion_template.example_description_placeholder')"
        :label="$t('discussion_template.example_description_label')"
      )

      v-select.mt-4(v-model="discussionTemplate.recipientAudience" :label="$t('discussion_form.invite')" :items="recipientAudienceItems")

      v-divider.my-4

      .text-subtitle-1.py-2.text-medium-emphasis(v-t="'discussion_template.poll_templates'")
      p.text-caption(v-t="'discussion_template.poll_templates_help'")
      v-card.my-8.decision-tools-card__poll-types
        sortable-list(v-model:list="pollTemplates" :useDragHandle="true" append-to=".decision-tools-card__poll-types"  lock-axis="y" axis="y")
          sortable-item(v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key")
            div
              v-list-item(
                lines="two"
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
              v-divider
      v-select.mt-4(
        variant="solo-filled"
        v-model="selectedPollTemplate"
        :items="pollTemplateItems"
        @update:modelValue="pollTemplateSelected"
      )
        template(v-slot:prepend-inner)
          common-icon(name="mdi-plus")
      v-divider.my-4

      //.text-subtitle-1.py-2.text-medium-emphasis(v-t="'thread_arrangement_form.sorting'")
      //v-radio-group(v-model="discussionTemplate.newestFirst")
      //  v-radio(:value="false")
      //    template(v-slot:label)
      //      strong(v-t="'thread_arrangement_form.earliest'")
      //      space
      //      | -
      //      space
      //      span(v-t="'thread_arrangement_form.earliest_description'")

      //  v-radio(:value="true")
      //    template(v-slot:label)
      //      strong(v-t="'thread_arrangement_form.latest'")
      //      space
      //      | -
      //      space
      //      span(v-t="'thread_arrangement_form.latest_description'")

      //.text-subtitle-1.py-2.text-medium-emphasis(v-t="'thread_arrangement_form.replies'")
      //v-radio-group(v-model="discussionTemplate.maxDepth")
      //  v-radio(:value="1")
      //    template(v-slot:label)
      //      strong(v-t="'thread_arrangement_form.linear'")
      //      space
      //      | -
      //      space
      //      span(v-t="'thread_arrangement_form.linear_description'")
      //  v-radio(:value="2")
      //    template(v-slot:label)
      //      strong(v-t="'thread_arrangement_form.nested_once'")
      //      space
      //      | -
      //      space
      //      span(v-t="'thread_arrangement_form.nested_once_description'")
      //  v-radio(:value="3")
      //    template(v-slot:label)
      //      strong(v-t="'thread_arrangement_form.nested_twice'")
      //      space
      //      | -
      //      space
      //      span(v-t="'thread_arrangement_form.nested_twice_description'")


      //- .d-flex.justify-space-between.my-4.mt-4.discussion-template-form-actions
    v-card-actions
      v-spacer
      v-btn.mr-2(
        @click="discardDraft"
        v-t="'common.reset'"
      )
      v-btn.discussion-template-form__submit(
        variant="elevated"
        color="primary"
        @click='submit()'
        :loading="discussionTemplate.processing"
      )
        span(v-t="'common.action.save_template'")

</template>
