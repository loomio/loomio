import { isDraftImagePreview } from './draft_image_preview';

export const DRAFT_IMAGE_BUDGET = 4 * 1024 * 1024;

// Markdown keeps its regular image syntax. Preview bytes belong to the field's
// draft data, which travels with the model across editors and stays out of API serialization.
const imagePreviewsByField = Symbol('imagePreviewsByField');

function previewKey(src) {
  // The Markdown serializer can percent-encode characters in a signed URL.
  return src.replace(/(?:%[a-f0-9]{2})+/gi, encoded => {
    try {
      return decodeURI(encoded);
    } catch {
      return encoded;
    }
  });
}

function visitImages(node, visit) {
  if (node.type === 'image' && node.attrs?.src) visit(node.attrs);
  for (const child of node.content || []) visitImages(child, visit);
}

export function saveDraftImagePreviews(model, field, doc) {
  const previews = new Map();
  let remaining = DRAFT_IMAGE_BUDGET;
  visitImages(doc, ({ src, draftPreview }) => {
    if (!isDraftImagePreview(draftPreview) || draftPreview.length > remaining) return;

    const key = previewKey(src);
    if (previews.has(key)) return;

    previews.set(key, draftPreview);
    remaining -= draftPreview.length;
  });
  if (previews.size) {
    (model[imagePreviewsByField] ||= {})[field] = previews;
  } else if (model[imagePreviewsByField]) {
    delete model[imagePreviewsByField][field];
  }
}

export function rememberDraftImagePreview(model, field, src, preview) {
  if (!isDraftImagePreview(preview)) return;

  const previews = ((model[imagePreviewsByField] ||= {})[field] ||= new Map());
  const key = previewKey(src);
  const markdown = previewKey(model[field] || '');
  let size = preview.length;
  for (const [url, stored] of previews) {
    if (!markdown.includes(url)) {
      previews.delete(url);
    } else if (url !== key) {
      size += stored.length;
    }
  }
  if (size <= DRAFT_IMAGE_BUDGET) previews.set(key, preview);
}

export function draftImagePreviewFor(model, field, src) {
  return model[imagePreviewsByField]?.[field]?.get(previewKey(src));
}

export function restoreDraftImagePreviews(model, field, doc) {
  if (!model[imagePreviewsByField]?.[field]?.size) return;

  let remaining = DRAFT_IMAGE_BUDGET;
  visitImages(doc, attrs => {
    const preview = draftImagePreviewFor(model, field, attrs.src);
    if (!preview || preview.length > remaining) return;

    attrs.draftPreview = preview;
    remaining -= preview.length;
  });
  delete model[imagePreviewsByField][field];
}
