const fs = require('node:fs');
const path = require('node:path');

const images_dir = path.resolve(__dirname, '../../../../docs/user_manual/images');
const name_pattern = /^[a-z0-9][a-z0-9/_-]*$/;

module.exports = function(test) {
  return {
    capture(name, options = {}) {
      if (!name_pattern.test(name)) {
        throw new Error(`Invalid manual screenshot name: ${name}`);
      }

      const width = options.width || 1280;
      const height = options.height || 900;
      const image_path = path.join(images_dir, `${name}.png`);

      fs.mkdirSync(path.dirname(image_path), { recursive: true });

      test.execute(function() {
        let style = document.getElementById('manual-screenshot-styles');

        if (!style) {
          style = document.createElement('style');
          style.id = 'manual-screenshot-styles';
          style.textContent = `
            *, *::before, *::after {
              animation-delay: 0s !important;
              animation-duration: 0s !important;
              caret-color: transparent !important;
              scroll-behavior: auto !important;
              transition-delay: 0s !important;
              transition-duration: 0s !important;
            }
          `;
          document.head.appendChild(style);
        }
      });
      test.resizeWindow(width, height);
      test.pause(300);
      test.execute(function() {
        window.scrollTo(0, 0);
      });

      return test.saveScreenshot(image_path);
    }
  };
};
