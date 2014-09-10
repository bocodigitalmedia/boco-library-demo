class Document
  constructor: (props = {}) ->
    @id = props.id
    @url = props.url
    @name = props.name
    @mimeType = props.mimeType
    @setDefaults()

  setDefaults: ->
    @id ?= require('uuid').v4()


module.exports = Document
