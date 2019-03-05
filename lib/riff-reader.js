(function() {
  // RIFF reader

  // @ref https://msdn.microsoft.com/en-us/library/windows/desktop/dd798636(v=vs.85).aspx
  var RIFFReader, _, assert, fs,
    indexOf = [].indexOf;

  assert = require('assert');

  fs = require('fs');

  _ = require('underscore');

  // function(file, formType)

  // - file     String filepath or content buffer
  // - formtype 4 characters id
  module.exports = function(file, formType) {
    return new RIFFReader(file, formType);
  };

  RIFFReader = class RIFFReader {
    // new RIFFReader(file, formType)

    // - file     String filepath or content buffer
    // - formType 4 characters id
    constructor(file, formType) {
      var header, magic;
      if (_.isString(file)) {
        this.filepath = file;
      } else {
        this.buf = file;
      }
      this.pos = 0;
      header = this._read(12);
      magic = header.toString('utf8', 0, 4);
      assert.ok(magic === 'RIFF', `Invalid file. magic:${magic}`);
      this.fileSize = (header.readUInt32LE(4)) + 8;
      this.formType = header.toString('ascii', 8, 12);
      assert.ok(this.formType === formType, `Invalid file. form type:${this.formType}`);
    }

    // readSync(callback, [subscribeIds])

    // - callback     function(chunkId, data)
    // - subscribeIds array of chunk id. *optional
    readSync(callback, subscribeIds) {
      var remainSize;
      // RIFF size of some files has wrong (+1) value
      remainSize = this.fileSize - this.pos;
      while (remainSize >= 4) {
        this._readChunk(callback, subscribeIds);
        remainSize = this.fileSize - this.pos;
      }
      return this;
    }

    _readChunk(callback, subscribeIds) {
      var data, header, id, size;
      header = this._read(8);
      id = header.toString('ascii', 0, 4);
      size = header.readUInt32LE(4);
      if (subscribeIds && !(indexOf.call(subscribeIds, id) >= 0)) {
        this._skip(size);
      } else {
        data = this._read(size);
        callback.call(this, id, data);
      }
      if (size & 0x01) {
        // skip padding byte for 16bit boundary
        this._skip(1);
      }
      return this;
    }

    _skip(len) {
      this.pos += len;
      return this;
    }

    _read(len) {
      if (this.filepath) {
        return this._readFile(len);
      } else {
        return this._readBuffer(len);
      }
    }

    _readFile(len) {
      var bytesRead, fd, ret;
      ret = new Buffer(len);
      fd = fs.openSync(this.filepath, 'r');
      bytesRead = fs.readSync(fd, ret, 0, len, this.pos);
      fs.closeSync(fd);
      assert.ok(bytesRead === len, `File read error. bytesRead:${bytesRead} expected bytes:${len}`);
      this.pos += len;
      return ret;
    }

    _readBuffer(len) {
      var ret;
      ret = this.buf.slice(this.pos, this.pos + len);
      this.pos += len;
      return ret;
    }

  };

}).call(this);
