<script lang="coffee">
import loki        from 'lokijs'

testdb = new loki('test.db')
events = testdb.addCollection('events', indices: ['key'])

# want to test sort by key ascending and descending
# test with and without index on column

events.insert([
  {key: '001'},
  {key: '003'},
  {key: '002-002'},
  {key: '002'},
  {key: '002-001'},
  {key: '001-001'},
  {key: '001-002'},
  {key: '001-002-001'},
  {key: '001-001-001'},
])

keys = events.chain().find(key: {$jgte: '000'}).simplesort('key').data().map('key')

export default
  data: ->
    events: events.chain().find(key: {$jgte: '000'}).simplesort('key').data()
</script>

<template lang="pug">
div.loki-test
  div(v-for="e in events") {{e.id}} {{e.key}}

</template>
