gulp        = require 'gulp'
coffeelint  = require 'gulp-coffeelint'
coffee      = require 'gulp-coffee'
del         = require 'del'
data        = require 'gulp-data'
watch       = require 'gulp-watch'
beautify    = require 'js-beautify'

reader      = require './'

  
gulp.task 'coffeelint', ->
  gulp.src ['./*.coffee', './src/*.coffee']
    .pipe coffeelint './coffeelint.json'
    .pipe coffeelint.reporter()

gulp.task 'coffee', ['coffeelint'], ->
  gulp.src ['./src/*.coffee']
    .pipe coffee()
    .pipe gulp.dest './lib'

gulp.task 'default', ['coffee']

gulp.task 'watch', ->
  gulp.watch './**/*.coffee', ['default']
 
gulp.task 'clean', (cb) ->
  del ['./lib/*.js', './**/*~'], force: true, cb

gulp.task 'test', [
  'default'
  '_test-file'
  '_test-file-chunk'
  '_test-buffer'
  '_test-buffer-chunk'
  ]

gulp.task '_test-file', ['default'], ->
  gulp.src ["sample.riff"], read: off
    .pipe data (file) ->
      reader file.path, 'NIKS'
        .read (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"

gulp.task '_test-file-chunk', ['default'], ->
  gulp.src ["sample.riff"], read: off
    .pipe data (file) ->
      reader file.path, 'NIKS'
        .read (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"
        , ['NISI', 'PLID']


gulp.task '_test-buffer', ['default'], ->
  gulp.src ["sample.riff"], read: on
    .pipe data (file) ->
      reader file.contents, 'NIKS'
        .read (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"

gulp.task '_test-buffer-chunk', ['default'], ->
  gulp.src ["sample.riff"], read: on
    .pipe data (file) ->
      reader file.contents, 'NIKS'
        .read (id, chunk) ->
          console.info "## chunk Id:#{id}  size:#{chunk.length}"
        , ['NISI', 'PLID']
