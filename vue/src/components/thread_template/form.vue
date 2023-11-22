<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash  from '@/shared/services/flash';
import I18n from '@/i18n';
import { compact } from 'lodash-es';
import { ContainerMixin, HandleDirective } from 'vue-slicksort';

export default {
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
      recipientAudienceItems: [{text: 'None', value: null}, {text: I18n.t('announcement.audiences.everyone_in_the_group'), value: 'group'}]
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
          text: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    }
  },

  methods: {
    updatePollTemplateItems() {
      this.pollTemplateItems = [{text: I18n.t('thread_template.add_proposal_or_poll_template'), value: null}].concat(
        Records.pollTemplates.find({groupId: this.discussionTemplate.group().id}).filter( pt => {
          return !this.pollTemplates.includes(pt);
        }).map(pt => ({
          text: pt.processName,
          value: pt.id || pt.key
        }))
      );
    },

    submit() {
      this.discussionTemplate.pollTemplateKeysOrIds = this.pollTemplates.map(pt => pt.keyOrId());
      this.discussionTemplate.save().then(data => {
        Flash.success("thread_template.thread_template_saved");
        this.$router.push(this.$route.query.return_to || ('/thread_templates/?group_id='+this.discussionTemplate.groupId));
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
<template>

<div class="thread-template-form">
  <submit-overlay :value="discussionTemplate.processing"></submit-overlay>
  <div class="d-flex">
    <v-breadcrumbs class="px-0 py-0" :items="breadcrumbs">
      <template v-slot:divider="v-slot:divider">
        <common-icon name="mdi-chevron-right"></common-icon>
      </template>
    </v-breadcrumbs>
    <v-spacer></v-spacer>
    <v-btn class="back-button" v-if="$route.query.return_to" icon="icon" :aria-label="$t('common.action.cancel')" :to="$route.query.return_to">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </div>
  <v-card-title class="px-0">
    <h1 class="text-h4" v-if="discussionTemplate.id" tabindex="-1" v-t="'discussion_form.edit_thread_template'"></h1>
    <h1 class="text-h4" v-else tabindex="-1" v-t="'discussion_form.new_thread_template'"></h1>
  </v-card-title>
  <v-text-field v-model="discussionTemplate.processName" :label="$t('poll_common_form.process_name')" :hint="$t('poll_common_form.process_name_hint')"></v-text-field>
  <validation-errors :subject="discussionTemplate" field="processName"></validation-errors>
  <v-text-field v-model="discussionTemplate.processSubtitle" :label="$t('poll_common_form.process_subtitle')" :hint="$t('poll_common_form.process_subtitle_hint')"></v-text-field>
  <validation-errors :subject="discussionTemplate" field="processSubtitle"></validation-errors>
  <lmo-textarea :model="discussionTemplate" field="processIntroduction" :placeholder="$t('poll_common_form.process_introduction_hint')" :label="$t('poll_common_form.process_introduction')"></lmo-textarea>
  <v-divider class="my-4"></v-divider>
  <v-text-field class="thread-template-form-fields__title" :label="$t('thread_template.default_title_label')" :hint="$t('thread_template.default_title_hint')" v-model="discussionTemplate.title" maxlength="250"></v-text-field>
  <validation-errors :subject="discussionTemplate" field="title"></validation-errors>
  <v-text-field class="thread-template-form-fields__title-placeholder" :hint="$t('thread_template.title_placeholder_hint')" :label="$t('thread_template.title_placeholder_label')" :placeholder="$t('thread_template.title_placeholder_placeholder')" v-model="discussionTemplate.titlePlaceholder" maxlength="250"></v-text-field>
  <validation-errors :subject="discussionTemplate" field="titlePlaceholder"></validation-errors>
  <tags-field :model="discussionTemplate"></tags-field>
  <lmo-textarea :model="discussionTemplate" field="description" :placeholder="$t('thread_template.example_description_placeholder')" :label="$t('thread_template.example_description_label')"></lmo-textarea>
  <v-select v-model="discussionTemplate.recipientAudience" :label="$t('discussion_form.invite')" :items="recipientAudienceItems"></v-select>
  <v-divider class="my-4"></v-divider>
  <v-subheader class="ml-n4" v-t="'thread_template.decision_templates'"></v-subheader>
  <p class="text-caption" v-t="'thread_template.decision_templates_help'"></p>
  <div class="decision-tools-card__poll-types">
    <sortable-list v-model="pollTemplates" :useDragHandle="true" append-to=".decision-tools-card__poll-types" lock-axis="y" axis="y">
      <sortable-item v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key">
        <v-list>
          <v-list-item class="decision-tools-card__poll-type" :class="'decision-tools-card__poll-type--' + template.pollType">
            <v-list-item-content>
              <v-list-item-title><span>{{ template.processName }}</span></v-list-item-title>
              <v-list-item-subtitle>{{ template.processSubtitle }}</v-list-item-subtitle>
            </v-list-item-content>
            <v-list-item-action class="handle" v-handle="v-handle" style="cursor: grab">
              <common-icon name="mdi-drag-vertical"></common-icon>
            </v-list-item-action>
            <v-list-item-action>
              <v-btn icon="icon" @click="removePollTemplate(template)">
                <common-icon name="mdi-close"></common-icon>
              </v-btn>
            </v-list-item-action>
          </v-list-item>
        </v-list>
      </sortable-item>
    </sortable-list>
  </div>
  <v-select v-model="selectedPollTemplate" :items="pollTemplateItems" @change="pollTemplateSelected"></v-select>
  <v-divider class="my-4"></v-divider>
  <v-subheader class="ml-n4" v-t="'thread_arrangement_form.sorting'"></v-subheader>
  <v-radio-group v-model="discussionTemplate.newestFirst">
    <v-radio :value="false">
      <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.earliest'"></strong>
        <space></space>-
        <space></space><span v-t="'thread_arrangement_form.earliest_description'"></span>
      </template>
    </v-radio>
    <v-radio :value="true">
      <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.latest'"></strong>
        <space></space>-
        <space></space><span v-t="'thread_arrangement_form.latest_description'"></span>
      </template>
    </v-radio>
  </v-radio-group>
  <v-subheader class="ml-n4" v-t="'thread_arrangement_form.replies'"></v-subheader>
  <v-radio-group v-model="discussionTemplate.maxDepth">
    <v-radio :value="1">
      <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.linear'"></strong>
        <space></space>-
        <space></space><span v-t="'thread_arrangement_form.linear_description'"></span>
      </template>
    </v-radio>
    <v-radio :value="2">
      <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.nested_once'"></strong>
        <space></space>-
        <space></space><span v-t="'thread_arrangement_form.nested_once_description'"></span>
      </template>
    </v-radio>
    <v-radio :value="3">
      <template v-slot:label="v-slot:label"><strong v-t="'thread_arrangement_form.nested_twice'"></strong>
        <space></space>-
        <space></space><span v-t="'thread_arrangement_form.nested_twice_description'"></span>
      </template>
    </v-radio>
  </v-radio-group>
  <v-checkbox v-model="discussionTemplate.public" :label="$t('thread_template.share_in_template_gallery')"></v-checkbox>
  <div class="d-flex justify-space-between my-4 mt-4 thread-template-form-actions">
    <v-spacer></v-spacer>
    <v-btn class="thread-template-form__submit" color="primary" @click="submit()" :loading="discussionTemplate.processing" :disabled="!discussionTemplate.processName || !discussionTemplate.processSubtitle"><span v-t="'common.action.save'"></span></v-btn>
  </div>
</div>
</template>
