/*
 * Codex Reset — Plasma 6 panel widget.
 * Shows when the next Codex reset is, or when the last one was, from codex-reset.com.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../code/forecast.js" as Forecast

PlasmoidItem {
    id: root

    property var forecast: null
    property bool failed: false
    // Ticks every 30 s so "5h ago" / "in 3h 12m" stay current between fetches.
    property double now: Date.now()
    readonly property var info: forecast ? Forecast.summarize(forecast, now) : null

    readonly property color dotColor: !info ? Kirigami.Theme.disabledTextColor
        : info.state === "announced" ? Kirigami.Theme.negativeTextColor
        : info.state === "hinted" ? Kirigami.Theme.neutralTextColor
        : Kirigami.Theme.disabledTextColor

    Plasmoid.title: "Codex Reset"
    Plasmoid.icon: "view-refresh"
    preferredRepresentation: compactRepresentation
    toolTipMainText: "Codex reset"
    toolTipSubText: info ? (info.state === "announced" ? "Next reset " + info.next : "Last reset " + info.text) : ""

    function fetchForecast() {
        var request = new XMLHttpRequest();
        request.onreadystatechange = function () {
            if (request.readyState !== XMLHttpRequest.DONE) return;
            try {
                if (request.status !== 200) throw new Error(request.status);
                root.forecast = JSON.parse(request.responseText);
                root.failed = false;
            } catch (e) {
                // Keep the last good forecast; its relative times are still right.
                root.failed = true;
            }
            root.now = Date.now();
        };
        request.open("GET", Forecast.FORECAST_URL + "?_=" + Date.now());
        request.send();
    }

    Component.onCompleted: fetchForecast()

    Timer {
        interval: 5 * 60000
        running: true
        repeat: true
        onTriggered: root.fetchForecast()
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: row.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: Layout.minimumWidth
        onClicked: root.expanded = !root.expanded

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: Kirigami.Units.smallSpacing * 2
                height: width
                radius: width / 2
                color: root.dotColor
            }

            PlasmaComponents.Label {
                text: root.info ? root.info.text : (root.failed ? "offline" : "…")
                opacity: root.failed ? 0.6 : 1
            }
        }
    }

    fullRepresentation: MouseArea {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 13
        Layout.preferredHeight: grid.implicitHeight + Kirigami.Units.largeSpacing * 2
        cursorShape: Qt.PointingHandCursor
        onClicked: Qt.openUrlExternally("https://codex-reset.com/")

        GridLayout {
            id: grid
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            columns: 2
            columnSpacing: Kirigami.Units.largeSpacing

            PlasmaComponents.Label { text: "Next reset"; opacity: 0.7 }
            PlasmaComponents.Label { text: root.info ? root.info.next : "…" }

            PlasmaComponents.Label { text: "Last reset"; opacity: 0.7 }
            PlasmaComponents.Label {
                text: root.info && isFinite(root.info.last)
                    ? Qt.formatDateTime(new Date(root.info.last), "MMM d, HH:mm") : "…"
            }

            PlasmaComponents.Label { text: "Chance 24h"; opacity: 0.7 }
            PlasmaComponents.Label { text: root.info && root.info.chance !== null ? root.info.chance + "%" : "…" }

            PlasmaComponents.Label {
                Layout.columnSpan: 2
                Layout.topMargin: Kirigami.Units.smallSpacing
                text: root.failed ? "Can't reach codex-reset.com" : "Click to open codex-reset.com"
                opacity: 0.6
                font: Kirigami.Theme.smallFont
            }
        }
    }
}
