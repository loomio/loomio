/**
 * Utils: alignment
 */
import {
  findParentNode,
  isCellSelection,
  findCellClosestToPos,
  findChildrenByAttr,
  findChildrenByType,
} from 'prosemirror-utils'
import { nodeEqualsType } from 'tiptap-utils'

function dispatchTasks (tasks, textAlign, selectionIsCell, tr, dispatch, paragraph) {
  if (!tasks.length) {
    return false
  }

  let transformation = tr

  tasks.forEach(({ cell, node, pos }) => {
    if (cell) {
      const paragraphs = findChildrenByType(node, paragraph, false)
      if (paragraphs && paragraphs.length > 0) {
        const p = paragraphs[0]
        const attrs = {
          ...node.attrs,
          textAlign: textAlign
        }
        transformation = transformation.setNodeMarkup(pos, p.type, attrs, node.marks)
      }

      return
    }

    const attrs = {
      ...node.attrs,
      textAlign: selectionIsCell
        ? textAlign
        : null,
    }

    transformation = transformation.setNodeMarkup(pos, node.type, attrs, node.marks)
  })

  if (dispatch) {
    dispatch(transformation)
  }

  return true
}

export function setAlignment (type, attrs = {}) {
  return (state, dispatch) => {
    const {
      doc,
      selection,
    } = state

    if (!selection || !doc) {
      return false
    }

    const {
      paragraph,
      heading,
      blockquote,
      list_item: listItem,
      todo_item: todoItem,
      table_cell: tableCell,
      table_header: tableHeader,
    } = state.schema.nodes
    const { ranges } = selection
    let { tr } = state


    const selectionIsCell = isCellSelection(selection)
    const alignment = attrs.textAlign || null

    // If there is no text selected, or the text is within a single node
    if (selection.empty ||
      (ranges.length === 1 &&
      ranges[0].$from.parent.eq(ranges[0].$to.parent) &&
      !selectionIsCell)
    ) {
      const { depth, parent } = selection.$from
      const predicateTypes = depth > 1 && nodeEqualsType({ node: parent, types: paragraph })
        ? [blockquote, listItem, todoItem, paragraph]
        : parent.type
      const predicate = node => nodeEqualsType({ node, types: predicateTypes })


      const {
        pos,
        node: {
          type: nType,
          attrs: nAttrs,
          marks: nMarks,
        },
      } = findParentNode(predicate)(selection)

      tr = tr.setNodeMarkup(pos, nType, { ...nAttrs, textAlign: alignment }, nMarks)

      if (dispatch) { dispatch(tr) }

      return true
    }

    const tasks = []

    if (selectionIsCell) {
      const tableTypes = [tableHeader, tableCell]

      ranges.forEach(range => {
        const {
          $from: { parent: fromParent },
          $to: { parent: toParent },
        } = range

        if (!fromParent.eq(toParent) ||
          !range.$from.sameParent(range.$to) ||
          !nodeEqualsType({ node: fromParent, types: tableTypes }) ||
          !nodeEqualsType({ node: toParent, types: tableTypes })
        ) {
          return
        }

        if (fromParent.attrs.textAlign !== alignment) {
          tasks.push({
            node: fromParent,
            pos: range.$from.pos,
            cell: findCellClosestToPos(range.$from),
          })
        }

        const predicate = ({ textAlign }) => typeof textAlign !== 'undefined' && textAlign !== null

        findChildrenByAttr(fromParent, predicate, true)
          .forEach(({ node, pos }) => {
            if (!nodeEqualsType({ node, types: [paragraph, heading, blockquote, listItem] })) {
              return
            }

            tasks.push({
              node,
              pos: range.$from.pos + pos,
            })
          })
      })

      return dispatchTasks(tasks, alignment, true, tr, dispatch, paragraph)
    }

    doc.nodesBetween(selection.from, selection.to, (node, pos) => {
      if (!nodeEqualsType({ node, types: [paragraph, heading, blockquote, listItem] })) {
        return true
      }

      const textAlign = node.attrs.textAlign || null

      if (textAlign === alignment) { return true }

      tasks.push({ node, pos, })

      return nodeEqualsType({ node, types: [blockquote, listItem] })
    })

    return dispatchTasks(tasks, alignment, true, tr, dispatch, paragraph)
  }
}
