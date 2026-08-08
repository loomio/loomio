#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const siteRoot = path.resolve(process.argv[2] || 'public/en');
const excludedNames = new Set([
  '404.html',
  'error.html',
  'maintenance.html',
  'print.html',
  'toc.html'
]);

function htmlFiles(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
    const entryPath = path.join(directory, entry.name);
    return entry.isDirectory() ? htmlFiles(entryPath) : [entryPath];
  }).filter(file => file.endsWith('.html'));
}

function decodeEntities(value) {
  const named = {
    amp: '&',
    apos: "'",
    gt: '>',
    lt: '<',
    nbsp: ' ',
    quot: '"'
  };

  return value.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (entity, code) => {
    if (code[0] !== '#') return named[code.toLowerCase()] || entity;
    const number = code[1].toLowerCase() === 'x'
      ? parseInt(code.slice(2), 16)
      : parseInt(code.slice(1), 10);
    return Number.isFinite(number) && number >= 0 && number <= 0x10ffff
      ? String.fromCodePoint(number)
      : entity;
  });
}

function textFromHtml(value) {
  return decodeEntities(value
    .replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' '))
    .replace(/\s+/g, ' ')
    .trim();
}

function truncate(value, maxLength = 160) {
  if (value.length <= maxLength) return value;
  const shortened = value.slice(0, maxLength - 1);
  const lastSpace = shortened.lastIndexOf(' ');
  return `${shortened.slice(0, lastSpace > 110 ? lastSpace : maxLength - 1)}…`;
}

function escapeAttribute(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function descriptionFor(html, file) {
  const override = html.match(/<!--\s*seo-description:\s*([\s\S]*?)\s*-->/i);
  if (override) return truncate(textFromHtml(override[1]));

  const main = html.match(/<main\b[^>]*>([\s\S]*?)<\/main>/i);
  if (!main) throw new Error(`${file}: missing <main> content`);

  const paragraphs = main[1].matchAll(/<p\b[^>]*>([\s\S]*?)<\/p>/gi);
  for (const paragraph of paragraphs) {
    const text = textFromHtml(paragraph[1]);
    if (text.length >= 40) return truncate(text);
  }

  const heading = main[1].match(/<h1\b[^>]*>([\s\S]*?)<\/h1>/i);
  if (heading) {
    return truncate(`${textFromHtml(heading[1])}. Help and guidance for using Loomio.`);
  }

  throw new Error(`${file}: could not derive a meta description`);
}

if (!fs.existsSync(siteRoot)) {
  throw new Error(`Site directory does not exist: ${siteRoot}`);
}

let updated = 0;
for (const file of htmlFiles(siteRoot)) {
  if (excludedNames.has(path.basename(file))) continue;

  let html = fs.readFileSync(file, 'utf8');
  if (/http-equiv="refresh"/i.test(html)) continue;

  const description = escapeAttribute(descriptionFor(html, file));
  const tag = `<meta name="description" content="${description}">`;

  if (/<meta name="description" content="[^"]*">/i.test(html)) {
    html = html.replace(/<meta name="description" content="[^"]*">/i, tag);
  } else if (/<link rel="canonical"[^>]*>/i.test(html)) {
    html = html.replace(/(<link rel="canonical"[^>]*>)/i, `$1\n        ${tag}`);
  } else {
    throw new Error(`${file}: missing canonical link for description insertion`);
  }

  fs.writeFileSync(file, html);
  updated += 1;
}

console.log(`generated descriptions for ${updated} pages`);
