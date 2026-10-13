import Blockquote from '@tiptap/extension-blockquote';
import Bold from '@tiptap/extension-bold';
import Code from '@tiptap/extension-code';
import CodeBlock from '@tiptap/extension-code-block';
import Document from '@tiptap/extension-document';
import HardBreak from '@tiptap/extension-hard-break';
import Heading from '@tiptap/extension-heading';
import HorizontalRule from '@tiptap/extension-horizontal-rule';
import Italic from '@tiptap/extension-italic';
import Paragraph from '@tiptap/extension-paragraph';
import Strike from '@tiptap/extension-strike';
import { Table, TableRow, TableCell, TableHeader } from '@tiptap/extension-table';
import { BulletList, OrderedList, ListItem, ListKeymap } from '@tiptap/extension-list';
import { TextStyle } from '@tiptap/extension-text-style';
import Text from '@tiptap/extension-text';
import Underline from '@tiptap/extension-underline';
import { CustomTaskItem } from './extension_custom_task_item';
import { CustomTaskList } from './extension_custom_task_list';
import { CustomMention } from './extension_mention';
import { CustomLink } from './extension_link';
import { CustomImage, Video, Audio } from './extension_image';
import { Iframe } from './extension_iframe';
import { TextAlign } from './extension_text_align';
import { Highlight } from './extension_highlight';
import { safeUrl } from '@/shared/helpers/safe_url.mjs';

// The editor and mode-switch converters share a schema. Unsupported Markdown
// styling is deliberately dropped while its text is retained; in particular,
// Tiptap's ++underline++ syntax is not understood by our display renderers.
const renderText = (node, helpers) => helpers.renderChildren(node);
const renderParagraph = (node, helpers) => {
  // Tiptap escapes inline delimiters but leaves block delimiters untouched.
  // A literal heading, list, or rule inside a paragraph must remain text.
  return helpers.renderChildren(node)
    .replace(/^([ \t]{0,3})(#{1,6}|[+-])(?=\s)/gm, '$1\\$2')
    .replace(/^([ \t]{0,3}\d{1,9})([.)])(?=\s)/gm, '$1\\$2')
    .replace(/^([ \t]{0,3})([-=])(?=[-= \t]*$)/gm, '$1\\$2');
};

// Destinations and image labels must not introduce Markdown syntax. Keep URLs
// with spaces or parentheses usable, and escape quotes in optional titles.
const markdownUrl = url => String(safeUrl(url) || '').replace(/[\s<>()\\"]/g, character => {
  return encodeURIComponent(character).replace(/[()]/g, bracket => `%${bracket.charCodeAt(0).toString(16)}`);
});
const markdownTitle = title => title ? ` "${title.replace(/[\\"]/g, '\\$&')}"` : '';
const renderLink = (node, helpers) => `[${helpers.renderChildren(node)}](${markdownUrl(node.attrs.href)}${markdownTitle(node.attrs.title)})`;
const renderImage = node => `![${(node.attrs.alt || '').replace(/[\\\[\]]/g, '\\$&')}](${markdownUrl(node.attrs.src)}${markdownTitle(node.attrs.title)})`;
const renderMedia = (node, helpers) => renderLink({
  attrs: { href: node.attrs.src },
  content: [{ type: 'text', text: node.attrs.src }],
}, helpers);

const MarkdownMention = CustomMention.extend({
  renderMarkdown: node => `@${node.attrs.id}`,
  parseMarkdown: (token, helpers) => helpers.createNode('mention', {
    id: token.handle.toLowerCase(),
    label: token.handle,
  }),
  markdownTokenizer: {
    name: 'mention',
    level: 'inline',
    start(source) {
      // Avoid lookbehind: supported Safari versions cannot parse it.
      const match = /(^|[^\p{L}\p{N}_])(@[a-z0-9_]+(?:-[a-z0-9_]+)*)/iu.exec(source);
      return match ? match.index + match[1].length : -1;
    },
    tokenize(source, tokens) {
      // Match the server's handle boundaries, excluding addresses and escaped @.
      if (/[\p{L}\p{N}_]$/u.test(tokens.at(-1)?.raw || '')) return;
      const match = /^@([a-z0-9_]+(?:-[a-z0-9_]+)*)/i.exec(source);
      if (match) return { type: 'mention', raw: match[0], handle: match[1] };
    },
  },
});

export function contentExtensions({ attachFile, attachImageFile, mentionOptions = {} } = {}) {
  return [
    Blockquote,
    Bold,
    Code,
    BulletList, OrderedList, ListItem, ListKeymap,
    CodeBlock,
    CustomImage.extend({ renderMarkdown: renderImage }).configure({ attachFile, attachImageFile }),
    Video.extend({ renderMarkdown: renderMedia }),
    Audio.extend({ renderMarkdown: renderMedia }),
    Document,
    HardBreak,
    Heading,
    Highlight.extend({ renderMarkdown: renderText }).configure({ multicolor: true }),
    HorizontalRule,
    Italic,
    Iframe.extend({ renderMarkdown: renderMedia }),
    CustomLink.extend({ renderMarkdown: renderLink }),
    Paragraph.extend({ renderMarkdown: renderParagraph }),
    Strike,
    Text,
    Table, TableHeader, TableRow, TableCell,
    CustomTaskList,
    CustomTaskItem.configure({ nested: true }),
    MarkdownMention.configure(mentionOptions),
    TextStyle.extend({ renderMarkdown: renderText }),
    TextAlign.configure({ types: ['heading', 'paragraph'] }),
    Underline.extend({ renderMarkdown: renderText, markdownTokenizer: null }),
  ];
}
