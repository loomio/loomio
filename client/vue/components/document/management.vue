<style>
.document-management {
  margin-bottom: 16px;
}

.document-management__caption {
  color: $grey-on-white;
}

.document-management__icon {
  font-size: 24px;
}

.document-management__column-row {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  margin: 8px 0;
  i { padding: 4px; }
}

</style>

<script lang="coffee">
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'vue/mixins/url_for'
truncate       = require 'vue/mixins/truncate'

module.exports =
  mixins: [urlFor, truncate]
  props:
    group: Object
    fragment: Object
    filter: Object
    header: Object
  methods:
    canAdministerGroup: ->
      AbilityService.canAdministerGroup(@group)

    edit: (doc) ->
      ModalService.open 'DocumentModal', doc: => doc

    remove: (doc) ->
      ModalService.open 'ConfirmModal', confirm: =>
        submit:      doc.destroy
        text:
          title:    'documents_page.confirm_remove_title'
          helptext: 'documents_page.confirm_remove_helptext'
          flash:    'documents_page.document_removed'
  computed:
    documents: ->
      _.filter @group.allDocuments(), (doc) =>
        return false  if @filter == 'group'   and doc.model() != @group
        return false  if @filter == 'content' and doc.model() == @group
        _.isEmpty(@fragment) or doc.title.match(///#{@fragment}///i)

    orderedDocuments: ->
      _.orderBy @documents, 'createdAt', 'desc'

    hasDocuments: ->
      _.some @documents
</script>

<template>
  <div v-if="hasDocuments" class="document-management">
    <h3 v-t="'document.management.' + filter + '_header'" v-if="filter" class="lmo-h3"></h3>
    <div v-for="document in orderedDocuments" :key="document.id" layout="row" class="document-management__document lmo-flex lmo-flex__space-between">
      <div class="document-management__column-row">
        <i :class="'mdi lmo-margin-right document-management__icon mdi-' + document.icon" :style="{color: document.color}"></i>
      </div>
      <div layout="column" class="document-management__column-row lmo-flex lmo-flex__grow">
        <strong class="lmo-truncate">
          <a :href="document.url" target="_blank">{{ truncate(document.title, 50) }}</a>
        </strong>
        <div class="document-management__caption md-caption">
          <a :href="urlFor(document.model())" class="lmo-truncate">{{ truncate(document.modelTitle(), 50) }}</a>
        </div>
        <div class="document-management__caption md-caption">
          <span>{{document.authorName()}}</span>
          <span>·</span>
          <time-ago :date="document.createdAt"></time-ago>
        </div>
      </div>
      <div v-if="canAdministerGroup()" class="document-management__column-row">
        <button @click="edit(document)" v-t="'common.action.edit'" class="md-accent"></button>
      </div>
      <div v-if="canAdministerGroup()" class="document-management__column-row">
        <button @click="remove(document)" v-t="'common.action.remove'" class="md-warn"></button>
      </div>
    </div>
  </div>
</template>
