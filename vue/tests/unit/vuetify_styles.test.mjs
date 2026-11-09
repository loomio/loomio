import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { compile } from 'sass-embedded';

const root = new URL('../../', import.meta.url);
const vuetifyStyles = new URL('node_modules/vuetify/lib/styles/main.sass', root);
const classes = css => new Set([...css.matchAll(/\.([a-zA-Z][\w-]*)/g)].map(match => match[1]));

test('trimmed Vuetify styles retain the utility classes used by Vue and Rails', () => {
  const full = classes(readFileSync(new URL('node_modules/vuetify/lib/styles/main.css', root), 'utf8'));
  const trimmed = classes(compile(fileURLToPath(new URL('src/css/vuetify_styles.scss', root)), {
    importers: [{findFileUrl: url => url === 'vuetify' ? vuetifyStyles : null}]
  }).css);
  const removed = new Set([...full].filter(name => !trimmed.has(name)));
  const missing = [];

  // Scan whole source files so Pug shorthand and literal conditional classes
  // are covered too. Dynamically constructed component classes are kept intact.
  for (const directory of ['src/', '../app/views/', '../app/helpers/']) {
    const base = new URL(directory, root);
    for (const file of readdirSync(base, {recursive: true}).filter(name => /\.(vue|js|mjs|rb|erb)$/.test(name))) {
      const tokens = readFileSync(new URL(file, base), 'utf8').match(/[a-zA-Z][\w-]*/g) || [];
      for (const name of new Set(tokens.filter(token => removed.has(token)))) {
        missing.push(`${directory}${file}: ${name}`);
      }
    }
  }

  assert.deepEqual(missing, [], 'Re-enable utilities in src/css/vuetify_styles.scss before using them');
});
