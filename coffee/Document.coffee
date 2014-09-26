class Document

  constructor: (props = {}) ->
    @id = props.id
    @url = props.url
    @name = props.name
    @mimeType = props.mimeType
    @encoding = props.encoding
    @createdAt = props.createdAt
    @updatedAt = props.updatedAt
    @setDefaults()

  setDefaults: ->
    @id ?= require('uuid').v4()
    @createdAt ?= new Date()
    @updatedAt ?= new Date()

module.exports = Document
