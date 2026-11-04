import assert from 'node:assert/strict'
import test from 'node:test'

import { nextWatchRecordsName } from '../../src/shared/helpers/watch_records_name.js'

test('record watchers have unique names across mixin and composable callers', () => {
  const names = new Set()

  for (let index = 0; index < 20_000; index += 1) {
    names.add(nextWatchRecordsName(['stances', 'polls']))
  }

  assert.equal(names.size, 20_000)
})

test('descriptive keys do not collide across live component instances', () => {
  const first = nextWatchRecordsName(['topics'], 'dashboard')
  const second = nextWatchRecordsName(['topics'], 'dashboard')

  assert.notEqual(first, second)
})
