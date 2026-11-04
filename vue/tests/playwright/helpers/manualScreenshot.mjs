import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repoDir = path.resolve(here, '../../../..');
const manualDir = path.join(repoDir, 'docs/help/en/user_manual');
const docsDir = path.join(repoDir, 'docs/help/en');
const spotlightScript = path.join(repoDir, 'bin/spotlight-screenshot');
const cropScript = path.join(repoDir, 'bin/crop-screenshot');
const compressScript = path.join(repoDir, 'bin/compress-screenshot');
export const namePattern = /^[A-Za-z0-9][A-Za-z0-9/_-]*$/;

function runRuby(script, args, failure) {
  const result = spawnSync('bundle', ['exec', 'ruby', script, ...args], { cwd: repoDir, encoding: 'utf8' });
  if (result.status !== 0) {
    throw new Error(`${failure}: ${result.stderr || result.stdout}`);
  }
}

// Captures user-manual screenshots from a Playwright page. The page's context
// sets the device scale (2× for the manual) and locale; this helper fixes the
// CSS viewport, freezes animation, and post-processes the PNG with the Ruby
// crop, spotlight, and compression scripts.
export function manualScreenshot(page, { outputDir } = {}) {
  function imagePath(name) {
    if (!namePattern.test(name)) {
      throw new Error(`Invalid manual screenshot name: ${name}`);
    }

    const generatedRoot = process.env.DOCS_SCREENSHOT_OUTPUT;
    const imageRoot = generatedRoot || outputDir || (name.startsWith('guides/') ? docsDir : manualDir);
    const imageName = generatedRoot && !name.startsWith('guides/') ? `user_manual/${name}` : name;
    const imagePath = path.join(imageRoot, `${imageName}.png`);
    fs.mkdirSync(path.dirname(imagePath), { recursive: true });
    return imagePath;
  }

  async function prepare(options) {
    await page.setViewportSize({ width: options.width || 1280, height: options.height || 900 });
    if (process.env.DOCS_SCREENSHOT_APP_LOCALE) {
      // A completed Vue boot does not guarantee its asynchronous locale import
      // has finished. Never save English UI under a translated filename.
      // Server-rendered pages such as email previews have no app to wait for.
      if (await page.locator('.app-is-booted').count()) {
        await page.locator(`html[lang="${process.env.DOCS_SCREENSHOT_APP_LOCALE}"]`).waitFor({ state: 'attached', timeout: 20000 });
      }
    }
    await page.evaluate(showFlash => {
      let style = document.getElementById('manual-screenshot-styles');

      if (!style) {
        style = document.createElement('style');
        style.id = 'manual-screenshot-styles';
        document.head.appendChild(style);
      }
      style.textContent = `
        *, *::before, *::after {
          animation-delay: 0s !important;
          animation-duration: 0s !important;
          caret-color: transparent !important;
          scroll-behavior: auto !important;
          transition-delay: 0s !important;
          transition-duration: 0s !important;
        }
        ${showFlash ? '' : '.flash-root { display: none !important; }'}
      `;
    }, options.showFlash === true);
    await page.waitForTimeout(300);
    if (options.clearSelection) {
      await page.evaluate(() => {
        document.activeElement?.blur();
        window.getSelection()?.removeAllRanges();
      });
    }
  }

  async function scrollIntoView(options) {
    await page.evaluate(([scrollSelector, scrollBlock]) => {
      if (scrollSelector) {
        document.querySelector(scrollSelector)?.scrollIntoView({ block: scrollBlock || 'center' });
      } else {
        window.scrollTo(0, 0);
      }
    }, [options.scrollSelector, options.scrollBlock]);
    await page.waitForTimeout(200);
  }

  async function spotlightGeometry(spotlight, captureSelector, includeThreadGutters = false) {
    if (!spotlight) {
      return null;
    }

    const options = typeof spotlight === 'string' ? { selector: spotlight } : spotlight;
    const selectors = options.selectors || [options.selector].filter(Boolean);
    if (!selectors.length) {
      throw new Error('A spotlight selector or selectors list is required');
    }

    const rect = await page.evaluate(([selectors, rootSelector, includeThreadGutters]) => {
      const targets = selectors.map(selector => document.querySelector(selector));
      const root = rootSelector ? document.querySelector(rootSelector) : null;

      const missingIndex = targets.findIndex(target => !target);
      if (missingIndex !== -1) {
        return { error: `Spotlight target not found: ${selectors[missingIndex]}` };
      }
      if (rootSelector && !root) {
        return { error: `Screenshot root not found: ${rootSelector}` };
      }

      const targetRects = targets.map(target => target.getBoundingClientRect());
      const targetTop = Math.min(...targetRects.map(rect => rect.top));
      const targetBottom = Math.max(...targetRects.map(rect => rect.bottom));
      const threadGutterRects = includeThreadGutters
        ? targets.flatMap(target => {
          const gutter = target.closest('.topic-item__row')?.querySelector(':scope > .topic-item__gutter');
          const avatar = gutter?.querySelector('.user-avatar');

          if (!gutter || !avatar) {
            return [];
          }

          const avatarRect = avatar.getBoundingClientRect();
          return avatarRect.bottom > targetTop && avatarRect.top < targetBottom
            ? [gutter.getBoundingClientRect()]
            : [];
        })
        : [];
      const targetLeft = Math.min(...targetRects.map(rect => rect.left), ...threadGutterRects.map(rect => rect.left));
      const targetRight = Math.max(...targetRects.map(rect => rect.right));
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
    }, [selectors, captureSelector, includeThreadGutters]);

    if (rect.error) {
      throw new Error(rect.error);
    }
    return { options, rect };
  }

  function applySpotlight(outputPath, geometry) {
    if (!geometry) {
      return;
    }
    runRuby(spotlightScript, [outputPath, JSON.stringify({ ...geometry.rect, ...geometry.options })], 'Could not apply screenshot spotlight');
  }

  function applyCrop(outputPath, geometry, padding) {
    runRuby(cropScript, [outputPath, JSON.stringify({ ...geometry.rect, padding })], 'Could not crop screenshot');
  }

  // Compress last, after cropping and spotlighting have read the full-colour
  // capture.
  function applyCompression(outputPath) {
    runRuby(compressScript, [outputPath], 'Could not compress screenshot');
  }

  return {
    async capture(name, options = {}) {
      const outputPath = imagePath(name);
      // Full-page images keep the 757px page height the manual has always used.
      options = { height: 757, ...options };
      await prepare(options);
      await scrollIntoView(options);
      const geometry = await spotlightGeometry(options.spotlight, null);

      await page.screenshot({ path: outputPath, animations: 'disabled', caret: 'hide' });
      applySpotlight(outputPath, geometry);
      applyCompression(outputPath);
    },

    async captureElement(name, selector, options = {}) {
      const outputPath = imagePath(name);
      await prepare(options);
      await page.locator(selector).first().waitFor({ state: 'visible' });
      // Grow the window to fit the whole element. A capture that has to scroll
      // leaves sticky headers floating over the middle of the image.
      const bottom = await page.locator(selector).first().evaluate(element => Math.ceil(element.getBoundingClientRect().bottom + window.scrollY));
      const viewport = page.viewportSize();
      if (bottom > viewport.height) {
        await page.setViewportSize({ width: viewport.width, height: bottom });
      }
      await scrollIntoView({ ...options, scrollSelector: options.scrollSelector || selector });
      const geometry = await spotlightGeometry(options.spotlight, selector);

      await page.locator(selector).first().screenshot({ path: outputPath, animations: 'disabled', caret: 'hide' });
      applySpotlight(outputPath, geometry);
      applyCompression(outputPath);
    },

    async captureRegion(name, selectors, options = {}) {
      const outputPath = imagePath(name);
      await prepare(options);
      for (const selector of selectors) {
        await page.locator(selector).first().waitFor({ state: 'attached' });
      }
      if (options.scrollSelector) {
        await scrollIntoView(options);
      }
      const geometry = await spotlightGeometry({ selectors }, null, options.includeThreadGutters !== false);
      const spotlight = await spotlightGeometry(options.spotlight, null);
      await page.waitForTimeout(200);

      await page.screenshot({ path: outputPath, animations: 'disabled', caret: 'hide' });
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
      applyCompression(outputPath);
    }
  };
}
