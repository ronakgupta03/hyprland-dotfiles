// Dashboard · Codeforces (CF): Live statistics, rating history, problem breakdown, upcoming rounds
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

ColumnLayout {
    id: page

    property var dash
    property int nowSeconds: Math.floor(Date.now() / 1000)

    spacing: 12

    // 1-second timer for live upcoming contest countdown
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: page.nowSeconds = Math.floor(Date.now() / 1000)
    }

    component CFButton: Rectangle {
        id: cfBtn
        property string label: ""
        property string iconName: ""
        property color textColor: Theme.on_surface
        property color btnColor: Theme.alpha(Theme.surface_container_highest, 0.6)
        signal clicked

        implicitWidth: cfContent.implicitWidth + 20
        implicitHeight: 32
        radius: 10
        color: cfArea.containsMouse ? Theme.alpha(Theme.primary, 0.24) : btnColor
        border.width: 1
        border.color: cfArea.containsMouse ? Theme.primary : Theme.alpha(Theme.outline_variant, 0.4)

        Row {
            id: cfContent
            anchors.centerIn: parent
            spacing: 6

            LucideIcon {
                visible: cfBtn.iconName !== ""
                anchors.verticalCenter: parent.verticalCenter
                icon: cfBtn.iconName
                size: 14
                color: Theme.primary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: cfBtn.label
                color: cfBtn.textColor
                font.family: Theme.font
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: cfArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cfBtn.clicked()
        }
    }

    // -------------------------------------------------------- top profile banner --
    DashCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 114

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Avatar / Trophy badge
            Rectangle {
                implicitWidth: 54
                implicitHeight: 54
                radius: 27
                color: Theme.alpha(CodeforcesService.rankColor, 0.18)
                border.width: 2
                border.color: CodeforcesService.rankColor

                LucideIcon {
                    anchors.centerIn: parent
                    icon: "trophy"
                    size: 26
                    color: CodeforcesService.rankColor
                }
            }

            // User Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Row {
                    spacing: 8
                    Text {
                        text: CodeforcesService.handle
                        color: Theme.on_surface
                        font.family: Theme.font
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    Rectangle {
                        implicitWidth: rankText.implicitWidth + 12
                        implicitHeight: 22
                        radius: 6
                        color: Theme.alpha(CodeforcesService.rankColor, 0.2)
                        border.width: 1
                        border.color: CodeforcesService.rankColor

                        Text {
                            id: rankText
                            anchors.centerIn: parent
                            text: CodeforcesService.rank.toUpperCase()
                            color: CodeforcesService.rankColor
                            font.family: Theme.font
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }
                }

                Row {
                    spacing: 14
                    Text {
                        text: "Current: <font color='" + CodeforcesService.rankColor + "'><b>" + CodeforcesService.rating + "</b></font>"
                        textFormat: Text.RichText
                        color: Theme.on_surface_variant
                        font.family: Theme.font
                        font.pixelSize: 13
                    }
                    Text {
                        text: "Max: <font color='" + CodeforcesService.maxRankColor + "'><b>" + CodeforcesService.maxRating + "</b> (" + CodeforcesService.maxRank + ")</font>"
                        textFormat: Text.RichText
                        color: Theme.on_surface_variant
                        font.family: Theme.font
                        font.pixelSize: 13
                    }
                    Text {
                        text: "· " + CodeforcesService.org + " (" + CodeforcesService.country + ")"
                        color: Theme.alpha(Theme.on_surface_variant, 0.7)
                        font.family: Theme.font
                        font.pixelSize: 12
                    }
                }
            }

            // Quick Stats Badges
            RowLayout {
                spacing: 10

                Rectangle {
                    implicitWidth: 80
                    implicitHeight: 52
                    radius: 12
                    color: Theme.alpha(Theme.surface_container_highest, 0.5)
                    border.width: 1
                    border.color: Theme.alpha(Theme.outline_variant, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: CodeforcesService.uniqueSolved
                            color: Theme.primary
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "SOLVED"
                            color: Theme.on_surface_variant
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 80
                    implicitHeight: 52
                    radius: 12
                    color: Theme.alpha(Theme.surface_container_highest, 0.5)
                    border.width: 1
                    border.color: Theme.alpha(Theme.outline_variant, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: CodeforcesService.totalContests
                            color: Theme.tertiary
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "ROUNDS"
                            color: Theme.on_surface_variant
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 80
                    implicitHeight: 52
                    radius: 12
                    color: Theme.alpha(Theme.surface_container_highest, 0.5)
                    border.width: 1
                    border.color: Theme.alpha(Theme.outline_variant, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: CodeforcesService.accuracy + "%"
                            color: "#73daca"
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "ACCURACY"
                            color: Theme.on_surface_variant
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                ColumnLayout {
                    spacing: 6
                    CFButton {
                        label: CodeforcesService.syncing ? "Syncing…" : "󰑐 Sync"
                        onClicked: CodeforcesService.refresh()
                    }
                    CFButton {
                        label: "Profile 󰌹"
                        onClicked: Qt.openUrlExternally("https://codeforces.com/profile/" + CodeforcesService.handle)
                    }
                }
            }
        }
    }

    // ---------------------------------------------------- scrollable statistics --
    DashCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 380
        clip: true

        Flickable {
            id: cfFlick
            anchors.fill: parent
            anchors.margins: 16
            contentWidth: cfCol.width
            contentHeight: cfCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: cfCol
                width: cfFlick.width - 12
                spacing: 16

                // 1. Upcoming Contests Alert
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 12
                    color: Theme.alpha(Theme.primary, 0.12)
                    border.width: 1
                    border.color: Theme.alpha(Theme.primary, 0.35)
                    visible: CodeforcesService.upcomingContests.length > 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        LucideIcon {
                            icon: "flame"
                            size: 18
                            color: Theme.primary
                        }

                        Text {
                            text: "Next Contest:"
                            color: Theme.primary
                            font.family: Theme.font
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: {
                                if (!CodeforcesService.upcomingContests.length) return ""
                                const next = CodeforcesService.upcomingContests[0]
                                const diff = next.startTime - page.nowSeconds
                                if (diff <= 0) return next.name + " (Started / Running)"
                                const days = Math.floor(diff / 86400)
                                const hrs = Math.floor((diff % 86400) / 3600)
                                const mins = Math.floor((diff % 3600) / 60)
                                const secs = diff % 60
                                let timeStr = ""
                                if (days > 0) timeStr += days + "d "
                                timeStr += hrs + "h " + mins + "m " + secs + "s"
                                return next.name + "  ·  Starts in: " + timeStr
                            }
                            color: Theme.on_surface
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        CFButton {
                            label: "Register 󰌹"
                            textColor: Theme.primary
                            onClicked: {
                                if (CodeforcesService.upcomingContests.length)
                                    Qt.openUrlExternally(CodeforcesService.upcomingContests[0].url)
                            }
                        }
                    }
                }

                // 2. Rating Distribution Chart
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Problem Rating Breakdown"
                            color: Theme.on_surface
                            font.family: Theme.font
                            font.pixelSize: 14
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: CodeforcesService.uniqueSolved + " problems solved"
                            color: Theme.on_surface_variant
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                    }

                    // Horizontal bars for each rating level
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: CodeforcesService.ratingDist

                            delegate: ColumnLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                spacing: 4

                                readonly property real maxCount: {
                                    let m = 1
                                    for (let i = 0; i < CodeforcesService.ratingDist.length; i++)
                                        m = Math.max(m, CodeforcesService.ratingDist[i].count)
                                    return m
                                }

                                readonly property color barCol: {
                                    const r = modelData.rating
                                    if (r >= 1900) return "#ff3333"
                                    if (r >= 1600) return "#6699ff"
                                    if (r >= 1400) return "#33ddbb"
                                    if (r >= 1200) return "#55ee55"
                                    return "#aaaaaa"
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.count
                                    color: barCol
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 70
                                    radius: 6
                                    color: Theme.alpha(Theme.surface_container_highest, 0.4)

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        radius: 6
                                        color: barCol
                                        height: Math.max(6, (modelData.count / maxCount) * parent.height)
                                        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.rating
                                    color: Theme.on_surface_variant
                                    font.family: Theme.font
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }

                // 3. Top Topic Tags
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Solved Problems by Topic"
                        color: Theme.on_surface
                        font.family: Theme.font
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: CodeforcesService.tagsDist

                            delegate: Rectangle {
                                required property var modelData
                                implicitWidth: tagRow.implicitWidth + 16
                                implicitHeight: 28
                                radius: 8
                                color: Theme.alpha(Theme.surface_container_highest, 0.6)
                                border.width: 1
                                border.color: Theme.alpha(Theme.outline_variant, 0.3)

                                Row {
                                    id: tagRow
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: modelData.tag
                                        color: Theme.on_surface
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitWidth: tagCountText.implicitWidth + 8
                                        implicitHeight: 18
                                        radius: 5
                                        color: Theme.alpha(Theme.primary, 0.18)

                                        Text {
                                            id: tagCountText
                                            anchors.centerIn: parent
                                            text: modelData.count
                                            color: Theme.primary
                                            font.family: Theme.font
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Qt.openUrlExternally("https://codeforces.com/problemset?tags=" + encodeURIComponent(modelData.tag))
                                }
                            }
                        }
                    }
                }

                // 4. Recent Contests Performance
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Recent Contest History"
                        color: Theme.on_surface
                        font.family: Theme.font
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    Repeater {
                        model: CodeforcesService.recentContests

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 40
                            radius: 10
                            color: cArea.containsMouse ? Theme.alpha(Theme.on_surface, 0.08) : Theme.alpha(Theme.surface_container_highest, 0.4)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.contestName
                                    color: Theme.on_surface
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "Rank: " + modelData.rank
                                    color: Theme.on_surface_variant
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                }

                                Rectangle {
                                    implicitWidth: 64
                                    implicitHeight: 22
                                    radius: 6
                                    color: modelData.diff >= 0 ? Theme.alpha("#55ee55", 0.18) : Theme.alpha("#ff3333", 0.18)

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.diffStr
                                        color: modelData.diff >= 0 ? "#55ee55" : "#ff3333"
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                }

                                Text {
                                    text: "→ " + modelData.newRating
                                    color: Theme.primary
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                id: cArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.openUrlExternally(modelData.url)
                            }
                        }
                    }
                }
            }
        }
    }
}
