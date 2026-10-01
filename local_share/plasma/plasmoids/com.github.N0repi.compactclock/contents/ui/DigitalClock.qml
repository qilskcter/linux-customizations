/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2013 Martin Klapetek <mklapetek@kde.org>
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.private.digitalclock
import org.kde.kirigami as Kirigami
import org.kde.plasma.clock

MouseArea {
    id: main
    objectName: "compact-clock-compactrepresentation"

    property string timeFormat
    property string timeFormatWithSeconds

    readonly property var dateFormatter: {
        if (Plasmoid.configuration.dateFormat === "custom") {
            Plasmoid.configuration.customDateFormat;
            return (d) => Qt.locale().toString(d, Plasmoid.configuration.customDateFormat);
        } else if (Plasmoid.configuration.dateFormat === "isoDate") {
            return (d) => Qt.formatDate(d, Qt.ISODate);
        } else if (Plasmoid.configuration.dateFormat === "longDate") {
            return (d) => Qt.formatDate(d, Qt.locale(), Locale.LongFormat);
        } else {
            return (d) => Qt.formatDate(d, Qt.locale(), Locale.ShortFormat);
        }
    }

    readonly property string dayText: {
        const fmt = Plasmoid.configuration.dayFormat === "long" ? "dddd" : "ddd";
        return Qt.locale().toString(clock.dateTime, fmt);
    }

    readonly property string timeText: {
        const fmt = Plasmoid.configuration.showSeconds === 2 ? main.timeFormatWithSeconds : main.timeFormat;
        return Qt.locale().toString(clock.dateTime, fmt);
    }

    readonly property string dateText: main.dateFormatter(clock.dateTime)

    readonly property var visibleSegments: {
        // Bind to config fields used below
        Plasmoid.configuration.showTime;
        Plasmoid.configuration.showDay;
        Plasmoid.configuration.showDate;
        Plasmoid.configuration.segmentOrder;
        main.timeText;
        main.dayText;
        main.dateText;

        const enabled = {
            "time": Plasmoid.configuration.showTime,
            "day": Plasmoid.configuration.showDay,
            "date": Plasmoid.configuration.showDate,
        };
        const values = {
            "time": main.timeText,
            "day": main.dayText,
            "date": main.dateText,
        };

        const order = String(Plasmoid.configuration.segmentOrder || "date,time")
            .split(",")
            .map(s => s.trim().toLowerCase())
            .filter(s => s === "time" || s === "day" || s === "date");

        // Fall back if the user cleared everything
        const tokens = order.length > 0 ? order : ["date", "time"];
        const seen = {};
        const result = [];
        for (const token of tokens) {
            if (seen[token] || !enabled[token]) {
                continue;
            }
            seen[token] = true;
            const text = values[token];
            if (text && text.length > 0) {
                result.push({ type: token, text });
            }
        }
        return result;
    }

    readonly property string separator: Plasmoid.configuration.segmentSeparator

    readonly property string compactText: {
        const parts = main.visibleSegments.map(s => s.text);
        const sep = main.separator;
        let line = parts.join(sep);

        if (timeZoneLabel.text.length > 0) {
            line = line.length > 0 ? `${line}${sep}${timeZoneLabel.text}` : timeZoneLabel.text;
        }
        return line;
    }

    // Stacked (two-line) only when explicitly requested, or on vertical panels
    readonly property bool oneLineMode: {
        if (Plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return false;
        }
        if (Plasmoid.configuration.dateDisplayFormat === 2) {
            // BelowTime
            return false;
        }
        // Adaptive or BesideTime → single line for this plasmoid
        return true;
    }

    property string lastDate: ""
    property int tzIndex: 0
    property bool wasExpanded
    property int wheelDelta: 0

    Accessible.role: Accessible.Button
    Accessible.name: main.compactText
    Accessible.onPressAction: clicked(null)

    // Never fill width on a horizontal panel. Measure via sizehelper after VerticalFit
    // (a Label with font.pixelSize: 1024 otherwise reports a huge implicitWidth).
    Layout.fillHeight: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    Layout.fillWidth: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    Layout.minimumWidth: contentItem.width
    Layout.maximumWidth: contentItem.width
    Layout.preferredWidth: contentItem.width
    Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? contentItem.height : 0
    Layout.maximumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? contentItem.height : Infinity
    Layout.preferredHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? contentItem.height : -1

    Clock {
        id: clock
        timeZone: Plasmoid.configuration.lastSelectedTimezone
        trackSeconds: Plasmoid.configuration.showSeconds == 2
        onDateTimeChanged: main.dateTimeChanged()
        onTimeZoneChanged: main.setupLabels()
    }

    Connections {
        target: Plasmoid
        function onContextualActionsAboutToShow() {
            ClipboardMenu.secondsIncluded = (Plasmoid.configuration.showSeconds === 2);
            ClipboardMenu.timezone = clock.timeZone;
        }
    }

    Connections {
        target: Plasmoid.configuration
        function onSelectedTimeZonesChanged() {
            if (Plasmoid.configuration.selectedTimeZones.indexOf(Plasmoid.configuration.lastSelectedTimezone) === -1) {
                Plasmoid.configuration.lastSelectedTimezone = Plasmoid.configuration.selectedTimeZones[0];
            }
            main.setupLabels();
            main.setTimeZoneIndex();
        }
        function onDisplayTimezoneFormatChanged() { main.setupLabels(); }
        function onLastSelectedTimezoneChanged() { main.timeFormatCorrection(); }
        function onShowLocalTimezoneChanged() { main.timeFormatCorrection(); }
        function onShowDateChanged() { main.timeFormatCorrection(); }
        function onShowTimeChanged() { main.timeFormatCorrection(); }
        function onShowDayChanged() { main.timeFormatCorrection(); }
        function onSegmentOrderChanged() { main.setupLabels(); }
        function onSegmentSeparatorChanged() { main.setupLabels(); }
        function onDayFormatChanged() { main.setupLabels(); }
        function onUse24hFormatChanged() { main.timeFormatCorrection(); }
        function onDateFormatChanged() { main.setupLabels(); }
        function onCustomDateFormatChanged() { main.setupLabels(); }
    }

    function pointToPixel(pointSize: int): int {
        const pixelsPerInch = Screen.pixelDensity * 25.4;
        return Math.round(pointSize / 72 * pixelsPerInch);
    }

    acceptedButtons: Qt.LeftButton | (ApplicationIntegration.calendarInstalled ? Qt.MiddleButton : 0)
    onPressed: wasExpanded = root.expanded
    onClicked: mouse => {
        if (!mouse) {
            root.expanded = !wasExpanded;
            return;
        }
        if (mouse.button === Qt.MiddleButton && ApplicationIntegration.calendarInstalled) {
            ApplicationIntegration.launchCalendar();
        } else if (mouse.button === Qt.LeftButton) {
            root.expanded = !wasExpanded;
        }
    }
    onWheel: wheel => {
        if (!Plasmoid.configuration.wheelChangesTimezone) {
            return;
        }

        var delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x);
        var newIndex = tzIndex;
        wheelDelta += delta;
        while (wheelDelta >= 120) {
            wheelDelta -= 120;
            newIndex--;
        }
        while (wheelDelta <= -120) {
            wheelDelta += 120;
            newIndex++;
        }

        if (newIndex >= Plasmoid.configuration.selectedTimeZones.length) {
            newIndex = 0;
        } else if (newIndex < 0) {
            newIndex = Plasmoid.configuration.selectedTimeZones.length - 1;
        }

        if (newIndex !== tzIndex) {
            Plasmoid.configuration.lastSelectedTimezone = Plasmoid.configuration.selectedTimeZones[newIndex];
            tzIndex = newIndex;
        }
    }

    Item {
        id: contentItem
        anchors.verticalCenter: main.verticalCenter
        anchors.horizontalCenter: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? main.horizontalCenter : undefined

        width: main.oneLineMode ? Math.ceil(sizehelper.contentWidth) : stackedColumn.implicitWidth
        height: main.oneLineMode
            ? sizehelper.height
            : stackedColumn.implicitHeight

        // Primary horizontal / one-line presentation
        PlasmaComponents.Label {
            id: compactLabel
            visible: main.oneLineMode
            height: parent.height
            width: parent.width
            text: main.compactText
            textFormat: Text.PlainText
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: fontHelper.font.family
            font.weight: fontHelper.font.weight
            font.italic: fontHelper.font.italic
            font.features: { "tnum": 1 }
            font.pixelSize: 1024
            fontSizeMode: Text.VerticalFit
            minimumPixelSize: 1
        }

        // Vertical panel / "below time" stacked presentation
        Column {
            id: stackedColumn
            visible: !main.oneLineMode
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            PlasmaComponents.Label {
                id: stackedTimeLabel
                visible: Plasmoid.configuration.showTime
                width: Math.max(paintedWidth, stackedDateLabel.paintedWidth, stackedDayLabel.paintedWidth, 1)
                horizontalAlignment: Text.AlignHCenter
                text: main.timeText
                textFormat: Text.PlainText
                font.family: fontHelper.font.family
                font.weight: fontHelper.font.weight
                font.italic: fontHelper.font.italic
                font.features: { "tnum": 1 }
                font.pixelSize: Math.round(main.height * (Plasmoid.configuration.showDate || Plasmoid.configuration.showDay ? 0.56 : 0.71))
            }

            PlasmaComponents.Label {
                id: stackedDayLabel
                visible: Plasmoid.configuration.showDay
                width: stackedTimeLabel.width
                horizontalAlignment: Text.AlignHCenter
                text: main.dayText
                textFormat: Text.PlainText
                font.family: fontHelper.font.family
                font.weight: fontHelper.font.weight
                font.italic: fontHelper.font.italic
                font.pixelSize: Math.round(stackedTimeLabel.font.pixelSize * 0.7)
            }

            PlasmaComponents.Label {
                id: stackedDateLabel
                visible: Plasmoid.configuration.showDate
                width: stackedTimeLabel.width
                horizontalAlignment: Text.AlignHCenter
                text: main.dateText
                textFormat: Text.PlainText
                font.family: fontHelper.font.family
                font.weight: fontHelper.font.weight
                font.italic: fontHelper.font.italic
                font.pixelSize: Math.round(stackedTimeLabel.font.pixelSize * 0.7)
            }

            PlasmaComponents.Label {
                visible: timeZoneLabel.text.length > 0
                width: stackedTimeLabel.width
                horizontalAlignment: Text.AlignHCenter
                text: timeZoneLabel.text
                textFormat: Text.PlainText
                font.family: fontHelper.font.family
                font.weight: fontHelper.font.weight
                font.italic: fontHelper.font.italic
                font.pixelSize: Math.round(stackedTimeLabel.font.pixelSize * 0.7)
            }
        }

        // Hidden label used only so setupLabels can write timezone text
        PlasmaComponents.Label {
            id: timeZoneLabel
            visible: false
            textFormat: Text.PlainText
        }
    }

    // Measures one-line width at the panel-fitted font size (same trick as stock clock)
    PlasmaComponents.Label {
        id: sizehelper
        visible: false
        textFormat: Text.PlainText
        text: main.compactText
        font.family: fontHelper.font.family
        font.weight: fontHelper.font.weight
        font.italic: fontHelper.font.italic
        font.features: { "tnum": 1 }
        height: Math.min(main.height > 0 ? main.height : fontHelper.contentHeight, fontHelper.contentHeight)
        font.pixelSize: fontHelper.font.pixelSize
        fontSizeMode: Text.VerticalFit
        minimumPixelSize: 1
    }

    PlasmaComponents.Label {
        id: fontHelper
        height: 1024
        font.family: (Plasmoid.configuration.autoFontAndSize || Plasmoid.configuration.fontFamily.length === 0)
            ? Kirigami.Theme.defaultFont.family
            : Plasmoid.configuration.fontFamily
        font.weight: Plasmoid.configuration.autoFontAndSize
            ? Kirigami.Theme.defaultFont.weight
            : Plasmoid.configuration.fontWeight
        font.italic: Plasmoid.configuration.autoFontAndSize
            ? Kirigami.Theme.defaultFont.italic
            : Plasmoid.configuration.italicText
        font.pixelSize: Plasmoid.configuration.autoFontAndSize
            ? 3 * Kirigami.Theme.defaultFont.pixelSize
            : main.pointToPixel(Plasmoid.configuration.fontSize)
        fontSizeMode: Text.VerticalFit
        visible: false
        textFormat: Text.PlainText
        text: main.compactText.length > 0 ? main.compactText : "00:00"
    }

    function timeFormatCorrection(timeFormatString = Qt.locale().timeFormat(Locale.ShortFormat)) {
        const regexp = /(hh*)(.+)(mm)/i;
        const match = regexp.exec(timeFormatString);
        if (!match) {
            timeFormat = timeFormatString;
            timeFormatWithSeconds = timeFormatString;
            setupLabels();
            return;
        }

        const hours = match[1];
        const delimiter = match[2];
        const minutes = match[3];
        const seconds = "ss";
        const amPm = "AP";
        const uses24hFormatByDefault = timeFormatString.toLowerCase().indexOf("ap") === -1;

        let result = hours.toLowerCase() + delimiter + minutes;
        let result_sec = result + delimiter + seconds;

        if ((Plasmoid.configuration.use24hFormat === Qt.PartiallyChecked && !uses24hFormatByDefault)
            || Plasmoid.configuration.use24hFormat === Qt.Unchecked) {
            result += " " + amPm;
            result_sec += " " + amPm;
        }

        timeFormat = result;
        timeFormatWithSeconds = result_sec;
        setupLabels();
    }

    function setupLabels() {
        const showTimezone = Plasmoid.configuration.showLocalTimezone
            || (Plasmoid.configuration.lastSelectedTimezone !== "Local"
                && !clock.isSystemTimeZone);

        let timezoneString = "";
        if (showTimezone) {
            switch (Plasmoid.configuration.displayTimezoneFormat) {
            case 0:
                timezoneString = clock.timeZoneCode;
                break;
            case 1:
                timezoneString = TimeZonesI18n.i18nCity(clock.timeZone);
                break;
            case 2:
                timezoneString = clock.timeZoneOffset;
                break;
            }
            if (main.oneLineMode && Plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
                timezoneString = `(${timezoneString})`;
            }
        }
        timeZoneLabel.text = timezoneString;
    }

    function dateTimeChanged() {
        let doCorrections = false;
        if (Plasmoid.configuration.showDate || Plasmoid.configuration.showDay) {
            const currentDate = Qt.formatDateTime(clock.dateTime, "yyyy-MM-dd");
            if (lastDate !== currentDate) {
                doCorrections = true;
                lastDate = currentDate;
            }
        }
        if (doCorrections) {
            timeFormatCorrection();
        }
    }

    function setTimeZoneIndex() {
        tzIndex = Plasmoid.configuration.selectedTimeZones.indexOf(Plasmoid.configuration.lastSelectedTimezone);
    }

    Component.onCompleted: {
        Plasmoid.configuration.selectedTimeZones = TimeZoneUtils.sortedTimeZones(Plasmoid.configuration.selectedTimeZones);
        setTimeZoneIndex();
        dateTimeChanged();
        timeFormatCorrection();
    }
}
