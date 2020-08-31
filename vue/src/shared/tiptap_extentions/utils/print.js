/**
 * Utils: print
 * @author Leecason
 * @license MIT, https://github.com/Leecason/element-tiptap/blob/master/LICENSE
 * @see https://github.com/Leecason/element-tiptap/blob/master/src/utils/print.ts
 */
const IS_TEST = false

export function printHtml (dom) {
  let style = Array.from(document.querySelectorAll('style, link'))
    .reduce((str, style) => str + style.outerHTML, '')
  style = style.replace(new RegExp('<link href=".*.js" .*[ht]">', 'g'), '')
  style = style.replace(new RegExp('href="', 'g'), 'href="/')
  style = style.replace(new RegExp('fonts/', 'g'), '/fonts/')

  const content = style + `<section class="tiptap tiptap-editor quasar-tiptap">${dom.outerHTML}</section>`
  // console.log('html', content)

  if (IS_TEST) {
    // open a new window, for test
    let newWindow = window.open('print window', '_blank')
    newWindow.document.write(content)
    newWindow.document.close()
  } else {
    // iframe, for print
    const iframe = document.createElement('iframe')
    iframe.id = 'quasar-tiptap-iframe'
    iframe.setAttribute('style', 'position: absolute; width: 0; height: 0; top: -10px; left: -10px;')
    document.body.appendChild(iframe)

    const frameWindow = iframe.contentWindow
    const doc = iframe.contentDocument || (iframe.contentWindow && iframe.contentWindow.document)

    if (doc) {
      doc.open()
      doc.write(content)
      doc.close()
    }

    if (frameWindow) {
      iframe.onload = function () {
        try {
          setTimeout(() => {
            frameWindow.focus()
            try {
              if (!frameWindow.document.execCommand('print', false)) {
                frameWindow.print()
              }
            } catch (e) {
              frameWindow.print()
            }
            frameWindow.close()
          }, 10)
        } catch (err) {
          console.error(err)
        }

        setTimeout(function () {
          document.body.removeChild(iframe)
        }, 100)
      }
    }
  }
}
