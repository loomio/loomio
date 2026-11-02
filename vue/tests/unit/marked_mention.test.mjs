import assert from 'node:assert/strict'
import test from 'node:test'

import { marked } from 'marked'

import { markedMention } from '../../src/shared/helpers/marked_mention.mjs'

marked.use({ extensions: [markedMention] })

const render = markdown => marked.parseInline(markdown)

test('renders handles as mention spans', () => {
  assert.equal(
    render('@richardlane4 I think @Geez8tc has it'),
    '<span data-mention-id="richardlane4">@richardlane4</span> I think <span data-mention-id="geez8tc">@Geez8tc</span> has it'
  )
})

test('stops hyphenated handles before trailing punctuation', () => {
  assert.equal(render('Thanks @sam-jones-.'), 'Thanks <span data-mention-id="sam-jones">@sam-jones</span>-.')
})

test('ignores email addresses and code', () => {
  assert.doesNotMatch(render('mail rob@loomio.org'), /data-mention-id/)
  assert.equal(render('`@sam`'), '<code>@sam</code>')
})
