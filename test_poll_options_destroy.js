#!/usr/bin/env node

/**
 * Test to demonstrate the bug and fix for poll options _destroy parameter
 *
 * Bug: When using lodash's snakeCase() on poll option attributes,
 * the '_destroy' key gets converted to 'destroy', which is not permitted
 * by Rails strong parameters.
 *
 * Fix: Preserve the '_destroy' key when converting to snake_case.
 */

// Simple implementation of snakeCase for testing (mimics lodash behavior)
function snakeCase(str) {
  return str
    .replace(/^_+/, '') // Remove leading underscores
    .replace(/([A-Z])/g, '_$1')
    .replace(/[-\s]+/g, '_')
    .toLowerCase()
    .replace(/^_/, '');
}

// Simple implementation of mapKeys for testing
function mapKeys(obj, fn) {
  const result = {};
  Object.keys(obj).forEach((key, index) => {
    const newKey = fn(obj[key], key, index);
    result[newKey] = obj[key];
  });
  return result;
}

// Simulate poll options with _destroy flag (using actual poll option fields)
const pollOptions = [
  { id: 1, name: 'Option 1', testOperator: 'greater_than', testPercent: 50 },
  { id: 2, name: 'Option 2', testOperator: 'less_than', testPercent: 25, _destroy: 1 }
];

console.log('Testing poll options transformation\n');
console.log('Original poll options:', JSON.stringify(pollOptions, null, 2));

// BUG: This was the original code that caused the issue
console.log('\n--- BUG: Original transformation (without fix) ---');
const buggyTransform = pollOptions.map((o) => mapKeys(o, (_, k) => snakeCase(k)));
console.log('Result:', JSON.stringify(buggyTransform, null, 2));

const option2Buggy = buggyTransform[1];
if (option2Buggy.destroy !== undefined) {
  console.log('❌ BUG CONFIRMED: _destroy was converted to "destroy"');
  console.log('   This causes Rails error: "found unpermitted parameter: :destroy"');
} else if (option2Buggy._destroy !== undefined) {
  console.log('✓ _destroy was preserved correctly');
}

// FIX: Preserve _destroy key
console.log('\n--- FIX: Transformation with _destroy preserved ---');
const fixedTransform = pollOptions.map((o) => mapKeys(o, (_, k) => k === '_destroy' ? k : snakeCase(k)));
console.log('Result:', JSON.stringify(fixedTransform, null, 2));

const option2Fixed = fixedTransform[1];
if (option2Fixed._destroy !== undefined && option2Fixed.destroy === undefined) {
  console.log('✅ FIX VERIFIED: _destroy is preserved correctly');
  console.log('   Rails will now accept this parameter!');
} else {
  console.log('❌ Fix did not work as expected');
}

// Summary
console.log('\n--- SUMMARY ---');
console.log('The bug occurred because lodash snakeCase("_destroy") returns "destroy"');
console.log('The fix checks if key === "_destroy" before applying snakeCase()');
console.log('\nTest keys:');
console.log(`  snakeCase("_destroy") = "${snakeCase("_destroy")}"  ❌ Wrong!`);
console.log(`  "_destroy" (preserved) = "_destroy"  ✅ Correct!`);
