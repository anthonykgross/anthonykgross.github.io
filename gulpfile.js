let gulp = require('gulp'),
    uglify = require('gulp-uglify'),
    concat = require('gulp-concat'),
    uglifycss = require('gulp-uglifycss'),
    replace = require('gulp-replace')
;

exports.default = function() {
    gulp.src([
        './node_modules/@highlightjs/cdn-assets/highlight.min.js',
        './node_modules/@highlightjs/cdn-assets/languages/dockerfile.min.js',
        './node_modules/jquery/dist/jquery.min.js',
        './node_modules/clipboard/dist/clipboard.min.js',
        './node_modules/magnific-popup/dist/jquery.magnific-popup.min.js',
        './node_modules/noty/lib/noty.min.js',
        './node_modules/urijs/src/URI.min.js',
    ])
    .pipe(concat('assets/dist/libs.js'))
    .pipe(uglify())
    .pipe(gulp.dest('./'));

    gulp.src(['./node_modules/font-awesome/fonts/**/*'])
        .pipe(gulp.dest('assets/dist'));

    return gulp.src([
        './node_modules/font-awesome/css/font-awesome.min.css',
        './node_modules/magnific-popup/dist/magnific-popup.css',
        './node_modules/noty/lib/noty.css',
        './node_modules/noty/lib/themes/light.css',
        './node_modules/@highlightjs/cdn-assets/styles/atom-one-dark-reasonable.min.css',
    ])
    .pipe(concat('assets/dist/libs.css'))
    .pipe(replace('../fonts/fontawesome-', 'fontawesome-'))
    .pipe(uglifycss())
    .pipe(gulp.dest('./'));
}
