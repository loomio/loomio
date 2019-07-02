<script lang="coffee">
export default
  props: ['node', 'updateAttrs', 'view']
  methods:
    onChange: ->
      @updateAttrs
        done: !@node.attrs.done
</script>

<template>
<li :data-type="node.type.name" :data-done="node.attrs.done.toString()" data-drag-handle>
  <span class="todo-checkbox" contenteditable="false" @click="onChange"></span>
  <div class="todo-content" ref="content" :contenteditable="view.editable.toString()"></div>
</li>
</template>
