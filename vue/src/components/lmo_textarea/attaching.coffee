import { forEach } from 'lodash'
import FileUploader from '@/shared/services/file_uploader'
import {insertImage} from '@/components/lmo_textarea/image'
export default
  data: ->
    files: []
    imageFiles: []

  created: ->
    @files = @model.attachments.filter((a) -> a.signed_id).map((a) -> {blob: a, file: {name: a.filename}})

  watch:
    files: -> @updateFiles()
    imageFiles: -> @updateFiles()

  methods:
    resetFiles: ->
      @files = []
      @imageFiles = []

    updateFiles: ->
      @model.files = @files.filter((w) => w.blob).map (wrapper) => wrapper.blob.signed_id
      @model.imageFiles = @imageFiles.filter((w) => w.blob).map (wrapper) => wrapper.blob.signed_id
      @emitUploading()

    emitUploading: ->
      @$emit('is-uploading', !((@model.files || []).length == @files.length && (@model.imageFiles || []).length == @imageFiles.length))

    removeFile: (name) ->
      @files = @files.filter (wrapper) -> wrapper.file.name != name

    attachFile: ({file}) ->
      wrapper = {file: file, key: file.name+file.size, percentComplete: 0, blob: null}
      @files.push(wrapper)
      @emitUploading()
      uploader = new FileUploader onProgress: (e) ->
        wrapper.percentComplete = parseInt(e.loaded / e.total * 100)

      uploader.upload(file).then (blob) =>
        wrapper.blob = blob
        @updateFiles()
      ,
      (e) ->
        console.log "attachment failed to upload"

    attachImageFile: ({file, onProgress, onComplete, onFailure}) ->
      wrapper = {file: file, blob: null}
      @imageFiles.push(wrapper)
      @emitUploading()
      uploader = new FileUploader onProgress: onProgress
      uploader.upload(file).then((blob) =>
        wrapper.blob = blob
        onComplete(blob)
        @updateFiles()
      , onFailure)

    fileSelected: ->
      forEach @$refs.filesField.files, (file) => @attachFile(file: file)

    # collab editor only
    imageSelected: ->
      # console.log 'state', @editor.state.tr.selection.from
      Array.from(@$refs.imagesField.files || []).forEach (file) =>
        if (/image/i).test(file.type)
          insertImage(file, @editor.view, null, @attachImageFile)
        else
          attachFile({file})
