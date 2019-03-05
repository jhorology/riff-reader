gulp        = require 'gulp'
coffeelint  = require 'gulp-coffeelint'
coffee      = require 'gulp-coffee'
del         = require 'del'
data        = require 'gulp-data'
beautify    = require 'js-beautify'


gulp.task 'coffeelint', ->
  gulp.src ['./*.coffee', './src/*.coffee']
    .pipe coffeelint './coffeelint.json'
    .pipe coffeelint.reporter()

_coffee = ->
  gulp.src ['./src/*.coffee']
    .pipe coffee()
    .pipe gulp.dest './lib'
    
gulp.task 'coffee', gulp.series 'coffeelint', _coffee

gulp.task 'default', gulp.series 'coffeelint', _coffee

gulp.task 'watch', ->
  gulp.watch './**/*.coffee', gulp.task 'coffee'
 
gulp.task 'clean', (cb) ->
  del ['./lib/*.js', './**/*~'], force: true, cb

gulp.task '_test-file', ->
  reader = require './'
  gulp.src ['sample.riff'], read: off
    .pipe data (file) ->
      reader file.path, 'NIKS'
        .readSync (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"

gulp.task '_test-file-chunk', ->
  reader = require './'
  gulp.src ['sample.riff'], read: off
    .pipe data (file) ->
      reader file.path, 'NIKS'
        .readSync (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"
        , ['NISI', 'PLID']


gulp.task '_test-buffer', ->
  reader = require './'
  gulp.src ['sample.riff'], read: on
    .pipe data (file) ->
      reader file.contents, 'NIKS'
        .readSync (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"

gulp.task '_test-buffer-chunk', ->
  reader = require './'
  gulp.src ['sample.riff'], read: on
    .pipe data (file) ->
      reader file.contents, 'NIKS'
        .readSync (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"
        , ['NISI', 'PLID']

gulp.task 'test', gulp.series 'coffee', gulp.parallel(
  '_test-file',
  '_test-file-chunk',
  '_test-buffer',
  '_test-buffer-chunk'
)
