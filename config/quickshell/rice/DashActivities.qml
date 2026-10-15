// Dashboard · Activities: Codeforces & DSA Curriculum Tracker
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

ColumnLayout {
    id: page

    property var dash
    property string searchQuery: ""
    property var expandedParts: ({})
    property var expandedChapters: ({})

    spacing: 14

    component PillButton: Rectangle {
        id: pbtn
        property string label: ""
        property string iconName: ""
        signal clicked

        implicitWidth: btnContent.implicitWidth + 20
        implicitHeight: 32
        radius: 10
        color: btnArea.containsMouse ? Theme.alpha(Theme.primary, 0.22) : Theme.alpha(Theme.surface_container_highest, 0.6)
        border.width: 1
        border.color: btnArea.containsMouse ? Theme.primary : Theme.alpha(Theme.outline_variant, 0.4)

        Row {
            id: btnContent
            anchors.centerIn: parent
            spacing: 6

            LucideIcon {
                visible: pbtn.iconName !== ""
                anchors.verticalCenter: parent.verticalCenter
                icon: pbtn.iconName
                size: 14
                color: Theme.primary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: pbtn.label
                color: Theme.on_surface
                font.family: Theme.font
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pbtn.clicked()
        }
    }

    // ------------------------------------------------------------- top cards --
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        // Codeforces Card
        DashCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 110

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Rectangle {
                    implicitWidth: 44
                    implicitHeight: 44
                    radius: 22
                    color: Theme.alpha(ActivitiesService.cfColor, 0.16)

                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"
                        font.family: Theme.mono
                        font.pixelSize: 22
                        color: ActivitiesService.cfColor
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Row {
                        spacing: 8
                        Text {
                            text: "Codeforces"
                            color: Theme.on_surface_variant
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: ActivitiesService.cfRank
                            color: ActivitiesService.cfColor
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        text: ActivitiesService.cfHandle + ": " + ActivitiesService.cfRating
                        color: Theme.on_surface
                        font.family: Theme.font
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Peak: " + ActivitiesService.cfMaxRank + " (" + ActivitiesService.cfMaxRating + ")"
                        color: Theme.on_surface_variant
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }

                PillButton {
                    label: "Profile 󰌹"
                    onClicked: ActivitiesService.openCodeforcesProfile()
                }
            }
        }

        // LeetCode & DSA Tracker Card
        DashCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 110

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Rectangle {
                    implicitWidth: 44
                    implicitHeight: 44
                    radius: 22
                    color: Theme.alpha(Theme.primary, 0.16)

                    Text {
                        anchors.centerIn: parent
                        text: "󰉻"
                        font.family: Theme.mono
                        font.pixelSize: 22
                        color: Theme.primary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Row {
                        spacing: 8
                        Text {
                            text: "DSA & LeetCode"
                            color: Theme.on_surface_variant
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: ActivitiesService.lcUser + " (" + ActivitiesService.lcTotalSolved + " solved)"
                            color: Theme.primary
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        text: ActivitiesService.dsaQuestionsDone + " / " + ActivitiesService.dsaTotalQuestions + " Questions (" + Math.round(ActivitiesService.dsaProgress * 100) + "%)"
                        color: Theme.on_surface
                        font.family: Theme.font
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    // Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Theme.alpha(Theme.on_surface, 0.1)

                        Rectangle {
                            height: parent.height
                            radius: 3
                            color: Theme.primary
                            width: parent.width * ActivitiesService.dsaProgress
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        }
                    }
                }

                PillButton {
                    label: "󰑐 Sync"
                    onClicked: ActivitiesService.syncLeetCode()
                }
            }
        }
    }

    // ------------------------------------------------------------- search bar --
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            radius: 14
            color: Theme.alpha(Theme.surface_container_high, 0.8)
            border.width: 1
            border.color: Theme.alpha(Theme.outline_variant, 0.5)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                LucideIcon {
                    icon: "search"
                    size: 16
                    color: Theme.on_surface_variant
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: Theme.on_surface
                    font.family: Theme.font
                    font.pixelSize: 13
                    onTextChanged: page.searchQuery = text.trim().toLowerCase()

                    Text {
                        anchors.fill: parent
                        text: "Search chapters, algorithms (e.g. dynamic programming, binary search, graph)..."
                        color: Theme.alpha(Theme.on_surface_variant, 0.6)
                        font.family: Theme.font
                        font.pixelSize: 13
                        visible: searchInput.text === "" && !searchInput.activeFocus
                    }
                }
            }
        }

        PillButton {
            label: "Expand All"
            onClicked: {
                const map = {}
                for (let i = 0; i < ActivitiesService.curriculum.length; i++)
                    map[i] = true
                page.expandedParts = map
            }
        }

        PillButton {
            label: "Collapse All"
            onClicked: page.expandedParts = ({})
        }
    }

    // -------------------------------------------------------- curriculum list --
    DashCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 330
        clip: true

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 14
            contentWidth: col.width
            contentHeight: col.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Column {
                id: col
                width: flick.width - 12
                spacing: 8

                Repeater {
                    model: ActivitiesService.curriculum

                    delegate: Column {
                        id: partDelegate
                        required property var modelData
                        required property int index

                        readonly property bool partMatches: page.searchQuery === ""
                            || modelData.title.toLowerCase().includes(page.searchQuery)
                            || modelData.chapters.some(c => c.title.toLowerCase().includes(page.searchQuery) || c.num.includes(page.searchQuery))

                        visible: partMatches
                        width: parent.width
                        spacing: 4

                        readonly property bool isExpanded: page.searchQuery !== "" || !!page.expandedParts[index]

                        // Part Header Row
                        Rectangle {
                            width: parent.width
                            implicitHeight: 36
                            radius: 10
                            color: partHeaderArea.containsMouse ? Theme.alpha(Theme.on_surface, 0.08) : Theme.alpha(Theme.surface_container_highest, 0.4)

                            MouseArea {
                                id: partHeaderArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const next = Object.assign({}, page.expandedParts)
                                    next[index] = !next[index]
                                    page.expandedParts = next
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: partDelegate.isExpanded ? "▾" : "▸"
                                    color: Theme.primary
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                // Part Checkbox
                                Rectangle {
                                    implicitWidth: 18
                                    implicitHeight: 18
                                    radius: 5
                                    color: isPartComplete ? Theme.primary : "transparent"
                                    border.width: 1.5
                                    border.color: isPartComplete ? Theme.primary : Theme.outline

                                    readonly property bool isPartComplete: {
                                        if (!modelData.chapters.length) return false
                                        return modelData.chapters.every(c => ActivitiesService.isChapterDone(c.num))
                                    }

                                    LucideIcon {
                                        anchors.centerIn: parent
                                        icon: "check"
                                        size: 13
                                        color: Theme.on_primary
                                        visible: parent.isPartComplete
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: ActivitiesService.togglePart(index)
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    color: Theme.on_surface
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    implicitWidth: partBadgeText.implicitWidth + 12
                                    implicitHeight: 20
                                    radius: 6
                                    color: Theme.alpha(Theme.primary, 0.15)

                                    Text {
                                        id: partBadgeText
                                        anchors.centerIn: parent
                                        text: {
                                            const doneCh = modelData.chapters.filter(c => ActivitiesService.isChapterDone(c.num)).length
                                            return doneCh + "/" + modelData.chapters.length + " ch"
                                        }
                                        color: Theme.primary
                                        font.family: Theme.font
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        // Chapters Column
                        Column {
                            width: parent.width
                            visible: partDelegate.isExpanded
                            spacing: 3
                            leftPadding: 26

                            Repeater {
                                model: modelData.chapters

                                delegate: Column {
                                    id: chapterDelegate
                                    required property var modelData
                                    required property int index

                                    readonly property bool chMatches: page.searchQuery === ""
                                        || modelData.title.toLowerCase().includes(page.searchQuery)
                                        || modelData.num.includes(page.searchQuery)

                                    visible: chMatches
                                    width: parent.width - 26
                                    spacing: 3

                                    readonly property bool isDone: ActivitiesService.isChapterDone(modelData.num)
                                    readonly property bool showProblems: !!page.expandedChapters[modelData.num]

                                    readonly property int solvedCount: {
                                        if (!modelData.problems) return 0
                                        let c = 0
                                        const set = {}
                                        ActivitiesService.solvedProblemIds.forEach(id => set[id] = true)
                                        modelData.problems.forEach(p => { if (set[p.id]) c++ })
                                        return c
                                    }

                                    // Chapter Row
                                    RowLayout {
                                        width: parent.width
                                        spacing: 8

                                        // Chapter Checkbox
                                        Rectangle {
                                            implicitWidth: 16
                                            implicitHeight: 16
                                            radius: 4
                                            color: chapterDelegate.isDone ? Theme.primary : "transparent"
                                            border.width: 1.5
                                            border.color: chapterDelegate.isDone ? Theme.primary : Theme.outline

                                            LucideIcon {
                                                anchors.centerIn: parent
                                                icon: "check"
                                                size: 12
                                                color: Theme.on_primary
                                                visible: chapterDelegate.isDone
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: ActivitiesService.toggleChapter(modelData.num)
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.full_label
                                            color: chapterDelegate.isDone ? Theme.alpha(Theme.on_surface, 0.5) : Theme.on_surface
                                            font.family: Theme.font
                                            font.pixelSize: 12
                                            font.strikeout: chapterDelegate.isDone
                                        }

                                        // LC solved badge
                                        Rectangle {
                                            visible: chapterDelegate.solvedCount > 0
                                            implicitWidth: lcBadgeText.implicitWidth + 8
                                            implicitHeight: 18
                                            radius: 5
                                            color: chapterDelegate.solvedCount === (modelData.problems ? modelData.problems.length : 0)
                                                ? Theme.alpha("#73daca", 0.16)
                                                : Theme.alpha(Theme.primary, 0.14)

                                            Text {
                                                id: lcBadgeText
                                                anchors.centerIn: parent
                                                text: chapterDelegate.solvedCount + "/" + (modelData.problems ? modelData.problems.length : 0) + " LC"
                                                color: chapterDelegate.solvedCount === (modelData.problems ? modelData.problems.length : 0) ? "#73daca" : Theme.primary
                                                font.family: Theme.font
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                            }
                                        }

                                        // Problems toggle button
                                        Text {
                                            visible: !!(modelData.problems && modelData.problems.length > 0)
                                            text: chapterDelegate.showProblems ? "Problems ▴" : "Problems ▾"
                                            color: Theme.primary
                                            font.family: Theme.font
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    const next = Object.assign({}, page.expandedChapters)
                                                    next[modelData.num] = !next[modelData.num]
                                                    page.expandedChapters = next
                                                }
                                            }
                                        }

                                        // Open handbook
                                        Text {
                                            text: "󰌹 Open"
                                            color: Theme.on_surface_variant
                                            font.family: Theme.font
                                            font.pixelSize: 11

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: ActivitiesService.openHandbookChapter(modelData.url)
                                            }
                                        }
                                    }

                                    // Problems drawer
                                    Column {
                                        visible: chapterDelegate.showProblems && !!modelData.problems
                                        width: parent.width - 24
                                        leftPadding: 24
                                        spacing: 3

                                        Repeater {
                                            model: modelData.problems || []

                                            delegate: RowLayout {
                                                required property var modelData
                                                width: parent.width
                                                spacing: 6

                                                readonly property bool isSolved: ActivitiesService.solvedProblemIds.indexOf(modelData.id) !== -1

                                                Text {
                                                    text: isSolved ? "✓" : "○"
                                                    color: isSolved ? "#73daca" : Theme.outline
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: (modelData.is_star ? "★ " : "") + "LC " + modelData.id + ": " + modelData.title + " [" + modelData.difficulty + "]" + (isSolved ? "  (Solved)" : "")
                                                    color: isSolved ? "#73daca" : Theme.on_surface_variant
                                                    font.family: Theme.font
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    text: "Solve 󰌹"
                                                    color: Theme.primary
                                                    font.family: Theme.font
                                                    font.pixelSize: 11

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: ActivitiesService.openLeetCodeProblem(modelData.slug)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
