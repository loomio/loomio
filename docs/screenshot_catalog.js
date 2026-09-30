// Discover capture names by running our trusted recipes with navigation and
// browser operations disabled. This also resolves names composed by helpers.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {createRequire} = require('node:module');

const root = path.resolve(__dirname, '..');
const directory = path.join(root, 'vue/tests/e2e/screenshots');
let chain;
chain = new Proxy(function() { return chain; }, {get() { return chain; }});
const captures = [];

for (const spec of fs.readdirSync(directory).filter(name => name.endsWith('.js')).sort()) {
  const filename = path.join(directory, spec);
  const localRequire = createRequire(filename);
  let testcase;
  const screenshot = Object.fromEntries(['capture', 'captureElement', 'captureRegion'].map(method => [method, name => {
    if (!/^[A-Za-z0-9][A-Za-z0-9/_-]*$/.test(name)) throw new Error(`Invalid screenshot name: ${name}`);
    const image = `${name.startsWith('guides/') ? '' : 'user_manual/'}${name}.png`;
    captures.push({image, spec, testcase});
  }]));
  const sandbox = {
    module: {exports: {}}, __dirname: directory,
    require(name) {
      if (name === '../helpers/pageHelper') return () => chain;
      if (name === '../helpers/manualScreenshot') return () => screenshot;
      return localRequire(name);
    }
  };
  vm.runInNewContext(fs.readFileSync(filename, 'utf8'), sandbox, {filename});
  for (const [name, run] of Object.entries(sandbox.module.exports)) {
    if (typeof run !== 'function' || name.startsWith('@')) continue;
    testcase = name;
    run(chain);
  }
}

const images = new Map();
for (const capture of captures) {
  // Only approved English assets are eligible. Photos, diagrams and manual
  // captures without a recipe remain shared English images.
  if (!fs.existsSync(path.join(root, 'docs/en', capture.image))) continue;
  if (images.has(capture.image)) throw new Error(`Duplicate screenshot recipe: ${capture.image}`);
  images.set(capture.image, capture);
}
process.stdout.write(JSON.stringify([...images.values()]));
