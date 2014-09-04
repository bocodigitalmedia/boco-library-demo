# boco-library-demo

Simple library demo.

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

Run the demo server, using the specified `PORT`:

```
PORT=3000 npm run-script demo
```

## Documents JSON

You can modify the documents available by changing `documents.json` in the root directory.

## Administration

The library can be managed using a simple REST interface at http://localhost:3000/documents

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

## Live view

The live view via websockets can be accessed by pointing a browser to http://localhost:3000/

As you add, update, and remove documents, the view will change.
