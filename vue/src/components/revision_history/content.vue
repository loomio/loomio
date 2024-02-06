<script lang="js">
import Records from '@/shared/services/records';
import { exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import { reject, map, parseInt } from 'lodash-es';

import {marked} from 'marked';
import {customRenderer, options} from '@/shared/helpers/marked';
marked.setOptions(Object.assign({renderer: customRenderer()}, options));

export default {
  props: {
    model: Object,
    version: Object
  },

  methods: {
    exact
  },

  computed: {
    modelKind() { return this.model.constructor.singular; },

    bodyField() {
      switch (this.model.constructor.singular) {
        case "comment": return "body";
        case "stance": return "reason";
        case "discussion": return "description";
        case "poll": return "details";
        case "outcome": return "statement";
      }
    },

    bodyChanges() {
      if (!this.version || !this.version.objectChanges || !this.version.objectChanges[this.bodyField]) { return ''; }
      if (this.model[this.bodyField+"Format"] === "md") {
        return this.version.objectChanges[this.bodyField].map(val => marked(val || ''));
      } else {
        return this.version.objectChanges[this.bodyField];
      }
    },

    titleChanges() {
      return (this.version.objectChanges || {}).title;
    },

    bodyLabel() {
      switch (this.model.constructor.singular) {
        case "comment": return "activity_card.comment";
        case "stance": return "poll_common.reason";
        case "discussion": return "discussion_form.context_label";
        case "poll": return "poll_common.details";
        case "outcome": return "poll_common.statement";
      }
    },

    objectKeys() {
      const excl = (() => { switch (this.model.constructor.singular) {
        case "comment": return ['body', 'body_format'];
        case "stance": return ['reason', 'reason_format'];
        case "discussion": return ['title', 'description', 'description_format'];
        case "poll": return ['title', 'details', 'details_format'];
        case "outcome": return ['statement', 'statement_format'];
      } })();
      return reject(Object.keys(this.version.objectChanges || {}), key => excl.includes(key));
    },

    otherFields() {
      return this.objectKeys.map(key => {
        const vals = this.version.objectChanges[key].map(v => {
          if (v) {
            return (key.match(/_at$/) && exact(parseISO(v))) || v;
          } else {
            return this.$t('common.empty');
          }
        });
        return {key, was: vals[0], now: vals[1]};
    });
    },

    stanceChoices() {
      if ((this.model.constructor.singular === "stance") && this.version.objectChanges['option_scores']) {
        const was = this.version.objectChanges['option_scores'][0];
        const now = this.version.objectChanges['option_scores'][1];
        const wasChoices = map(was, (score, pollOptionId) => {
          const option = Records.pollOptions.find(parseInt(pollOptionId));
          // option = @model.poll().pollOptions().find( (o) -> o.id == parseInt(pollOptionId) )
          return {
            name: option.optionName(),
            color: option.color,
            score
          };
        });
        const nowChoices = map(now, (score, pollOptionId) => {
          // option = @model.poll().pollOptions().find( (o) -> o.id == parseInt(pollOptionId) )
          const option = Records.pollOptions.find(parseInt(pollOptionId));
          return {
            name: option.optionName(),
            color: option.color,
            score
          };
        });
        return {was: wasChoices, now: nowChoices};
      } else {
        return false;
      }
    },

    labelFor(field) {
      // setup a case soon
      return field;
    }
  }
};

</script>

<template lang="pug">

.revision-history-content
  .mb-3(v-if="titleChanges")
    v-label(v-t="'discussion_form.title_label'")
    html-diff.text-h5(:before="titleChanges[0]" :after="titleChanges[1]")

  .mb-3(v-if="!stanceChoices && otherFields.length")
    v-simple-table(dense)
      thead
        tr
          th(v-t="'revision_history_modal.field'")
          th(v-t="'revision_history_modal.before'")
          th(v-t="'revision_history_modal.after'")
      tbody
        tr(v-for="field in otherFields")
          td {{field.key}}
          td {{field.was}}
          td {{field.now}}

  .mb-3(v-if="stanceChoices")
    .text-secondary(v-t="'revision_history_modal.before'")
    v-simple-table.mb-4(dense)
      tr(v-for="choice in stanceChoices.was")
        td(:style="'border-left: 2px solid '+choice.color") {{choice.name}}
        td {{choice.score}}
    .text-secondary(v-t="'revision_history_modal.after'")
    v-simple-table.mb-4(dense)
      tr(v-for="choice in stanceChoices.now")
        td(:style="'border-left: 2px solid '+choice.color") {{choice.name}}
        td {{choice.score}}
  .mb-3(v-if="bodyChanges")
    v-label(v-t="bodyLabel")
    html-diff.lmo-markdown-wrapper(:before="bodyChanges[0]" :after="bodyChanges[1]")

</template>
