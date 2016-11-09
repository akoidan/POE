const months_ago = 5;
$('.found-time-ago').each(function (i, el) {
    if (el.textContent.indexOf('month') < 0 || parseInt(el.textContent.substr(0, 1)) < months_ago) {
        $(el).parents('.item')[0].remove();
    }
});
