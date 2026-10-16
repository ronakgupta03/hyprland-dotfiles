pragma Singleton

// Synced lyrics for the track that is playing, modelled on Nisfere's
// LyricsService. Lookup order:
//   1. LRCLIB exact   title + artist (+ duration)
//   2. LRCLIB search  best synced result, preferring a matching duration
//   3. NetEase        as Nisfere does, for what LRCLIB lacks
// Titles are stripped of "(Official Video)"-style tags first, since browser
// players pass the video title through. Results - misses included - are
// cached for the session, so pausing and resuming never refetches, and a
// reply for a track that is no longer playing is ignored.
//
// Keep `pragma Singleton` on the first line: below a long comment Quickshell
// silently loads the file as a plain type.
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property real offset: 0            // seconds; positive shows lines later
    property var lines: []             // [{time, text}], sorted
    property bool loading: false
    property string source: ""         // lrclib | lrclib search | netease
    property real position: 0
    property var cache: ({})
    property int generation: 0

    readonly property bool hasLyrics: lines.length > 0
    readonly property var player: Array.from(Mpris.players.values).find(p => p.isPlaying) || null
    readonly property bool playing: player !== null
    readonly property string artist: player ? (player.trackArtist || "").replace(/ - Topic$/, "") : ""
    readonly property string title: player ? (player.trackTitle || "") : ""
    readonly property real length: {
        if (!player || !player.lengthSupported || player.length <= 0)
            return 0
        return player.length > 100000 ? player.length / 1e6 : player.length
    }
    readonly property string trackKey: artist && title ? artist + "\n" + title : ""

    readonly property int currentIndex: {
        const target = position - offset
        let lo = 0, hi = lines.length
        while (lo < hi) {
            const mid = (lo + hi) >> 1
            if (lines[mid].time <= target)
                lo = mid + 1
            else
                hi = mid
        }
        return lo - 1
    }

    // MPRIS position is not pushed; ask for it while something plays.
    Timer {
        interval: 200
        repeat: true
        running: root.playing
        triggeredOnStart: true
        onTriggered: {
            root.player.positionChanged()
            root.position = root.player.position
        }
    }

    onTrackKeyChanged: debounce.restart()

    Timer {
        id: debounce
        interval: 400
        onTriggered: root.load()
    }

    function load() {
        const key = trackKey
        generation++
        lines = []
        source = ""
        if (!key) {
            loading = false
            return
        }
        if (cache[key] !== undefined) {
            lines = cache[key].lines
            source = cache[key].source
            loading = false
            return
        }

        loading = true
        const gen = generation
        const t = cleanTitle(title), a = artist, len = length
        const done = (parsed, src) => {
            if (parsed.length > 0)
                root.cache[key] = { lines: parsed, source: src }
            if (gen !== root.generation)
                return
            root.lines = parsed
            root.source = parsed.length ? src : ""
            root.loading = false
        }

        const art = primaryArtist(a) || a
        lrclibGet(t, art, len, p1 => {
            if (p1.length) {
                done(p1, "lrclib")
            } else {
                lrclibSearch(t, art, len, p2 => {
                    if (p2.length) {
                        done(p2, "lrclib search")
                    } else if (art !== a) {
                        lrclibSearch(t, a, len, p3 => p3.length ? done(p3, "lrclib search") : netease(t, art, p4 => done(p4, "netease")))
                    } else {
                        netease(t, art, p4 => done(p4, "netease"))
                    }
                })
            }
        })
    }

    function reload() {
        delete cache[trackKey]
        load()
    }

    function cleanTitle(t) {
        return t.replace(/\s*[\(\[][^\)\]]*(official|video|audio|lyric|visuali[sz]er|remaster|live|hd|4k)[^\)\]]*[\)\]]/gi, "")
                .replace(/\s*[-–]\s*from\s+["'][^"']+["']/gi, "")
                .replace(/\s*[-–]\s*from\s+.*$/gi, "")
                .replace(/\s*[\(\[]from\s+[^)\]]+[\)\]]/gi, "")
                .replace(/\s+/g, " ").trim()
    }

    function primaryArtist(a) {
        if (!a) return ""
        return a.split(/[,&]/)[0].trim()
    }

    function request(url, headers, callback) {
        const xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.timeout = 8000
        for (const h in headers)
            xhr.setRequestHeader(h, headers[h])
        xhr.onreadystatechange = () => {
            if (xhr.readyState === XMLHttpRequest.DONE)
                callback(xhr.status, xhr.responseText)
        }
        xhr.ontimeout = () => callback(0, "")
        xhr.send()
    }

    readonly property var lrclibHeaders: ({
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64)",
        "Lrclib-Client": "quickshell-lyrics/1.0 (ronakgupta3305@gmail.com)"
    })

    function lrclibGet(t, a, len, callback) {
        let url = "https://lrclib.net/api/get?track_name=" + encodeURIComponent(t) + "&artist_name=" + encodeURIComponent(a)
        if (len > 1)
            url += "&duration=" + Math.round(len)
        request(url, lrclibHeaders, (status, body) => {
            try {
                callback(status === 200 ? parseLrc(JSON.parse(body).syncedLyrics || "") : [])
            } catch (e) {
                callback([])
            }
        })
    }

    function lrclibSearch(t, a, len, callback) {
        const url = "https://lrclib.net/api/search?track_name=" + encodeURIComponent(t) + (a ? "&artist_name=" + encodeURIComponent(a) : "")
        request(url, lrclibHeaders, (status, body) => {
            try {
                if (status !== 200) {
                    callback([])
                    return
                }
                const items = JSON.parse(body).filter(r => r.syncedLyrics && r.syncedLyrics.indexOf("[") !== -1)
                if (len > 1) {
                    items.sort((x, y) => {
                        const dx = Math.abs((x.duration || 0) - len)
                        const dy = Math.abs((y.duration || 0) - len)
                        return dx - dy
                    })
                }
                for (let i = 0; i < items.length; i++) {
                    const parsed = parseLrc(items[i].syncedLyrics)
                    if (parsed.length > 0) {
                        callback(parsed)
                        return
                    }
                }
                callback([])
            } catch (e) {
                callback([])
            }
        })
    }

    readonly property var neteaseHeaders: ({
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0",
        "Referer": "https://music.163.com/"
    })

    function netease(t, a, callback) {
        const search = "https://music.163.com/api/search/get?s=" + encodeURIComponent(t + " " + a) + "&type=1&limit=5"
        request(search, neteaseHeaders, (status, body) => {
            let id = -1
            try {
                const songs = status === 200 ? ((JSON.parse(body).result || {}).songs || []) : []
                const al = a.toLowerCase()
                const hit = songs.find(s => {
                    const sa = ((s.artists || [])[0] || {}).name || ""
                    return sa && (al.includes(sa.toLowerCase()) || sa.toLowerCase().includes(al))
                })
                id = hit ? hit.id : -1
            } catch (e) {}
            if (id < 0) {
                callback([])
                return
            }
            request("https://music.163.com/api/song/lyric?id=" + id + "&lv=1&kv=1&tv=-1", neteaseHeaders, (s2, b2) => {
                try {
                    callback(s2 === 200 ? parseLrc((JSON.parse(b2).lrc || {}).lyric || "") : [])
                } catch (e) {
                    callback([])
                }
            })
        })
    }

    // [mm:ss.xx]text, several timestamps per line allowed. An exec() loop, not
    // String.matchAll: the QML engine lacks it, and the TypeError was swallowed
    // by the callers' try blocks, so every lookup quietly came back empty.
    function parseLrc(text) {
        const stamp = /\[(\d+):(\d+(?:\.\d+)?)\]/g
        const result = []
        for (const line of text.split("\n")) {
            const times = []
            stamp.lastIndex = 0
            let m
            while ((m = stamp.exec(line)) !== null)
                times.push(m)
            if (!times.length)
                continue
            const lyric = line.replace(stamp, "").trim()
            for (const t of times)
                result.push({ time: parseInt(t[1]) * 60 + parseFloat(t[2]), text: lyric })
        }
        return result.sort((x, y) => x.time - y.time)
    }
}
