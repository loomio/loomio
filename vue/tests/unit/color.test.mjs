import assert from 'node:assert/strict';
import test from 'node:test';

import { colorIsTransparent } from '../../src/shared/helpers/color.mjs';

test('recognizes colors with zero alpha', () => {
  [
    'transparent',
    'rgba(0, 0, 0, 0)',
    'rgb(0 0 0 / 0%)',
    'hsla(0, 0%, 0%, 0.0)',
    '#0000',
    '#ffffff00',
    { r: 0, g: 0, b: 0, a: 0 },
  ].forEach(color => assert.equal(colorIsTransparent(color), true));
});

test('does not treat opaque or translucent colors as transparent', () => {
  [
    null,
    '#000',
    '#000000',
    '#00000001',
    'rgba(0, 0, 0, 0.1)',
    'rgb(0 0 0 / 10%)',
    { r: 0, g: 0, b: 0, a: 0.1 },
  ].forEach(color => assert.equal(colorIsTransparent(color), false));
});
