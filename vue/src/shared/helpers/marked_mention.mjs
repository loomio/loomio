// Render Markdown @handles as the same mention spans the rich-text editor
// saves, so published mentions look identical in both formats. Handle and
// boundary rules match MentionParser::MARKDOWN_PATTERN on the server and the
// Markdown tokenizer in lmo_textarea/content_extensions.js.
export const markedMention = {
  name: 'mention',
  level: 'inline',
  start(source) {
    // Avoid lookbehind: supported Safari versions cannot parse it.
    const match = /(^|[^\p{L}\p{N}_])(@[a-z0-9_]+(?:-[a-z0-9_]+)*)/iu.exec(source);
    return match ? match.index + match[1].length : undefined;
  },
  tokenizer(source, tokens) {
    // Exclude email addresses and other @ signs that follow a word character.
    if (/[\p{L}\p{N}_]$/u.test(tokens.at(-1)?.raw || '')) { return; }
    const match = /^@([a-z0-9_]+(?:-[a-z0-9_]+)*)/i.exec(source);
    if (match) { return { type: 'mention', raw: match[0], handle: match[1] }; }
  },
  // The handle pattern only allows characters that are safe in HTML.
  renderer(token) {
    return `<span data-mention-id="${token.handle.toLowerCase()}">@${token.handle}</span>`;
  },
};
