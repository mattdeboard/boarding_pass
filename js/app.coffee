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
        <button id=\"first\">
            First Class
        </button>
        <button id=\"business\">
            Business Class
        </button>
        <button id=\"coach\">
            Coach
        </button>
    </span>"

    unless $('span.cp-buttons').length
        $(buttons).insertAfter(detailHeadline)

    return null

port = chrome.runtime.connect({ name: 'nb-overlay' })

article_store = {}
article_store.indexedDB = {}
article_store.indexedDB.db = null
article_store.indexedDB.open = ->
    version = 1
    request = indexedDB.open "articles", version

    request.onupgradeneeded = (e) ->
        db = e.target.result
        e.target.transaction.onerror = article_store.indexedDB.onerror

        if db.objectStoreNames.contains "articles"
            db.deleteObjectStore "articles"

        store = db.createObjectStore "articles", {keyPath: "url"}

    request.onsuccess = (e) ->
        article_store.indexedDB.db = e.target.result
        article_store.indexedDB.getAllArticles()

    request.onerror = article_store.indexedDB.onerror
    null

article_store.indexedDB.open()

article_store.indexedDB.addArticle = (data) ->
    db = article_store.indexedDB.db
    trans = db.transaction ["articles"], "readwrite"
    store = trans.objectStore "articles"
    request = store.put data

    request.onsuccess = (e) ->
        article_store.indexedDB.getAllArticles()

article_store.indexedDB.getAllArticles = ->
    db = article_store.indexedDB.db
    trans = db.transaction ["articles"], "readwrite"
    store = trans.objectStore "articles"

    keyRange = IDBKeyRange.lowerBound 0
    cursorRequest = store.openCursor keyRange

    cursorRequest.onsuccess = (e) ->
        result = e.target.result
        if !!result == false
            return

        console.log result.value
        result.continue()

    cursorRequest.onerror = article_store.indexedDB.onerror
    return

$('div.NB-story-titles').on 'DOMSubtreeModified', (e) ->
    _.defer insertButtons

$('div.NB-story-titles').on 'click', 'span.cp-buttons button', (e) ->
    # When the user clicks one of the buttons, we either want to POST the
    # relevant data if it's never been seen before, or PUT it if it has been
    # seen. We use indexedDB to keep track of what we have seen before or not.
    target = $(e.target)
    parent = target.parent('span.cp-buttons')
    article =
        category:
            short_name: target.attr 'id'
        headline: parent.data('headline')
        url: parent.data('href').split("?")[0]

    db = article_store.indexedDB.db
    trans = db.transaction ["articles"], "readwrite"
    store = trans.objectStore "articles"
    request = store.get article.url

    request.onerror = (e) ->
        console.log e

    request.onsuccess = (e) ->
        # If this url already exists locally, compare the categories; if they're
        # different, send a PUT request. If they're the same, don't send a
        # request since there's no data change.
        reqUrl = 'http://api.celebrityplanecrash.com/v1/article/'
        reqType = 'POST'
        res = request.result
        if res?
            if res.category == article.category
                return
            reqType = 'PUT'
            reqUrl += "#{request.result.id}/"

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
            article_store.indexedDB.addArticle data
