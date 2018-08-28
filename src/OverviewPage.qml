﻿/* Copyright (C) 2018 Casper Meijn <casper@meijn.net>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import org.kde.kirigami 2.5 as Kirigami
import QtQml.Models 2.1
import QtQuick 2.9
import QtQuick.Controls 2.3 as Controls
import QtQuick.Layouts 1.3

Kirigami.ScrollablePage {
    id: pageOverview
    title: i18n("Overview")
    objectName: "overviewPage"

    actions {
        main: Kirigami.Action {
            iconName: "list-add"
            onTriggered: {
                selectedIndex = deviceManager.appendDevice()
                pageStack.push(settingsComponent);
            }
        }
    }

    Kirigami.CardsListView {
        id: view
        model: deviceManagerModel
        //        maximumColumnWidth: Kirigami.Units.gridUnit * 20

        delegate: Kirigami.AbstractCard {
            header: ColumnLayout {
                Kirigami.Heading {
                    level: 2
                    text: model.deviceName || i18n("Camera %1", model.index + 1)
                    Layout.fillWidth: true
                }
                Kirigami.Separator {
                    Layout.fillWidth: true
                }
            }
            //NOTE: never put a Layout as contentItem as it will cause binding loops
            //SEE: https://bugreports.qt.io/browse/QTBUG-66826
            contentItem: Item {
                implicitWidth: delegateLayout.implicitWidth
                implicitHeight: delegateLayout.implicitHeight
                GridLayout {
                    id: delegateLayout
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                    }
                    Controls.Label {
                        id: errorText
                        text: i18n("An error occurred during communication with the camera.")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: model.errorString
                        Layout.fillWidth: true
                    }

                    Controls.Label {
                        id: snapshotUnsupportedText
                        text: i18n("The camera doesn't support the retrieval of snapshots.")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: !model.errorString && !model.supportsSnapshotUri
                        Layout.fillWidth: true
                    }
                    OnvifCameraViewer {
                        id: viewerItem
                        snapshotUri: model.snapshotUri
                        snapshotInterval: 5000
                        visible: !model.errorString && model.supportsSnapshotUri
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.width / viewerItem.aspectRatio
                    }
                }
            }
            footer: Kirigami.ActionToolBar {
                id: actionsToolBar
                actions: [
                    Kirigami.Action {
                        iconName: "view-preview"
                        text: i18nc("Go to view a camera", "View")
                        onTriggered: {
                            selectedIndex = index
                            pageStack.pop(pageOverview);
                            pageStack.push(deviceViewerComponent);
                        }
                    },
                    Kirigami.Action {
                        iconName: "settings-configure"
                        text: i18nc("Go to settings of a camera", "Settings")
                        onTriggered: {
                            selectedIndex = index
                            pageStack.pop(pageOverview);
                            pageStack.push(settingsComponent);
                        }
                    }
                ]
            }
        }
    }
}
