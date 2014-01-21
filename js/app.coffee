insertButtons = ->
    detailHeadline = $("div.NB-story-detail a.NB-feed-story-title")
    unless detailHeadline.length
        return
    hl = detailHeadline.text().replace("'", "").replace("\"", "")
    href = detailHeadline.attr('href')
    buttons = "<span class=\"cp-buttons\"
          data-headline=\"#{hl}\"
          data-href=\"#{href}\">
        <button id=\"cockpit\">
            Cockpit
        </button>
        <button id=\"business\">
            Business
        </button>
        <button id=\"economy\">
            Economy
        </button>
    </span>"

    unless $('span.cp-buttons').length
        $(buttons).insertAfter(detailHeadline)

    return null

port = chrome.runtime.connect({ name: 'nb-overlay' })

$('div.NB-story-titles').on 'DOMSubtreeModified', (e) ->
    _.defer insertButtons

$('div.NB-story-titles').on 'click', 'span.cp-buttons button', (e) ->
    target = $(e.target)
    parent = target.parent('span.cp-buttons')
    req = $.ajax
        url: 'https://api.celebrityplanecrash.com/v1/story/'
        type: 'POST'
        timeout: 4000
        dataType: 'json'
        data:
            seatType: target.attr 'id'
            headline: parent.data('headline')
            storyLink: parent.data('href')
