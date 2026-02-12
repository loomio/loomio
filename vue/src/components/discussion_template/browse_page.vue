<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import utils         from '@/shared/record_store/utils';
import VuetifyColors  from 'vuetify/lib/util/colors';
import { mdiMagnify } from '@mdi/js';

const colors = Object.keys(VuetifyColors).filter(name => name !== 'shades').map(name => VuetifyColors[name]['base']);

export default {
  data() {
    return {
      mdiMagnify,
      results: [],
      query: this.$route.query.query,
      loading: false,
      tags: []
    };
  },

  mounted() {
    this.fetch();
    Records.remote.get('discussion_templates/browse_tags').then(data => {
      this.tags = data;
    });
  },

  methods: {
    changed() { return this.fetch(); },
    fetch() {
      this.loading = true;
      this.results = [];
      Records.remote.get('discussion_templates/browse', {query: this.query}).then(data => {
        this.results = data.results.map(utils.parseJSON);
        this.loading = false;
      });
    },

    tagColor(tag){
      return colors[this.tags.indexOf(tag) % colors.length];
    }
  }
};

</script>
<template lang="pug">
.thread-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      v-card(:title="$t('discussion_template.example_templates')")
        template(v-slot:append)
          v-btn.back-button(
            v-if="$route.query.return_to"
            variant="flat"
            icon
            :aria-label="$t('common.action.cancel')"
            :to='$route.query.return_to'
          )
            common-icon(name="mdi-close")

        v-alert.ma-4(type="info" variant="tonal")
          span(v-t="'discussion_template.browse_public_templates_hint'")

        .d-flex.px-4.align-center
          v-combobox(
            :loading="loading"
            autofocus
            filled
            single-line
            hide-selected
            clearable
            @change="changed"
            :append-icon="mdiMagnify"
            @click:append="fetch"
            v-model="query"
            :placeholder="$t('common.action.search')"
            @keydown.enter.prevent="fetch"
            hide-details
            :items="tags"
            )

        v-list.append-sort-here(lines="two")
          v-list-item(
            v-for="result in results"
            :key="result.id"
            :to="'/d/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key)+ '&group_id='+ $route.query.group_id"
          )
            template(v-slot:append)
              v-btn(
                variant="plain"
                icon
                :to="'/discussion_templates/new?template_id='+result.id+'&group_id='+$route.query.group_id"
                title="Make a copy of this template and edit it"
              )
                common-icon(name="mdi-pencil")

            v-list-item-title.d-flex
              span {{result.processName || result.title}}
              v-spacer
              v-chip.ml-1(
                v-for="tag in result.tags"
                :key="tag"
                outlined
                size="x-small"
                :color="tagColor(tag)"
              ) {{tag}}

            v-list-item-subtitle {{result.processSubtitle}}


</template>
