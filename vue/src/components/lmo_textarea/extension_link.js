import Link from '@tiptap/extension-link'

// Keep the cursor outside a completed link while retaining automatic linking for typed and pasted URLs.
export const CustomLink = Link.extend({
  inclusive: false,
}).configure({
  defaultProtocol: 'https',
})
