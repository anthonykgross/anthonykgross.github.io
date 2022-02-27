var uri = new URI();

$(document).ready(function () {
    // LOADER
    $('.page-loading').fadeOut(1000, function () {
        $(this).remove();
    });

    // jQuery smooth scrolling
    $('a.active-anchor').bind('click', function (event) {
        var anchor = $(this);
        var anchorId = anchor.attr('href').split("#")[1];
        animateAnchor(anchorId, event);
    });

    // POPUP FOR IMAGES
    $('.image-popup').magnificPopup({
        type: 'image',
        mainClass: 'mfp-with-zoom',
        zoom: {
            enabled: true,
            duration: 300,
            easing: 'ease-in-out',
            opener: function (openerElement) {
                return openerElement.is('img') ? openerElement : openerElement.find('img');
            }
        }
    });

    // CLIPABLE
    $('.clipable').each(function(i, elm) {
        var elm = $(elm);

        var a = $('<a/>')
            .addClass('cliper')
            .attr('data-clipboard-text', uri.origin()+uri.pathname()+'#'+elm.attr('id'))
            .attr('title', 'Copier le lien')
        ;
        elm.html(
            a.append(elm.html())
        );
    });

    var clipboard = new ClipboardJS('.cliper');
    clipboard.on('success', function() {
        new Noty({
            text: 'Lien copié !',
            theme: 'light',
            type: 'success',
            timeout: 3000
        }).show();
    });

    // CHECK HASH
    if (uri.hash().length > 0) {
        animateAnchor(uri.hash().substr(1));
    }
});

function animateAnchor(anchorId, event) {
    var elm = $("[id='"+anchorId+"']");

    if (elm.length >= 1) {
        changeUrl(elm.text(), uri.origin()+uri.pathname()+'#'+anchorId);
        $('html, body').stop().animate({
            scrollTop: parseInt(elm.offset().top)-100
        }, 1000);
        if(event) {
            event.preventDefault();
        }
    }
}

function changeUrl(title, url) {
    if (typeof (history.pushState) != "undefined") {
        var obj = { Title: title, Url: url };
        history.pushState(obj, obj.Title, obj.Url);
    } else {
        console.error("Browser does not support HTML5.");
    }
}