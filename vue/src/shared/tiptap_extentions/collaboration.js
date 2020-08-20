import { Extension } from 'tiptap'
import { Step } from 'prosemirror-transform'
import { Decoration, DecorationSet } from "prosemirror-view"
import {
  collab,
  sendableSteps,
  getVersion,
  receiveTransaction,
} from 'prosemirror-collab'

import colors from 'vuetify/lib/util/colors'

import AppConfig      from '@/shared/services/app_config'
import {map} from 'lodash'

export default class Collaboration extends Extension {

  get name() {
    return 'collaboration'
  }

  init() {
    this.editor.on('init', ({ state }) => {
      this.options.me.cursor = state.selection.anchor
      this.options.me.focused = state.selection.focused
      this.options.socket.emit('cursorchange', this.options.me)
    })

    this.getSendableSteps = this.debounce(({state, transaction}) => {
      const sendable = sendableSteps(state)

      let colorsList = map(colors, (value, key) => value.lighten3 )
      this.options.me.cursor = state.selection.anchor
      this.options.me.focused = state.selection.focused
      this.options.me.displayname = this.options.user.name
      this.options.me.displaycolor = colorsList[(this.options.user.id % colorsList.length)]


      if (sendable) {
        this.options.onSendable({
          socket: this.options.socket,
          editor: this.editor,
          sendable: {
            version: sendable.version,
            steps: sendable.steps.map(step => step.toJSON()),
            clientID: sendable.clientID,
            participant: this.options.me
          },
        })
      } else {
        // only send on position changes
        if (transaction.updated > 0) {
          this.options.socket.emit('cursorchange', this.options.me)
        }
      }
    }, this.options.debounce)

    this.updateLocalCursors = ({state, transaction}) => {
      const sendable = sendableSteps(state)
      if (sendable) {
        for (var participantID in this.participants) {
          var cursor = this.participants[participantID].cursor
          if (cursor != undefined &&
              sendable.steps[0].slice != undefined &&
              cursor >= sendable.steps[0].from
          ) {
            var gap = sendable.steps[0].from-sendable.steps[0].to
            this.participants[participantID].cursor = cursor+gap+sendable.steps[0].slice.content.size
          }
        }
        this.options.updateCursors({participants: this.participants})
      }
    }

    this.editor.on('transaction', ({ state, transaction }) => {
      this.updateLocalCursors({state, transaction})
      this.getSendableSteps({state, transaction})
    })
  }

  get defaultOptions() {
    return {
      version: 0,
      me: {displayname: ''},
      clientID: Math.floor(Math.random() * 0xFFFFFFFF),
      debounce: 250,
      socket: null,
      onSendable: ({socket, sendable}) => {
        socket.emit('update', sendable)
      },
      update: ({ steps, version }) => {
        // receives steps from the server
        const { state, view, schema } = this.editor

        if (getVersion(state) > version) {
          return
        }

        view.dispatch(receiveTransaction(
          state,
          steps.map(item => Step.fromJSON(schema, item.step)),
          steps.map(item => item.clientID),
        ))
      },

      updateCursors: ({ participants }) => {
        const { state, view, schema } = this.editor
        this.participants = participants

        //Set the decorations in the editor

        var clientID = this.options.clientID
        let props = {
          decorations(state) {
            var decos = []
            if (participants != undefined) {

              for (const [id, dec] of Object.entries(participants)){
                if (dec.cursor == undefined) { continue; }
                var cursorclass = 'cursor'
                var displayname = dec.displayname || dec.clientID
                var displaycolor = 'style="background-color:'+dec.displaycolor+'; border-top-color:'+dec.displaycolor+'"'

                const dom = document.createElement('div')
                if (dec.focused==false) {
                  cursorclass += ' inactive'
                }

                if (dec.clientID == clientID){
                  cursorclass += ' me'
                }

                dom.innerHTML = '<span class="'+cursorclass+'" '+displaycolor+'>'+displayname+'</span>'
                dom.style.display = 'inline'
                dom.class = 'tooltip'
                decos.push(Decoration.widget(dec.cursor, dom))
              }
            }
            return DecorationSet.create(state.doc, decos);
          }
        }
        view.setProps(props)
      }
    }
  }

  get plugins() {
    return [
      collab({
        version: this.options.version,
        clientID: this.options.clientID,
      }),
    ]
  }

  debounce(fn, delay) {
    let timeout
    return function (...args) {
      if (timeout) {
        clearTimeout(timeout)
      }
      timeout = setTimeout(() => {
        fn(...args)
        timeout = null
      }, delay)
    }
  }

}
