class DocumentRepository

  constructor: (props = {}) ->
    @collection = props.collection
    @index = props.index
    @setDefaults()

  setDefaults: ->
    @collection ?= []
    @index ?= {}

  generateId: ->
    require('uuid').v4()

  list: ->
    @collection

  buildIndex: ->
    @index = {}
    @index[doc.id] = pos for doc,pos in @collection

  find: (id, callback) ->
    unless @index.hasOwnProperty id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    pos = @index[id]
    doc = @collection[pos]
    return callback null, doc

  create: (doc, callback) ->
    doc.id ?= @generateId()

    if @index.hasOwnProperty doc.id
      error = Error()
      error.name = "PrimaryKeyViolation"
      error.message = "A document already exists with this id."
      error.payload = id: doc.id
      return callback error

    @collection.push doc
    @index[doc.id] = @collection.length - 1
    return callback null, doc

  update: (doc, callback) ->
    doc.updatedAt = new Date()

    unless doc.id?
      error = Error()
      error.name = "InvalidDocument"
      error.message = "This document has no identity"
      error.payload = document: doc
      return callback error

    unless @index.hasOwnProperty doc.id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Cannot update this document, not found."
      error.payload = id: doc.id
      return callback error

    pos = @index[doc.id]
    @collection[pos] = doc
    return callback null, doc

  delete: (id, callback) ->
    unless @index.hasOwnProperty id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    pos = @index[id]
    doc = @collection[pos]
    @collection.splice pos, 1
    @buildIndex()
    return callback null, doc

module.exports = DocumentRepository
