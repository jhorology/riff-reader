# RIFF reader
#
# @ref https://msdn.microsoft.com/en-us/library/windows/desktop/dd798636(v=vs.85).aspx

assert = require 'assert'
fs     = require 'fs'
_      = require 'underscore'

# function(file, formType)
#
# - file     String filepath or content buffer
# - formtype 4 characters id
module.exports = (file, formType) ->
  new RIFFReader file, formType

class RIFFReader
  # new RIFFReader(file, formType)
  #
  # - file     String filepath or content buffer
  # - formType 4 characters id
  constructor: (file, formType) ->
    fileSize = if _.isString file
      @filepath = file
      stat = fs.statSync file
      stat.size
    else
      @buf = file
      @buf.length
    @pos = 0
    header = @_read 12
    magic = header.toString 'utf8', 0, 4
    assert.ok (magic is 'RIFF'), "Invalid file. magic:#{magic}"
    @fileSize = Math.min (header.readUInt32LE 4) + 8, fileSize
    @formType = header.toString 'ascii', 8, 12
    assert.ok (@formType is formType), "Invalid file. form type:#{@formType}"

  # readSync(callback, [subscribeIds])
  #
  # - callback     function(chunkId, data)
  # - subscribeIds array of chunk id. *optional
  readSync: (callback, subscribeIds) ->
    # RIFF size of some files has wrong (+1) value
    remainSize = @fileSize - @pos
    while remainSize >= 4
      @_readChunk callback, subscribeIds
      remainSize = @fileSize - @pos
    @

  _readChunk: (callback, subscribeIds) ->
    header = @_read 8
    id = header.toString 'ascii', 0, 4
    size = header.readUInt32LE 4
    if subscribeIds and not (id in subscribeIds)
      @_skip size
    else
      data = @_read size
      callback.call @, id, data
    # skip padding byte for 16bit boundary
    @_skip 1 if size & 0x01
    @

  _skip: (len) ->
    @pos += len
    @

  _read: (len) ->
    if @filepath
      @_readFile len
    else
      @_readBuffer len

  _readFile: (len) ->
    ret = Buffer.alloc len
    fd = fs.openSync @filepath, 'r'
    bytesRead = fs.readSync fd, ret, 0, len, @pos
    fs.closeSync fd
    assert.ok  (bytesRead is len), "File read error. bytesRead:#{bytesRead} expected bytes:#{len}"
    @pos += len
    ret

  _readBuffer: (len) ->
    ret = @buf.slice @pos, @pos + len
    @pos += len
    ret
