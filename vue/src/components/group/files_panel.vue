<script lang="js">
import Records           from '@/shared/services/records';
import RecordLoader      from '@/shared/services/record_loader';
import EventBus          from '@/shared/services/event_bus';
import AbilityService    from '@/shared/services/ability_service';
import Session           from '@/shared/services/session';
import AttachmentService from '@/shared/services/attachment_service';

import { isEmpty, intersection, debounce, filter, some, orderBy, uniq } from 'lodash-es';

export default
{
  data() {
    return {
      group: null,
      loader: null,
      attachmentLoader: null,
      searchQuery: '',
      items: [],
      subgroups: 'mine',
      attachmentIds: [],
      per: 25,
      from: 0
    };
  },

  created() {
    this.onQueryInput = debounce(val => {
      return this.$router.replace({ query: { q: val } });
    } , 400);

    this.group = Records.groups.fuzzyFind(this.$route.params.key);

    EventBus.$emit('currentComponent', {
      page: 'groupPage',
      title: this.group.name,
      group: this.group,
      search: {
        placeholder: this.$t('navbar.search_files', {name: this.group.parentOrSelf().name})
      }
    });

    this.loader = new RecordLoader({
      collection: 'documents',
      path: 'for_group',
      params: {
        group_id: this.group.id,
        per: this.per,
        subgroups: this.subgroups,
        from: this.from
      }
    });

    this.attachmentLoader = new RecordLoader({
      collection: 'attachments',
      params: {
        group_id: this.group.id,
        per: this.per,
        subgroups: this.subgroups,
        from: this.from
      }
    });

    this.watchRecords({
      collections: ['documents', 'attachments'],
      query: () => this.query()
    });

    this.searchQuery = this.$route.query.q || '';
    this.fetch();
  },

  watch: {
    '$route.query.q'(val) {
      this.searchQuery = val || '';
      this.fetch();
      this.query();
    }
  },

  methods: {
    query() {
      const groupIds = (() => { switch (this.subgroups) {
        case 'none': return [this.group.id];
        case 'mine': return intersection(this.group.organisationIds(), Session.user().groupIds());
        case 'all': return this.group.organisationIds();
      } })();

      const documents = Records.documents.collection.chain().
                     find({groupId: {$in: groupIds}}).
                     find({title: {$regex: new RegExp(`${this.searchQuery}`, 'i')}}).
                     data();

      const attachments = Records.attachments.collection.chain().
                     find({id: {$in: this.attachmentIds}}).
                     find({filename: {$regex: new RegExp(`${this.searchQuery}`, 'i')}}).
                     data();

      this.items = orderBy(documents.concat(attachments), 'createdAt', 'desc');
    },

    fetch() {
      this.loader.fetchRecords({
        q: this.searchQuery});

      this.attachmentLoader.fetchRecords({q: this.searchQuery}).then(data => {
        this.attachmentIds = uniq(this.attachmentIds.concat((data.attachments || []).map(a => a.id)));
      }).then(() => this.query());
    },

    actionsFor(item) {
      return AttachmentService.actions(item);
    }
  },

  computed: {
    showLoadMore() { return !this.loader.exhausted && !this.attachmentLoader.exhausted; },
    loading() { return this.loader.loading || this.attachmentLoader.loading; },
    canAdminister() { return AbilityService.canAdminister(this.group); }
  }
};

</script>

<template lang="pug">
div
  v-layout.py-2(align-center wrap)
    v-text-field(clearable hide-details solo @input="onQueryInput" :placeholder="$t('navbar.search_files', {name: group.name})" append-icon="mdi-magnify")
  v-card.group-files-panel(outlined)
    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      p.text-center.pa-4(v-if="!loading && !items.length" v-t="'common.no_results_found'")
      v-simple-table(v-else :items="items" hide-default-footer)
        thead
          tr
            th(v-t="'group_files_panel.filename'")
            th(v-t="'group_files_panel.uploaded_by'")
            th(v-t="'group_files_panel.uploaded_at'")
            th(v-if="canAdminister")
        tbody
          tr(v-for="item in items" :key="item.id")
            td
              v-layout(align-center)
                common-icon(:name="'mdi-'+ item.icon")
                a(:href="item.downloadUrl || item.url") {{item.filename || item.title }}
            td
              user-avatar(:user="item.author()")
            td
              time-ago(:date="item.createdAt")
            td(v-if="canAdminister")
              action-menu(v-if="Object.keys(actionsFor(item)).length" :actions="actionsFor(item)" icon)

      v-layout(justify-center)
        .d-flex.flex-column.justify-center.align-center
          //- span(v-if="loader.total == null") {{items.length}} / {{attachmentLoader.total}}
          v-btn.my-2(outlined color='primary' v-if="!attachmentLoader.exhausted" :loading="loading" @click="fetch()" v-t="'common.action.load_more'")
</template>
