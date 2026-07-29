<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import { importTemplateFile } from '@/shared/helpers/template_file';
import utils         from '@/shared/record_store/utils';
import { compact }   from 'lodash-es';
import { mdiContentCopy } from '@mdi/js';

export default {
  data() {
    return {
      mdiContentCopy,
      group: null,
      results: [],
      loading: false,
      importing: false,
      filter: 'proposal'
    };
  },

  mounted() {
    EventBus.$emit('content-title-visible', false);
    EventBus.$emit('currentComponent', { titleKey: 'poll_common.example_poll_templates', page: 'pollTemplateBrowsePage' });
    this.fetch();
    const groupId = parseInt(this.$route.query.group_id);
    if (groupId) {
      Records.groups.findOrFetchById(groupId).then(group => {
        this.group = group;
      });
    }
  },

  computed: {
    breadcrumbs() {
      if (!this.group) return [];
      return compact([this.group.parentId && this.group.parent(), this.group]).map(g => {
        return {
          title: g.name,
          disabled: false,
          to: LmoUrlService.route({model: g})
        };
      });
    },
    canImportTemplates() {
      return this.group && (
        this.group.adminsInclude(Session.user()) ||
        (this.group.membersCanCreateTemplates && this.group.membersInclude(Session.user()))
      );
    },
    filteredResults() {
      if (this.filter === 'proposal') {
        return this.results.filter(r => ['proposal', 'question'].includes(r.pollType));
      } else {
        return this.results.filter(r => ['score', 'poll', 'ranked_choice', 'dot_vote', 'meeting', 'count'].includes(r.pollType));
      }
    },
    groupIdParam() {
      return this.$route.query.group_id ? '&group_id='+this.$route.query.group_id : '';
    },
    returnToParam() {
      const base = this.$route.path;
      const groupId = this.$route.query.group_id;
      const returnTo = groupId ? `${base}?group_id=${groupId}` : base;
      return '&return_to=' + encodeURIComponent(returnTo);
    }
  },

  methods: {
    titleVisible(visible) { EventBus.$emit('content-title-visible', visible); },
    importTemplate() {
      this.$refs.templateFileInput.click();
    },
    async templateFileSelected(event) {
      const file = event.target.files[0];
      if (!file) { return; }

      this.importing = true;
      try {
        if (await importTemplateFile('poll_template', file)) {
          await this.$router.push({
            path: '/poll_templates/new',
            query: {
              group_id: this.group.id,
              import_json: '1',
              return_to: this.$route.fullPath
            }
          });
        }
      } finally {
        this.importing = false;
        event.target.value = '';
      }
    },
    fetch() {
      this.loading = true;
      Records.remote.get('poll_templates/browse', {group_id: this.$route.query.group_id}).then(data => {
        this.results = data.map(utils.parseJSON);
        this.loading = false;
      });
    }
  }
};
</script>
<template lang="pug">
.poll-templates-browse-page
  v-main
    v-container.max-width-800
      v-breadcrumbs(v-if="breadcrumbs.length" color="anchor" :items="breadcrumbs")
        template(v-slot:divider)
          common-icon(name="mdi-chevron-right")
      v-card
        template(v-slot:title)
          span(v-intersect="{handler: titleVisible}") {{ $t('poll_common.example_poll_templates') }}
        template(v-slot:append)
          .d-flex.align-center
            input.d-none(ref="templateFileInput" type="file" accept="application/json,.json" @change="templateFileSelected")
            v-btn.mr-2(v-if="canImportTemplates" variant="text" :loading="importing" @click="importTemplate")
              span(v-t="'common.action.import_json'")
            v-btn(v-if="$route.query.return_to" icon variant="text" :to="$route.query.return_to" :aria-label="$t('common.action.back')")
              common-icon(name="mdi-close")
        v-alert.ma-4(type="info" variant="tonal" :icon="mdiContentCopy")
          div(v-t="'templates.make_a_copy'")

        .d-flex.px-4
          v-chip.mr-1(
            :color="filter === 'proposal' ? 'primary' : null"
            label
            @click="filter = 'proposal'"
          )
            common-icon.mr-2(size="small" name="mdi-thumbs-up-down" :color="filter === 'proposal' ? 'primary' : null")
            span(v-t="'decision_tools_card.proposal_title'")
          v-chip(
            :color="filter === 'poll' ? 'primary' : null"
            label
            @click="filter = 'poll'"
          )
            common-icon.mr-2(size="small" name="mdi-poll" :color="filter === 'poll' ? 'primary' : null")
            span(v-t="'decision_tools_card.poll_title'")

        v-list(lines="two")
          v-list-item(
            v-for="result in filteredResults"
            :key="result.id || result.key"
            :to="'/p/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key) + groupIdParam+returnToParam"
          )
            template(v-slot:append)
              v-btn(
                variant="tonal"
                color="primary"
                icon
                :to="'/poll_templates/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key) + groupIdParam+returnToParam"
                :title="$t('templates.make_a_copy')"
              )
                common-icon(name="mdi-content-copy")

            v-list-item-title {{result.processName}}
            v-list-item-subtitle {{result.groupName || result.processSubtitle}}
</template>
