findNewsBlurTab = (cb) ->
    queryInfo = {url: "*://*.newsblur.com/*"}
    chrome.tabs.query queryInfo, (tabs) ->
        cb t for t in tabs
    undefined

chrome.runtime.onInstalled.addListener (details) ->
    findNewsBlurTab (tab) ->
        chrome.tabs.executeScript tab.id, {file: "main.js"}

chrome.runtime.onConnect.addListener (port) ->
    return unless port.name is 'nb-overlay'

    port.onMessage.addListener (msg) ->
        console.log msg.data

    port.postMessage
        type: 'foo'
        data: 'bar'
