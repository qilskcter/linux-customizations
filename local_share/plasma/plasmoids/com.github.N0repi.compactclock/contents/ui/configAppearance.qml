/*
    SPDX-FileCopyrightText: 2013 Bhushan Shah <bhush94@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Qt.labs.platform as Platform

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.config as KConfig
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    id: appearancePage
    property alias cfg_autoFontAndSize: autoFontAndSizeRadioButton.checked

    property alias cfg_fontFamily: fontDialog.fontChosen.family
    property alias cfg_boldText: fontDialog.fontChosen.bold
    property alias cfg_italicText: fontDialog.fontChosen.italic
    property alias cfg_fontWeight: fontDialog.fontChosen.weight
    property alias cfg_fontStyleName: fontDialog.fontChosen.styleName
    property alias cfg_fontSize: fontDialog.fontChosen.pointSize

    property string cfg_timeFormat: ""
    property alias cfg_showLocalTimezone: showLocalTimeZone.checked
    property alias cfg_displayTimezoneFormat: displayTimeZoneFormat.currentIndex
    property alias cfg_showSeconds: showSecondsComboBox.currentIndex

    property alias cfg_showTime: showTime.checked
    property alias cfg_showDay: showDay.checked
    property alias cfg_showDate: showDate.checked
    property string cfg_dayFormat: "short"
    property string cfg_dateFormat: "custom"
    property alias cfg_customDateFormat: customDateFormat.text
    property alias cfg_use24hFormat: use24hFormat.currentIndex
    property alias cfg_dateDisplayFormat: dateDisplayFormat.currentIndex
    property string cfg_segmentOrder: "date,time"
    property alias cfg_segmentSeparator: segmentSeparatorField.text

    readonly property var orderPresets: [
        { label: i18n("Date, Time"), value: "date,time" },
        { label: i18n("Time, Date"), value: "time,date" },
        { label: i18n("Time, Day, Date"), value: "time,day,date" },
        { label: i18n("Day, Date, Time"), value: "day,date,time" },
        { label: i18n("Date, Day, Time"), value: "date,day,time" },
        { label: i18n("Day, Time, Date"), value: "day,time,date" },
        { label: i18n("Custom…"), value: "custom" },
    ]

    property real comboBoxWidth: Math.max(dateDisplayFormat.implicitWidth,
                                          showSecondsComboBox.implicitWidth,
                                          displayTimeZoneFormat.implicitWidth,
                                          use24hFormat.implicitWidth,
                                          dateFormat.implicitWidth,
                                          segmentOrderCombo.implicitWidth,
                                          dayFormatCombo.implicitWidth)

    function previewText(): string {
        const now = new Date();
        const values = {
            time: Qt.locale().toString(now, appearancePage.cfg_use24hFormat === 0 ? "h:mm AP"
                : (appearancePage.cfg_use24hFormat === 2 ? "HH:mm" : Qt.locale().timeFormat(Locale.ShortFormat))),
            day: Qt.locale().toString(now, appearancePage.cfg_dayFormat === "long" ? "dddd" : "ddd"),
            date: (() => {
                if (appearancePage.cfg_dateFormat === "custom") {
                    return Qt.locale().toString(now, appearancePage.cfg_customDateFormat);
                } else if (appearancePage.cfg_dateFormat === "isoDate") {
                    return Qt.formatDate(now, Qt.ISODate);
                } else if (appearancePage.cfg_dateFormat === "longDate") {
                    return Qt.formatDate(now, Qt.locale(), Locale.LongFormat);
                }
                return Qt.formatDate(now, Qt.locale(), Locale.ShortFormat);
            })(),
        };
        const enabled = {
            time: appearancePage.cfg_showTime,
            day: appearancePage.cfg_showDay,
            date: appearancePage.cfg_showDate,
        };
        const order = String(appearancePage.cfg_segmentOrder || "date,time")
            .split(",")
            .map(s => s.trim().toLowerCase())
            .filter(s => s === "time" || s === "day" || s === "date");
        const parts = [];
        const seen = {};
        for (const token of order) {
            if (seen[token] || !enabled[token]) {
                continue;
            }
            seen[token] = true;
            parts.push(values[token]);
        }
        return parts.join(appearancePage.cfg_segmentSeparator);
    }

    Kirigami.FormLayout {

        RowLayout {
            Kirigami.FormData.label: i18n("Show:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.CheckBox {
                id: showTime
                text: i18n("Time")
            }
            QQC2.CheckBox {
                id: showDay
                text: i18n("Day")
            }
            QQC2.CheckBox {
                id: showDate
                text: i18n("Date")
            }
        }

        QQC2.ComboBox {
            id: dateDisplayFormat
            Kirigami.FormData.label: i18n("Layout:")
            visible: Plasmoid.formFactor !== PlasmaCore.Types.Vertical
            Layout.preferredWidth: appearancePage.comboBoxWidth
            model: [
                i18n("Adaptive / one line"),
                i18n("Always one line"),
                i18n("Stack below"),
            ]
            onActivated: appearancePage.cfg_dateDisplayFormat = currentIndex
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ComboBox {
            id: segmentOrderCombo
            Kirigami.FormData.label: i18n("Segment order:")
            Layout.preferredWidth: appearancePage.comboBoxWidth
            textRole: "label"
            model: appearancePage.orderPresets
            onActivated: {
                const value = model[currentIndex].value;
                if (value !== "custom") {
                    appearancePage.cfg_segmentOrder = value;
                    // Enabling Day when a preset includes it
                    if (value.indexOf("day") !== -1) {
                        appearancePage.cfg_showDay = true;
                    }
                }
            }
            Component.onCompleted: {
                const idx = model.findIndex(item => item.value === appearancePage.cfg_segmentOrder);
                currentIndex = idx === -1 ? model.length - 1 : idx;
            }
        }

        QQC2.TextField {
            id: customOrderField
            Kirigami.FormData.label: i18n("Custom order:")
            Layout.fillWidth: true
            visible: segmentOrderCombo.currentIndex === appearancePage.orderPresets.length - 1
                || appearancePage.orderPresets.findIndex(i => i.value === appearancePage.cfg_segmentOrder) === -1
            text: appearancePage.cfg_segmentOrder
            placeholderText: "time,day,date"
            onTextChanged: appearancePage.cfg_segmentOrder = text
        }

        QQC2.Label {
            visible: customOrderField.visible
            text: i18n("Tokens: time, day, date (comma-separated)")
            font: Kirigami.Theme.smallFont
            textFormat: Text.PlainText
        }

        QQC2.TextField {
            id: segmentSeparatorField
            Kirigami.FormData.label: i18n("Separator:")
            Layout.preferredWidth: appearancePage.comboBoxWidth
            placeholderText: " | "
        }

        QQC2.Label {
            Kirigami.FormData.label: i18n("Preview:")
            textFormat: Text.PlainText
            font.bold: true
            // Recompute when any input that affects the line changes
            text: {
                appearancePage.cfg_showTime;
                appearancePage.cfg_showDay;
                appearancePage.cfg_showDate;
                appearancePage.cfg_segmentOrder;
                appearancePage.cfg_segmentSeparator;
                appearancePage.cfg_dayFormat;
                appearancePage.cfg_dateFormat;
                appearancePage.cfg_customDateFormat;
                appearancePage.cfg_use24hFormat;
                return appearancePage.previewText();
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ComboBox {
            id: showSecondsComboBox
            Layout.preferredWidth: appearancePage.comboBoxWidth
            Kirigami.FormData.label: i18n("Show seconds:")
            model: [
                i18nc("@option:check", "Never"),
                i18nc("@option:check", "Only in the tooltip"),
                i18n("Always"),
            ]
            onActivated: appearancePage.cfg_showSeconds = currentIndex;
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Show time zone:")
            Kirigami.FormData.buddyFor: showLocalTimeZoneWhenDifferent
            spacing: Kirigami.Units.smallSpacing

            QQC2.RadioButton {
                id: showLocalTimeZoneWhenDifferent
                text: i18n("Only when different from local time zone")
            }

            QQC2.RadioButton {
                id: showLocalTimeZone
                text: i18n("Always")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Display time zone as:")
            Kirigami.FormData.buddyFor: displayTimeZoneFormat
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.ComboBox {
                id: displayTimeZoneFormat
                Layout.preferredWidth: appearancePage.comboBoxWidth
                model: [
                    i18n("Code"),
                    i18n("City"),
                    i18n("Offset from UTC time"),
                ]
                onActivated: appearancePage.cfg_displayTimezoneFormat = currentIndex
            }
            QQC2.Button {
                id: switchTimeZoneButton
                Layout.preferredWidth: Math.max(changeRegionalSettingsButton.implicitWidth, switchTimeZoneButton.implicitWidth)
                visible: KConfig.KAuthorized.authorizeControlModule("kcm_clock")
                text: i18nc("@action:button opens kcm", "Switch Time Zone…")
                icon.name: "preferences-system-time"
                onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_clock")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("@label:listbox", "Time display:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.ComboBox {
                id: use24hFormat
                Layout.preferredWidth: appearancePage.comboBoxWidth
                model: [
                    i18nc("@item:inlistbox time display option", "12-Hour"),
                    i18nc("@item:inlistbox time display option", "Use region defaults"),
                    i18nc("@item:inlistbox time display option", "24-Hour")
                ]
                onActivated: appearancePage.cfg_use24hFormat = currentIndex
            }

            QQC2.Button {
                id: changeRegionalSettingsButton
                visible: KConfig.KAuthorized.authorizeControlModule("kcm_regionandlang")
                Layout.preferredWidth: Math.max(changeRegionalSettingsButton.implicitWidth, switchTimeZoneButton.implicitWidth)
                text: i18nc("@action:button opens kcm", "Change Regional Settings…")
                icon.name: "preferences-desktop-locale"
                onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_regionandlang")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ComboBox {
            id: dayFormatCombo
            Kirigami.FormData.label: i18n("Day format:")
            enabled: showDay.checked
            Layout.preferredWidth: appearancePage.comboBoxWidth
            model: [
                { label: i18n("Short (Mon)"), name: "short" },
                { label: i18n("Long (Monday)"), name: "long" },
            ]
            textRole: "label"
            onActivated: appearancePage.cfg_dayFormat = model[currentIndex].name
            Component.onCompleted: {
                currentIndex = model.findIndex(item => item.name === appearancePage.cfg_dayFormat);
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18nc("@label:listbox", "Date format:")
            enabled: showDate.checked
            spacing: Kirigami.Units.smallSpacing

            QQC2.ComboBox {
                id: dateFormat
                Layout.preferredWidth: appearancePage.comboBoxWidth
                textRole: "label"
                model: [
                    {
                        label: i18nc("@item:inlistbox date display option, includes e.g. day of week and month as word", "Long date"),
                        name: "longDate",
                        formatter(d) {
                            return Qt.formatDate(d, Qt.locale(), Locale.LongFormat);
                        },
                    },
                    {
                        label: i18nc("@item:inlistbox date display option, e.g. all numeric", "Short date"),
                        name: "shortDate",
                        formatter(d) {
                            return Qt.formatDate(d, Qt.locale(), Locale.ShortFormat);
                        },
                    },
                    {
                        label: i18nc("@item:inlistbox date display option, yyyy-mm-dd", "ISO date"),
                        name: "isoDate",
                        formatter(d) {
                            return Qt.formatDate(d, Qt.ISODate);
                        },
                    },
                    {
                        label: i18nc("@item:inlistbox custom date format", "Custom"),
                        name: "custom",
                        formatter(d) {
                            return Qt.locale().toString(d, customDateFormat.text);
                        },
                    },
                ]
                onActivated: appearancePage.cfg_dateFormat = model[currentIndex]["name"];

                Component.onCompleted: {
                    const isConfiguredDateFormat = item => item["name"] === Plasmoid.configuration.dateFormat;
                    const idx = model.findIndex(isConfiguredDateFormat);
                    currentIndex = idx >= 0 ? idx : 0;
                }
            }

            QQC2.Label {
                Layout.preferredWidth: Math.max(changeRegionalSettingsButton.implicitWidth, switchTimeZoneButton.implicitWidth)
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.PlainText
                text: dateFormat.currentIndex >= 0
                    ? dateFormat.model[dateFormat.currentIndex].formatter(new Date())
                    : ""
            }
        }

        QQC2.TextField {
            id: customDateFormat
            Layout.fillWidth: true
            enabled: showDate.checked
            visible: appearancePage.cfg_dateFormat === "custom"
        }

        QQC2.Label {
            text: i18n("<a href=\"https://doc.qt.io/qt-6/qml-qtqml-qt.html#formatDateTime-method\">Time Format Documentation</a>")
            enabled: showDate.checked
            visible: appearancePage.cfg_dateFormat === "custom"
            wrapMode: Text.Wrap
            Layout.preferredWidth: Layout.maximumWidth
            Layout.maximumWidth: Kirigami.Units.gridUnit * 16
            HoverHandler {
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : undefined
            }
            onLinkActivated: link => Qt.openUrlExternally(link)
            textFormat: Text.StyledText
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ButtonGroup {
            buttons: [autoFontAndSizeRadioButton, manualFontAndSizeRadioButton]
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            Kirigami.FormData.label: i18nc("@label:group", "Text display:")
            Kirigami.FormData.buddyFor: autoFontAndSizeRadioButton

            QQC2.RadioButton {
                id: autoFontAndSizeRadioButton
                text: i18nc("@option:radio", "Automatic")
            }

            QQC2.Label {
                text: i18nc("@label", "Text will follow the system font and expand to fill the available space.")
                Layout.leftMargin: autoFontAndSizeRadioButton.indicator.width + autoFontAndSizeRadioButton.spacing
                textFormat: Text.PlainText
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font: Kirigami.Theme.smallFont
            }
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.RadioButton {
                id: manualFontAndSizeRadioButton
                text: i18nc("@option:radio setting for manually configuring the font settings", "Manual")
                checked: !appearancePage.cfg_autoFontAndSize
                onClicked: {
                    if (appearancePage.cfg_fontFamily === "") {
                        fontDialog.fontChosen = Kirigami.Theme.defaultFont
                    }
                }
            }

            QQC2.Button {
                text: i18nc("@action:button", "Choose Style…")
                icon.name: "settings-configure"
                enabled: manualFontAndSizeRadioButton.checked
                onClicked: {
                    fontDialog.currentFont = fontDialog.fontChosen
                    fontDialog.open()
                }
            }
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                visible: manualFontAndSizeRadioButton.checked
                Layout.leftMargin: manualFontAndSizeRadioButton.indicator.width + manualFontAndSizeRadioButton.spacing
                text: i18nc("@info %1 is the font size, %2 is the font family", "%1pt %2", cfg_fontSize, fontDialog.fontChosen.family)
                textFormat: Text.PlainText
                font: fontDialog.fontChosen
            }
            QQC2.Label {
                visible: manualFontAndSizeRadioButton.checked
                Layout.leftMargin: manualFontAndSizeRadioButton.indicator.width + manualFontAndSizeRadioButton.spacing
                text: i18nc("@info", "Note: size may be reduced if the panel is not thick enough.")
                textFormat: Text.PlainText
                font: Kirigami.Theme.smallFont
            }
        }
    }

    Platform.FontDialog {
        id: fontDialog
        title: i18nc("@title:window", "Choose a Font")
        modality: Qt.WindowModal
        parentWindow: appearancePage.Window.window

        property font fontChosen: null

        onAccepted: {
            fontChosen = font
        }
    }

    Component.onCompleted: {
        if (!Plasmoid.configuration.showLocalTimezone) {
            showLocalTimeZoneWhenDifferent.checked = true;
        }
    }
}
