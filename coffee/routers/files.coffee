When = require 'when'
Path = require 'path'
Express = require 'express'
BusBoy = require 'connect-busboy'
FileSystem = require 'fs'

filesRouter = (config = {}) ->
  uploadsFolderPath = config.uploadsFolderPath
  constructDocument = config.constructDocument
  repository = config.documentRepository
  publishEvent = config.publishEvent

  busboy = BusBoy()
  router = Express()

  uploadFile = (request, response) ->
    baseUrl = request.baseUrl
    fields = {}
    writeFilePromises = []

    writeFile = (readableStream, fileName, encoding) ->
      uploadPath = Path.join uploadsFolderPath, fileName
      writeStream = FileSystem.createWriteStream uploadPath, encoding: encoding

      readableStream.pipe writeStream
      When.promise (resolve, reject) ->
        writeStream.on 'error', (error) -> reject error
        writeStream.on 'close', -> resolve()

    onFile = (fieldName, stream, fileName, encoding, mimeType) ->
      writeFilePromise = writeFile stream, fileName, encoding
      writeFilePromises.push writeFilePromise
      fields[fieldName] =
        fileName: fileName
        encoding: encoding
        mimeType: mimeType

    onField = (fieldName, value) ->
      fields[fieldName] = value

    onFinish = ->
      allFilesWritten = When.all writeFilePromises

      When(allFilesWritten)
        .then(processFields)
        .catch(handleError)
        .done()

    isPresent = (value) ->
      return false unless value?
      return value isnt ""

    validateFields = ->
      errors = []

      unless isPresent fields.file
        errors.push "File must be present"

      unless isPresent fields.name
        errors.push "Name must be present"

      message = errors.join ". "
      throw Error(message) unless errors.length is 0

    constructFileUrl = (fileName) ->
      host = request.get "host"
      baseUrl = request.baseUrl
      "#{host}#{baseUrl}/#{fileName}"

    processFields = ->
      validateFields()

      params = {}
      params.name = fields.name
      params.url = constructFileUrl fields.file.fileName

      params.mimeType =
        if isPresent(fields.mimeType) then fields.mimeType
        else fields.file.mimeType

      params.encoding =
        if isPresent(fields.encoding) then fields.encoding
        else fields.file.encoding

      document = constructDocument params

      repository.create document, (error, document) ->
        throw error if error?
        publishEvent "library.document.created", document: document
        response.redirect request.baseUrl

    handleError = (error) ->
      response.status(500).send error.message

    request.busboy.on 'file', onFile
    request.busboy.on 'field', onField
    request.busboy.on 'finish', onFinish
    request.pipe request.busboy

  showIndex = (request, response) ->
    baseUrl = request.baseUrl

    FileSystem.readdir uploadsFolderPath, (error, files) ->
      throw error if error?
      response.status 200
      response.write "<!doctype html>"
      response.write "<html>"
      response.write "<head>"
      response.write "<title>Files</title>"
      response.write """
      <style type="text/css">
      form li {
        list-style-type: none;
      }
      form label {
        display: block;
      }
      </style>
      """
      response.write "</head>"
      response.write "<body>"
      response.write "<h1>Files</h1>"
      response.write "<ul>"
      response.write "<li><a href=\"#{baseUrl}/#{path}\">#{path}</a></li>" for path in files
      response.write "</ul>"
      response.write "<form action=\"#{baseUrl}\" method=\"post\" enctype=\"multipart/form-data\">"
      response.write "<ul>"
      response.write '<li><label for="file">File</label><input type="file" name="file" /></li>'
      response.write '<li><label for="mimeType">MIME Type</label><input type="text" name="mimeType" /></li>'
      response.write '<li><label for="encoding">Encoding</label><input type="text" name="encoding" /></li>'
      response.write '<li><label for="name">Name</label><input type="text" name="name" /></li>'
      response.write '<li><input type="submit" /></li>'
      response.write "</ul>"
      response.write '</form>'
      response.write "</body>"
      response.write "</html>"
      response.end()

  getFile = (request, response) ->
    fileName = request.params.fileName
    path = Path.join uploadsFolderPath, fileName

    FileSystem.exists path, (isPresent) ->
      return response.status(404).send "Not Found" unless isPresent
      return response.sendFile path

  router.post "/", busboy, uploadFile
  router.get "/", showIndex
  router.get "/:fileName", getFile

  return router

module.exports = filesRouter
