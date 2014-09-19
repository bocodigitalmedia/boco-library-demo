# boco-library-demo

Simple library demo.

##
## Installation

Clone the repository locally:

```
git clone https://github.com/bocodigitalmedia/boco-library-demo
```

Install the package and its dependencies:

```
cd boco-library-demo
npm install
```

Make sure rabbitmq is running

```
rabbitmq-server
```

Start the demo server on port 3000:

```
LISTEN=3000 npm start
```

Or listen on a socket:

```
LISTEN=./server.sock npm start
```

## Documents JSON

You can modify the documents available by changing `documents.json` in the `data` directory.

## Administration

The library can be managed using a simple REST interface at http://localhost:3000/documents

### List documents

```
GET /documents
{
  "xxx-xxx-xxx-doc1": {
    "id": "xxx-xxx-xxx-doc1",
    "url": "http://example.com/document1.pdf"
  },
  "xxx-xxx-xxx-doc2": {
    "id": "xxx-xxx-xxx-doc2",
    "url": "http://example.com/document2.pdf"
  }
}
```

### Create a document

```
Content-Type: application/json
POST /documents
{ "url": "http://example.com/document1.pdf",
  "name": "document 1" }
```

### Update a document

```
Content-Type: application/json
POST /documents/:id
{ "url: "http://example.com/document1.pdf",
  "name": "Renamed this document" }
```

### Delete a document

```
DELETE /documents/:id
```


## Events

Events are dispatched using `socket.io`.

### library.document.deleted

A document was deleted from the library. Payload contains a `document` property, reflecting the document that was deleted.


### library.document.created

A document was added to the library. Payload contains a `document` property, reflecting the document that was created.

### library.document.updated

A document within the library was updated. Payload contains a `document` property, reflecting the document that was updated.


## Live view

The live view via websockets can be accessed by pointing a browser to http://localhost:3000/

As you add, update, and remove documents, the view will change.


## File Manager

Browse to `/files` to upload your own files to be used by the documents manager.
You may then set the url as follows: `http://[servername]/files/[filename]`
