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

articleDB = {}
db.open(
    server: "articles"
    version: 1
    schema:
        articles:
            key: { keyPath: 'id' }
            indexes:
                url: { unique: true })
    .done (s) ->
        articleDB = s

$('div.NB-story-titles').on 'DOMSubtreeModified', (e) ->
    _.defer insertButtons

$('div.NB-story-titles').on 'click', 'span.cp-buttons button', (e) ->
    # When the user clicks one of the buttons, we either want to POST the
    # relevant data if it's never been seen before, or PUT it if it has been
    # seen. We use indexedDB to keep track of what we have seen before or not.
    target = $(e.target)
    parent = target.parent('span.cp-buttons')
    article =
        category: target.attr 'id'
        headline: parent.data('headline')
        url: parent.data('href').split("?")[0]

    query = articleDB.articles.query().only('url', article.url).execute()

    $.when(query).done (res) ->
        # If this url already exists locally, compare the categories; if they're
        # different, send a PUT request. If they're the same, don't send a
        # request since there's no data change.
        reqUrl = 'http://api.celebrityplanecrash.com/v1/article/'
        reqType = 'POST'
        debugger
        if res.length
            if res.category == article.category
                return
            reqType = 'PUT'
            reqUrl += "#{res.id}/"

        req = $.ajax
            url: reqUrl
            type: reqType
            timeout: 4000
            headers:
                Accept: 'application/json'
            contentType: 'application/json'
            dataType: 'json'
            data: JSON.stringify(article)

        $.when(req).done (data) ->
            articleDB.add data
