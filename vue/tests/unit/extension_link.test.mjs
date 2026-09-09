import assert from 'node:assert/strict'
import test from 'node:test'

import { getSchema } from '@tiptap/core'
import Document from '@tiptap/extension-document'
import Paragraph from '@tiptap/extension-paragraph'
import Text from '@tiptap/extension-text'
import { EditorState, TextSelection } from '@tiptap/pm/state'

import { CustomLink } from '../../src/components/lmo_textarea/extension_link.js'

test('typing after a completed link does not extend the link', () => {
  const schema = getSchema([Document, Paragraph, Text, CustomLink])
  const link = schema.marks.link.create({ href: 'https://example.com' })
  const linkedText = schema.text('example.com', [link])
  const doc = schema.node('doc', null, [schema.node('paragraph', null, [linkedText])])
  const selection = TextSelection.atEnd(doc)
  const state = EditorState.create({ doc, selection })

  const nextState = state.apply(state.tr.insertText(' more'))
  const paragraph = nextState.doc.firstChild

  assert.equal(paragraph.childCount, 2)
  assert.equal(paragraph.child(0).text, 'example.com')
  assert.equal(paragraph.child(0).marks[0].type.name, 'link')
  assert.equal(paragraph.child(1).text, ' more')
  assert.equal(paragraph.child(1).marks.length, 0)
})

test('bare automatically linked URLs default to HTTPS', () => {
  assert.equal(CustomLink.options.defaultProtocol, 'https')
})
