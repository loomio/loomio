import { saveDraftImagePreviews } from '@/components/lmo_textarea/draft_image_content';

// Load conversion support only when switching modes. Update the format last,
// so failed conversion leaves the source and active editor intact. The
// converted HTML becomes the rich-text editor's seed, which names a fresh
// collaborative document, so cached drafts from before the switch don't return.

export async function convertToHtml(model, field) {
  const { markdownToHtml } = await import('./markdown_conversion');
  const html = markdownToHtml(model[field] || '');
  model[field] = html;
  model[`${field}Format`] = 'html';
}

export async function convertToMd(model, field, editor) {
  const { documentToMarkdown } = await import('./markdown_conversion');
  const doc = editor.getJSON();
  const markdown = documentToMarkdown(doc);
  saveDraftImagePreviews(model, field, doc);
  model[field] = markdown;
  model[`${field}Format`] = 'md';
}
