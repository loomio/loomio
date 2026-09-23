function featureSet(seed) {
  return Array.from(seed).reduce((total, character) => total + character.charCodeAt(0), 0) % 4;
}

function context(seed, paragraphs) {
  if (paragraphs.length !== 3) {
    throw new Error('Oatmilk example contexts must contain three paragraphs');
  }

  const [first, second, third] = paragraphs;

  switch (featureSet(seed)) {
    case 0:
      return `<p>${first} 🥛</p><p><strong>${second}</strong></p><p>${third} See the <a href="https://example.com/oatmilk-bottle-guide">bottle trial guide</a>.</p>`;
    case 1:
      return `<p><mark>${first}</mark></p><blockquote><p>${second}</p></blockquote><p><em>${third}</em></p>`;
    case 2:
      return `<p><strong>${first}</strong></p><p><em>${second}</em></p><p>${third} 🌾</p>`;
    default:
      return `<p>${first} Read the <a href="https://example.com/oatmilk-operations-plan">operations plan</a>.</p><p><mark>${second}</mark></p><p>${third} ✅</p>`;
  }
}

module.exports = {context};
