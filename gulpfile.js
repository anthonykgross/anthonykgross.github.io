let gulp = require('gulp'),
    uglify = require('gulp-uglify'),
    concat = require('gulp-concat'),
    uglifycss = require('gulp-uglifycss'),
    replace = require('gulp-replace')
;

exports.default = function() {
    gulp.src([
        './node_modules/prismjs/components/prism-core.js',
        './node_modules/prismjs/components/prism-markup.js',
        './node_modules/prismjs/components/prism-css.js',
        './node_modules/prismjs/components/prism-clike.js',
        './node_modules/prismjs/components/prism-javascript.js',
        './node_modules/prismjs/components/prism-bash.js',
        './node_modules/prismjs/components/prism-php.js',
        './node_modules/prismjs/components/prism-php-extras.js',
        './node_modules/prismjs/components/prism-docker.js',
        './node_modules/prismjs/components/prism-yaml.js',
        './node_modules/prismjs/components/prism-sql.js',
        './node_modules/prismjs/components/prism-rest.js',
        './node_modules/prismjs/components/prism-python.js',
        './node_modules/prismjs/components/prism-nginx.js',
        './node_modules/prismjs/components/prism-java.js',
        './node_modules/prismjs/components/prism-git.js',
        './node_modules/prismjs/components/prism-ini.js',
        './node_modules/prismjs/plugins/file-highlight/prism-file-highlight.js',

        './node_modules/jquery/dist/jquery.min.js',
        './node_modules/clipboard/dist/clipboard.min.js',
        './node_modules/jticker/js/jquery.jticker.js',
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
        './node_modules/prismjs/themes/prism-okaidia.css',
    ])
    .pipe(concat('assets/dist/libs.css'))
    .pipe(replace('../fonts/fontawesome-', 'fontawesome-'))
    .pipe(uglifycss())
    .pipe(gulp.dest('./'));
}
