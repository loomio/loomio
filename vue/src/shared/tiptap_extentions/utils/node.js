/**
 * Utils: node
 * @author Micle, micle@oriovo.com
 */

function isNodeActive (state, name, value) {
  const { selection, doc } = state
  const { from, to } = selection

  let keepLooking = true
  let active = false

  doc.nodesBetween(from, to, (node) => {
    if (keepLooking && node.attrs[name] === value) {
      keepLooking = false
      active = true
    }
    return keepLooking
  })

  return active
}

export { isNodeActive }
