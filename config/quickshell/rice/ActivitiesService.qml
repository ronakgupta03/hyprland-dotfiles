pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")

    // State properties
    property var curriculum: []
    property var completedChapters: []
    property var solvedProblemIds: []
    property var autoCompleted: []
    property var expandedParts: ({})
    property var expandedChapters: ({})

    // LeetCode stats
    property string lcUser: "the__ronakgupta"
    property int lcTotalSolved: 0

    // Codeforces stats
    property string cfHandle: "the.ronak.gupta"
    property int cfRating: 1206
    property string cfRank: "Pupil"
    property int cfMaxRating: 1206
    property string cfMaxRank: "Pupil"

    // Aggregate stats
    readonly property int dsaTotalChapters: 120
    readonly property int dsaTotalQuestions: 437
    readonly property int dsaChaptersDone: completedChapters.length

    readonly property int dsaQuestionsDone: {
        let count = 0
        const doneSet = {}
        for (let i = 0; i < completedChapters.length; i++)
            doneSet[completedChapters[i]] = true

        const solvedSet = {}
        for (let i = 0; i < solvedProblemIds.length; i++)
            solvedSet[solvedProblemIds[i]] = true

        for (let p = 0; p < curriculum.length; p++) {
            const part = curriculum[p]
            for (let c = 0; c < part.chapters.length; c++) {
                const ch = part.chapters[c]
                if (doneSet[ch.num]) {
                    count += ch.q_count
                } else if (ch.problems) {
                    for (let q = 0; q < ch.problems.length; q++) {
                        if (solvedSet[ch.problems[q].id])
                            count++
                    }
                }
            }
        }
        return count
    }

    readonly property real dsaProgress: dsaTotalQuestions > 0 ? (dsaQuestionsDone / dsaTotalQuestions) : 0

    readonly property color cfColor: {
        const r = cfRank.toLowerCase()
        if (r.includes("grandmaster")) return "#ff3333"
        if (r.includes("master")) return "#ffbb55"
        if (r.includes("candidate")) return "#cc66ff"
        if (r.includes("expert")) return "#6699ff"
        if (r.includes("specialist")) return "#33ddbb"
        if (r.includes("pupil")) return "#55ee55"
        return "#aaaaaa"
    }

    // Load curriculum data
    FileView {
        path: root.home + "/.config/waybar/scripts/dsa_data.json"
        onLoaded: {
            try {
                root.curriculum = JSON.parse(text()) || []
            } catch (e) {
                console.warn("ActivitiesService: unreadable dsa_data.json:", e)
            }
        }
    }

    // Load user state
    FileView {
        id: stateFile
        path: root.home + "/.config/waybar/dsa_state.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text()) || {}
                root.completedChapters = d.completed_chapters || []
                root.autoCompleted = d.auto_completed || []
                root.expandedParts = d.expanded_parts || ({})
                root.expandedChapters = d.expanded_chapters || ({})
                if (d.leetcode_user)
                    root.lcUser = d.leetcode_user
            } catch (e) {
                console.warn("ActivitiesService: unreadable dsa_state.json:", e)
            }
        }
    }

    // Load LeetCode solved problems
    FileView {
        path: root.home + "/.config/waybar/leetcode_solved.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text()) || {}
                root.solvedProblemIds = d.solved_ids || []
                root.lcTotalSolved = d.total_solved || 0
                if (d.username)
                    root.lcUser = d.username
            } catch (e) {
                console.warn("ActivitiesService: unreadable leetcode_solved.json:", e)
            }
        }
    }

    // Load Codeforces cache
    FileView {
        path: "/tmp/codeforces_waybar_activity_cache.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text()) || {}
                const u = d.user || {}
                if (u.handle) root.cfHandle = u.handle
                if (u.rating) root.cfRating = u.rating
                if (u.rank) root.cfRank = u.rank
                if (u.maxRating) root.cfMaxRating = u.maxRating
                if (u.maxRank) root.cfMaxRank = u.maxRank
            } catch (e) {
                console.warn("ActivitiesService: unreadable codeforces cache:", e)
            }
        }
    }

    function isChapterDone(num) {
        return completedChapters.indexOf(num) !== -1
    }

    function toggleChapter(num) {
        const idx = completedChapters.indexOf(num)
        let next = []
        if (idx !== -1) {
            next = completedChapters.filter(n => n !== num)
        } else {
            next = completedChapters.concat([num])
        }
        completedChapters = next
        saveState()
    }

    function togglePart(partIdx) {
        if (partIdx < 0 || partIdx >= curriculum.length)
            return
        const part = curriculum[partIdx]
        const partNums = part.chapters.map(c => c.num)
        const allDone = partNums.every(n => isChapterDone(n))

        let next = []
        if (allDone) {
            next = completedChapters.filter(n => partNums.indexOf(n) === -1)
        } else {
            const set = {}
            completedChapters.forEach(n => set[n] = true)
            partNums.forEach(n => set[n] = true)
            next = Object.keys(set)
        }
        completedChapters = next
        saveState()
    }

    function saveState() {
        const payload = {
            completed_chapters: completedChapters.slice().sort(),
            auto_completed: autoCompleted,
            solved_questions: solvedProblemIds,
            expanded_parts: expandedParts,
            expanded_chapters: expandedChapters,
            leetcode_user: lcUser,
            last_sync: Math.floor(Date.now() / 1000)
        }
        stateFile.setText(JSON.stringify(payload, null, 2) + "\n")
        Quickshell.execDetached(["killall", "-44", "waybar"])
    }

    function isPartExpanded(idx) {
        return !!expandedParts[idx]
    }

    function togglePartExpanded(idx) {
        const next = Object.assign({}, expandedParts)
        next[idx] = !next[idx]
        expandedParts = next
        saveState()
    }

    function isChapterExpanded(num) {
        return !!expandedChapters[num]
    }

    function toggleChapterExpanded(num) {
        const next = Object.assign({}, expandedChapters)
        next[num] = !next[num]
        expandedChapters = next
        saveState()
    }

    function setAllPartsExpanded(val) {
        const next = {}
        if (val) {
            for (let i = 0; i < curriculum.length; i++)
                next[i] = true
        }
        expandedParts = next
        saveState()
    }

    function syncLeetCode() {
        Quickshell.execDetached(["/usr/bin/python3", root.home + "/.config/waybar/scripts/leetcode_sync.py"])
    }

    function openLeetCodeProblem(slug) {
        const url = slug ? ("https://leetcode.com/problems/" + slug + "/") : "https://leetcode.com/"
        Qt.openUrlExternally(url)
    }

    function openCodeforcesProfile() {
        Qt.openUrlExternally("https://codeforces.com/profile/" + cfHandle)
    }

    function openHandbookChapter(url) {
        Qt.openUrlExternally(url)
    }
}
