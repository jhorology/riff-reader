## riff-reader

RIFF (Resource Interchange File Format) file reader.

see https://msdn.microsoft.com/en-us/library/windows/desktop/dd798636(v=vs.85).aspx

## Installation
```
  npm install riff-reader --save
```

## Usage

```javascript
reader = require('riff-reader');

reader('.../hogehoge.riff', 'HOGE')
    .read(function(chunkId, data) {
        // do something with id and data buffer
    },['HOGE','FUGA']);


// you can also use buffer.
var buffer = fs.readFileSync('.../hogehoge.riff');

reader(buffer, 'HOGE')
    .read(function(chunkId, data) {
        // do something with id and data buffer
    },['HOGE','FUGA']);
```

## API

### reader(file, formType)
 create new reader instance.

#### file
Type: `String` or instance of `Buffer`

The file path or buffer of file content.

#### formType
Type: `String`

The form type of the RIFF content.

### reader.read(callback, [subscribeIds])
read file synchronously.

#### callback
Type: `function(id, data)`

##### id
Type: `String`

The chunk ID.

##### data
Type: instance of `Buffer`

The buffer of chunk data content. id and size are not contained.

#### subscribeIds
Type: array of `String`, Optional, Default: all chunks.

The array of chunk id to read for.

## TODO
- asynchronous read operation
