pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string scriptPath: home + "/.config/waybar/scripts/codeforces_full_sync.py"

    property string handle: "the.ronak.gupta"
    property string name: "Ronak Gupta"
    property string country: "India"
    property string city: "Delhi"
    property string org: "VIPS - TC"
    property int rating: 1206
    property string rank: "pupil"
    property int maxRating: 1246
    property string maxRank: "pupil"
    property string avatar: ""
    property int totalContests: 23
    property int totalSubmissions: 622
    property int totalAccepted: 276
    property int uniqueSolved: 258
    property real accuracy: 44.4
    property var ratingDist: []
    property var tagsDist: []
    property var recentContests: []
    property var recentSolved: []
    property var upcomingContests: []
    property string lastUpdatedHuman: ""
    property bool syncing: false

    readonly property color rankColor: {
        const r = rank.toLowerCase()
        if (r.includes("legendary") || r.includes("tourist")) return "#ff0000"
        if (r.includes("grandmaster")) return "#ff3333"
        if (r.includes("master")) return "#ffbb55"
        if (r.includes("candidate")) return "#cc66ff"
        if (r.includes("expert")) return "#6699ff"
        if (r.includes("specialist")) return "#33ddbb"
        if (r.includes("pupil")) return "#55ee55"
        return "#aaaaaa"
    }

    readonly property color maxRankColor: {
        const r = maxRank.toLowerCase()
        if (r.includes("legendary") || r.includes("tourist")) return "#ff0000"
        if (r.includes("grandmaster")) return "#ff3333"
        if (r.includes("master")) return "#ffbb55"
        if (r.includes("candidate")) return "#cc66ff"
        if (r.includes("expert")) return "#6699ff"
        if (r.includes("specialist")) return "#33ddbb"
        if (r.includes("pupil")) return "#55ee55"
        return "#aaaaaa"
    }

    FileView {
        id: cacheView
        path: root.home + "/.cache/rice/codeforces_full.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text()) || {}
                root.handle = d.handle || root.handle
                root.name = d.name || root.name
                root.country = d.country || root.country
                root.city = d.city || root.city
                root.org = d.org || root.org
                root.rating = d.rating ?? root.rating
                root.rank = d.rank || root.rank
                root.maxRating = d.maxRating ?? root.maxRating
                root.maxRank = d.maxRank || root.maxRank
                root.avatar = d.avatar || ""
                root.totalContests = d.totalContests ?? root.totalContests
                root.totalSubmissions = d.totalSubmissions ?? root.totalSubmissions
                root.totalAccepted = d.totalAccepted ?? root.totalAccepted
                root.uniqueSolved = d.uniqueSolved ?? root.uniqueSolved
                root.accuracy = d.accuracy ?? root.accuracy
                root.ratingDist = d.ratingDist || []
                root.tagsDist = d.tagsDist || []
                root.recentContests = d.recentContests || []
                root.recentSolved = d.recentSolved || []
                root.upcomingContests = d.upcomingContests || []
                root.lastUpdatedHuman = d.lastUpdatedHuman || ""
                root.syncing = false
            } catch (e) {
                console.warn("CodeforcesService: parse error:", e)
            }
        }
    }

    function refresh() {
        if (syncing) return
        syncing = true
        Quickshell.execDetached(["/usr/bin/python3", root.scriptPath])
    }

    // Auto-refresh every 5 minutes (300,000 ms) in background
    Timer {
        interval: 300000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: {
        // Initial sync if cache missing or empty
        if (!ratingDist.length)
            root.refresh()
    }
}
