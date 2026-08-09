const fs = require('node:fs');
const path = require('node:path');
const {spawnSync} = require('node:child_process');

const manualDir = path.resolve(__dirname, '../../../../docs/user_manual');
const repoDir = path.resolve(__dirname, '../../../..');
const spotlightScript = path.join(repoDir, 'bin/spotlight-screenshot');
const cropScript = path.join(repoDir, 'bin/crop-screenshot');
const namePattern = /^[A-Za-z0-9][A-Za-z0-9/_-]*$/;

module.exports = function(test) {
  function imagePath(name) {
    if (!namePattern.test(name)) {
      throw new Error(`Invalid manual screenshot name: ${name}`);
    }

    const imagePath = path.join(manualDir, `${name}.png`);
    fs.mkdirSync(path.dirname(imagePath), {recursive: true});
    return imagePath;
  }

  function prepare(options) {
    const width = options.width || 1280;
    const height = options.height || 900;

    test.resizeWindow(width, height);
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
    test.pause(300);
  }

  function spotlightGeometry(spotlight, captureSelector) {
    if (!spotlight) {
      return null;
    }

    const options = typeof spotlight === 'string' ? {selector: spotlight} : spotlight;
    const selectors = options.selectors || [options.selector].filter(Boolean);
    if (!selectors.length) {
      throw new Error('A spotlight selector or selectors list is required');
    }

    const geometry = {options};
    test.execute(function(selectors, rootSelector) {
      const targets = selectors.map((selector) => document.querySelector(selector));
      const root = rootSelector ? document.querySelector(rootSelector) : null;

      const missingIndex = targets.findIndex((target) => !target);
      if (missingIndex !== -1) {
        return {error: `Spotlight target not found: ${selectors[missingIndex]}`};
      }
      if (rootSelector && !root) {
        return {error: `Screenshot root not found: ${rootSelector}`};
      }

      const targetRects = targets.map((target) => target.getBoundingClientRect());
      const targetLeft = Math.min(...targetRects.map((rect) => rect.left));
      const targetTop = Math.min(...targetRects.map((rect) => rect.top));
      const targetRight = Math.max(...targetRects.map((rect) => rect.right));
      const targetBottom = Math.max(...targetRects.map((rect) => rect.bottom));
      const rootRect = root ? root.getBoundingClientRect() : {
        left: 0,
        top: 0,
        width: window.innerWidth,
        height: window.innerHeight
      };

      return {
        x: targetLeft - rootRect.left,
        y: targetTop - rootRect.top,
        width: targetRight - targetLeft,
        height: targetBottom - targetTop,
        baseWidth: rootRect.width,
        baseHeight: rootRect.height
      };
    }, [selectors, captureSelector], (result) => {
      geometry.rect = result.value;
    });

    return geometry;
  }

  function applySpotlight(outputPath, geometry) {
    if (!geometry) {
      return;
    }
    if (!geometry.rect || geometry.rect.error) {
      throw new Error(geometry.rect?.error || 'Could not measure spotlight target');
    }

    const result = spawnSync(
      'bundle',
      ['exec', 'ruby', spotlightScript, outputPath, JSON.stringify({...geometry.rect, ...geometry.options})],
      {cwd: repoDir, encoding: 'utf8'}
    );

    if (result.status !== 0) {
      throw new Error(`Could not apply screenshot spotlight: ${result.stderr || result.stdout}`);
    }
  }

  function applyCrop(outputPath, geometry, padding) {
    if (!geometry.rect || geometry.rect.error) {
      throw new Error(geometry.rect?.error || 'Could not measure screenshot region');
    }

    const result = spawnSync(
      'bundle',
      ['exec', 'ruby', cropScript, outputPath, JSON.stringify({...geometry.rect, padding})],
      {cwd: repoDir, encoding: 'utf8'}
    );

    if (result.status !== 0) {
      throw new Error(`Could not crop screenshot: ${result.stderr || result.stdout}`);
    }
  }

  return {
    capture(name, options = {}) {
      const outputPath = imagePath(name);
      prepare(options);
      test.execute(function(scrollSelector, scrollBlock) {
        if (scrollSelector) {
          document.querySelector(scrollSelector)?.scrollIntoView({block: scrollBlock || 'center'});
        } else {
          window.scrollTo(0, 0);
        }
      }, [options.scrollSelector, options.scrollBlock]);
      test.pause(200);
      const geometry = spotlightGeometry(options.spotlight, null);

      return test.saveScreenshot(outputPath, () => applySpotlight(outputPath, geometry));
    },

    captureElement(name, selector, options = {}) {
      const outputPath = imagePath(name);
      prepare(options);
      test.waitForElementVisible(selector);
      const geometry = spotlightGeometry(options.spotlight, selector);

      return test.takeElementScreenshot(selector, (result) => {
        fs.writeFileSync(outputPath, Buffer.from(result.value, 'base64'));
        applySpotlight(outputPath, geometry);
      });
    },

    captureRegion(name, selectors, options = {}) {
      const outputPath = imagePath(name);
      prepare(options);
      selectors.forEach((selector) => test.waitForElementVisible(selector));
      const geometry = spotlightGeometry({selectors}, null);
      const spotlight = spotlightGeometry(options.spotlight, null);
      test.pause(200);

      return test.saveScreenshot(outputPath, () => {
        const padding = options.padding ?? 12;
        applyCrop(outputPath, geometry, padding);

        if (spotlight) {
          const region = geometry.rect;
          const left = Math.max(region.x - padding, 0);
          const top = Math.max(region.y - padding, 0);
          const right = Math.min(region.x + region.width + padding, region.baseWidth);
          const bottom = Math.min(region.y + region.height + padding, region.baseHeight);
          spotlight.rect = {
            ...spotlight.rect,
            x: spotlight.rect.x - left,
            y: spotlight.rect.y - top,
            baseWidth: right - left,
            baseHeight: bottom - top
          };
          applySpotlight(outputPath, spotlight);
        }
      });
    }
  };
};
