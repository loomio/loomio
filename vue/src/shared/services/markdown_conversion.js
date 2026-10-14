import { generateHTML } from '@tiptap/core';
import { MarkdownManager } from '@tiptap/markdown';
import { contentExtensions } from '@/components/lmo_textarea/content_extensions';
import { safeUrl } from '@/shared/helpers/safe_url.mjs';

const extensions = contentExtensions();
const markdown = new MarkdownManager({
  extensions,
  markedOptions: { gfm: true, breaks: true },
});

// Apply the same URL policy as Markdown display, including embedded HTML.
// Parsing into the editor schema retains only supported nodes and attributes.
function sanitizeUrls(node) {
  for (const attribute of ['href', 'src', 'poster']) {
    if (node.attrs?.[attribute]) node.attrs[attribute] = safeUrl(node.attrs[attribute]);
  }
  for (const mark of node.marks || []) sanitizeUrls(mark);
  for (const child of node.content || []) sanitizeUrls(child);
  return node;
}

export function markdownToHtml(source) {
  return generateHTML(sanitizeUrls(markdown.parse(source)), extensions);
}

export function documentToMarkdown(document) {
  return markdown.serialize(document);
}
