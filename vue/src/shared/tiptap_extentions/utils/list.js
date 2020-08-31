/**
 * Utils: list
 */

export function isBulletListNode (node) {
  return node.type.name === 'bullet_list'
}

export function isOrderedListNode (node) {
  return node.type.name === 'order_list'
}

export function isTodoListNode (node) {
  return node.type.name === 'todo_list'
}

export function isListNode (node) {
  return isBulletListNode(node) ||
    isOrderedListNode(node) ||
    isTodoListNode(node)
}
