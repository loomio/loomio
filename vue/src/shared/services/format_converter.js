// Load conversion support only when switching modes. Update the format last,
// so failed conversion leaves the source and active editor intact.
const convertedContent = new WeakMap();

export async function convertToHtml(model, field) {
  const { markdownToHtml } = await import('./markdown_conversion');
  const html = markdownToHtml(model[field] || '');
  if (!convertedContent.has(model)) convertedContent.set(model, new Map());
  convertedContent.get(model).set(field, html);
  model[field] = html;
  model[`${field}Format`] = 'html';
}

// Explicit conversion replaces the cached collaborative draft on its first
// sync. Otherwise switching back would restore the rich text from before any
// Markdown edits. Keep this transient state out of model attributes and saves.
export function takeConvertedContent(model, field) {
  if (!convertedContent.has(model)) return;
  const fields = convertedContent.get(model);
  const html = fields.get(field);
  fields.delete(field);
  if (fields.size === 0) convertedContent.delete(model);
  return html;
}

export async function convertToMd(model, field, editor) {
  const { documentToMarkdown } = await import('./markdown_conversion');
  const markdown = documentToMarkdown(editor.getJSON());
  model[field] = markdown;
  model[`${field}Format`] = 'md';
}
