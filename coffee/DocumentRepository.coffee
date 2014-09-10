
class DocumentRepository
  constructor: (props = {}) ->
    @collection = props.collection
    @setDefaults()

  setDefaults: ->
    @collection ?= {}

  generateId: ->
    require('uuid').v4()

  find: (id, callback) ->
    unless @collection.hasOwnProperty id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    doc = @collection[id]
    return callback null, doc

  create: (doc, callback) ->
    doc.id ?= @generateId

    if @collection.hasOwnProperty doc.id
      error = Error()
      error.name = "PrimaryKeyViolation"
      error.message = "A document already exists with this id."
      error.payload = id: doc.id
      return callback error

    @collection[doc.id] = doc
    return callback null, doc

  update: (doc, callback) ->
    unless doc.id?
      error = Error()
      error.name = "InvalidDocument"
      error.message = "This document has no identity"
      error.payload = document: doc
      return callback error

    unless @collection.hasOwnProperty doc.id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Cannot update this document, not found."
      error.payload = id: doc.id
      return callback error

    @collection[doc.id] = doc
    return callback null, doc

  delete: (id, callback) ->
    unless @collection.hasOwnProperty(id)
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    doc = @collection[id]
    delete @collection[id]
    return callback null, doc
    
module.exports = DocumentRepository
