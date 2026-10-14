import { Editor, generateJSON } from '@tiptap/core';
import { marked } from 'marked';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { contentExtensions } from '@/components/lmo_textarea/content_extensions';
import { documentToMarkdown, markdownToHtml } from '@/shared/services/markdown_conversion';
import { convertToHtml, convertToMd, takeConvertedContent } from '@/shared/services/format_converter';
import { customRenderer, options } from '@/shared/helpers/marked';
import compatibility from '../../../test/fixtures/files/markdown_conversion.json';

vi.mock('@/shared/services/session', () => ({ default: { user: () => ({ id: 42 }) } }));

const extensions = contentExtensions();
const fromHtml = html => documentToMarkdown(generateJSON(html, extensions));
const fragment = html => {
  const template = document.createElement('template');
  template.innerHTML = html;
  return template.content;
};
const display = markdown => fragment(marked(markdown, { ...options, renderer: customRenderer() }));
const editors = [];
afterEach(() => editors.splice(0).forEach(editor => editor.destroy()));

describe('Markdown mode conversion', () => {
  it('switches an empty rich-text editor to Markdown and back', async () => {
    const model = { body: '<p></p>', bodyFormat: 'html' };
    const editor = new Editor({ extensions: contentExtensions(), content: model.body });
    editors.push(editor);
    await convertToMd(model, 'body', editor);
    expect(model).toEqual({ body: '', bodyFormat: 'md' });
    await convertToHtml(model, 'body');
    expect(model.bodyFormat).toBe('html');
    expect(fragment(model.body).textContent).toBe('');
  });

  it.each(compatibility)('emits Markdown covered by server compatibility tests: $name', fixture => {
    expect(fromHtml(fixture.html).trim()).toBe(fixture.markdown);
  });

  it('converts blank paragraphs among text and empty table cells without losing content', () => {
    const markdown = fromHtml('<p>Before</p><p></p><p>After</p><table><tr><th>Name</th><th>Vote</th></tr><tr><td>Alice</td><td><p></p></td></tr></table>');
    const doc = display(markdown);
    expect(doc.textContent).toContain('Before');
    expect(doc.textContent).toContain('After');
    expect([...doc.querySelectorAll('tbody td')].map(cell => cell.textContent)).toEqual(['Alice', '']);
  });

  it('preserves tables, formatting, and cell boundaries through both editors', () => {
    const markdown = fromHtml('<table><tr><th>Name</th><th>Vote</th></tr><tr><td><strong>Alice</strong></td><td>Yes | maybe</td></tr></table>');
    for (const html of [markdownToHtml(markdown), display(markdown)]) {
      const doc = typeof html === 'string' ? fragment(html) : html;
      expect([...doc.querySelectorAll('tr')].map(row => [...row.children].map(cell => cell.textContent))).toEqual([
        ['Name', 'Vote'], ['Alice', 'Yes | maybe'],
      ]);
      expect(doc.querySelector('strong').textContent).toBe('Alice');
    }
  });

  it('retains text from coloured spans, highlights, and underlining without custom syntax', () => {
    const markdown = fromHtml('<p><span style="color: red">Colour</span> <mark data-color="yellow">highlight</mark> <u>underline</u></p>');
    expect(markdown).toBe('Colour highlight underline');
    expect(display(markdown).textContent.trim()).toBe('Colour highlight underline');
  });

  it('preserves checked tasks and nesting, giving each imported task its own identity', () => {
    const markdown = fromHtml('<ul data-type="taskList"><li data-type="taskItem" data-checked="true"><p>Done</p><ul data-type="taskList"><li data-type="taskItem" data-checked="false"><p>Next</p></li></ul></li></ul>');
    expect(markdown).toContain('- [x] Done');
    expect(markdown).toContain('  - [ ] Next');
    const doc = fragment(markdownToHtml(markdown));
    const tasks = [...doc.querySelectorAll('li[data-type="taskItem"]')];
    expect(tasks.map(task => task.dataset.checked)).toEqual(['true', 'false']);
    expect(new Set(tasks.map(task => task.dataset.uid)).size).toBe(2);
    expect(tasks[0].querySelector('ul li')).toBe(tasks[1]);
    expect(display(markdown).querySelectorAll('input[type="checkbox"]')).toHaveLength(2);
  });

  it('exports mentions by handle and restores them as mention nodes', () => {
    const markdown = fromHtml('<p>Hello <span data-mention-id="sam-one" data-label="Sam One">@Sam One</span> and <span data-mention-id="our-group" data-label="Our group">@Our group</span></p>');
    expect(markdown).toBe('Hello @sam-one and @our-group');
    const mentions = fragment(markdownToHtml(markdown)).querySelectorAll('span[data-mention-id]');
    expect([...mentions].map(mention => mention.dataset.mentionId)).toEqual(['sam-one', 'our-group']);
  });

  it('matches handle boundaries without converting addresses, escapes, or code into mentions', () => {
    const html = markdownToHtml('Hi @SAM-one, (@our-group). x@sam-one example@example.com \\@escaped `@inline`\n\n```\n@fenced\n```');
    const doc = fragment(html);
    expect([...doc.querySelectorAll('[data-mention-id]')].map(mention => mention.dataset.mentionId)).toEqual(['sam-one', 'our-group']);
    expect(doc.querySelector('p code').textContent).toBe('@inline');
    expect(doc.querySelector('pre code').textContent).toBe('@fenced');
  });

  it('retains newlines, nested lists, inline code, and fenced code', () => {
    const html = markdownToHtml('First\nSecond\n\n- Parent\n  - Child\n\n`inline`\n\n```js\nconst x = "<tag>";\n```');
    const markdown = fromHtml(html);
    const doc = display(markdown);
    expect(doc.querySelector('p').innerHTML).toContain('First<br>');
    expect(doc.querySelector('ul ul li').textContent).toContain('Child');
    expect(doc.querySelector('p code').textContent).toBe('inline');
    expect(doc.querySelector('pre code').textContent.trim()).toBe('const x = "<tag>";');
  });

  it('retains images and converts uploaded media and embeds into usable links', () => {
    const markdown = fromHtml('<p>Look</p><img src="/image (1).png" alt="A [picture]" title="A &quot;title&quot;"><video src="/clip (1).mp4"></video><audio src="/sound.mp3"></audio><iframe src="https://example.com/embed"></iframe>');
    const doc = display(markdown);
    expect(doc.querySelector('img').getAttribute('src')).toBe('/image%20%281%29.png');
    expect(doc.querySelector('img').getAttribute('alt')).toBe('A [picture]');
    expect(doc.querySelector('img').getAttribute('title')).toBe('A "title"');
    expect([...doc.querySelectorAll('a')].map(link => link.getAttribute('href'))).toEqual([
      '/clip%20%281%29.mp4', '/sound.mp3', 'https://example.com/embed',
    ]);
    expect(fragment(markdownToHtml(markdown)).querySelector('img')).not.toBeNull();
  });

  it.each([
    '[click](javascript:alert%281%29)',
    '![image](javascript:alert%281%29)',
    '![image](data:text/html,evil)',
    '<img src="java&#9;script:alert(1)" onerror="alert(1)">',
    '<a href="javascript:alert(1)" onclick="alert(1)">click</a>',
    '<iframe src="javascript:alert(1)"></iframe>',
    '[encoded](java&#x73;cript&#58;alert%281%29)',
    '<script>alert(1)</script>',
  ])('does not introduce executable URLs or event attributes: %s', source => {
    const doc = fragment(markdownToHtml(source));
    expect(doc.querySelector('script')).toBeNull();
    for (const element of doc.querySelectorAll('*')) {
      expect([...element.attributes].filter(attribute => attribute.name.startsWith('on'))).toEqual([]);
      for (const name of ['href', 'src']) {
        expect((element.getAttribute(name) || '').replace(/\s/g, '')).not.toMatch(/^(javascript|data):/i);
      }
    }
  });

  it('retains every data row when a table has no header', () => {
    const markdown = fromHtml('<table><tr><td>Alice</td><td>Yes</td></tr><tr><td>Bob</td><td>No</td></tr></table>');
    expect([...display(markdown).querySelectorAll('tbody tr')].map(row => [...row.children].map(cell => cell.textContent))).toEqual([
      ['Alice', 'Yes'], ['Bob', 'No'],
    ]);
  });

  it('preserves ordinary links and literal Markdown punctuation', () => {
    const markdown = fromHtml('<p><a href="https://example.com/a (b)">A link</a> *literal* [text]</p>');
    const doc = display(markdown);
    expect(doc.textContent.trim()).toBe('A link *literal* [text]');
    expect(doc.querySelector('a').getAttribute('href')).toBe('https://example.com/a%20%28b%29');
    expect(doc.querySelector('em')).toBeNull();
  });

  it('switches the model using the current editor document, including unsaved edits', async () => {
    const model = { body: '<p>Old</p>', bodyFormat: 'html' };
    const editor = new Editor({ extensions: contentExtensions(), content: '<p><strong>Latest</strong></p>' });
    editors.push(editor);
    await convertToMd(model, 'body', editor);
    expect(model).toEqual({ body: '**Latest**', bodyFormat: 'md' });
    await convertToHtml(model, 'body');
    expect(model.bodyFormat).toBe('html');
    expect(fragment(model.body).querySelector('strong').textContent).toBe('Latest');
  });

  it('leaves the original field and format intact if conversion fails', async () => {
    const model = { body: '<p>Original</p>', bodyFormat: 'html' };
    await expect(convertToMd(model, 'body', { getJSON() { throw new Error('failed'); } })).rejects.toThrow('failed');
    expect(model).toEqual({ body: '<p>Original</p>', bodyFormat: 'html' });
  });

  it('replaces a cached rich-text draft with converted content exactly once per field', async () => {
    const model = { body: 'New **draft**', bodyFormat: 'md', reason: '', reasonFormat: 'md' };
    await convertToHtml(model, 'body');
    await convertToHtml(model, 'reason');
    expect(takeConvertedContent(model, 'body')).toBe(model.body);
    expect(takeConvertedContent(model, 'body')).toBeUndefined();
    expect(takeConvertedContent(model, 'reason')).toBe(model.reason);
    expect(takeConvertedContent({}, 'body')).toBeUndefined();
  });

  it('does not introduce underline syntax that Markdown display treats as literal text', () => {
    expect(fragment(markdownToHtml('++literal++')).textContent).toBe('++literal++');
    expect(fragment(markdownToHtml('++literal++')).querySelector('u')).toBeNull();
  });

  it.each(['# literal heading', '- literal bullet', '1. literal number', '> literal quote', '---'])('retains literal paragraph text: %s', text => {
    const markdown = fromHtml(`<p>${text.replace('>', '&gt;')}</p>`);
    const doc = display(markdown);
    expect(doc.querySelector('p')?.textContent).toBe(text);
    expect(doc.querySelector('h1,ul,ol,blockquote,hr')).toBeNull();
  });
});
