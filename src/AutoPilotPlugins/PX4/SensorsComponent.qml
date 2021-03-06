/*=====================================================================

 QGroundControl Open Source Ground Control Station

 (c) 2009 - 2015 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>

 This file is part of the QGROUNDCONTROL project

 QGROUNDCONTROL is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 QGROUNDCONTROL is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with QGROUNDCONTROL. If not, see <http://www.gnu.org/licenses/>.

 ======================================================================*/

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    property QGCPalette qgcPal: QGCPalette { colorGroupEnabled: true }
    property ScreenTools screenTools: ScreenTools { }

    readonly property int rotationColumnWidth: 200
    readonly property var rotations: [
        "ROTATION_NONE",
        "ROTATION_YAW_45",
        "ROTATION_YAW_90",
        "ROTATION_YAW_135",
        "ROTATION_YAW_180",
        "ROTATION_YAW_225",
        "ROTATION_YAW_270",
        "ROTATION_YAW_315",
        "ROTATION_ROLL_180",
        "ROTATION_ROLL_180_YAW_45",
        "ROTATION_ROLL_180_YAW_90",
        "ROTATION_ROLL_180_YAW_135",
        "ROTATION_PITCH_180",
        "ROTATION_ROLL_180_YAW_225",
        "ROTATION_ROLL_180_YAW_270",
        "ROTATION_ROLL_180_YAW_315",
        "ROTATION_ROLL_90",
        "ROTATION_ROLL_90_YAW_45",
        "ROTATION_ROLL_90_YAW_90",
        "ROTATION_ROLL_90_YAW_135",
        "ROTATION_ROLL_270",
        "ROTATION_ROLL_270_YAW_45",
        "ROTATION_ROLL_270_YAW_90",
        "ROTATION_ROLL_270_YAW_135",
        "ROTATION_PITCH_90",
        "ROTATION_PITCH_270",
        "ROTATION_ROLL_270_YAW_270"
    ]

    color: qgcPal.window

    // We use this bogus loader just so we can get an onLoaded signal to hook to in order to
    // finish controller initialization.
    Component {
        id: loadSignal;
        Item { }
    }
    Loader {
        sourceComponent: loadSignal
        onLoaded: {
            controller.statusLog = statusTextArea
            controller.progressBar = progressBar
            controller.compassButton = compassButton
            controller.gyroButton = gyroButton
            controller.accelButton = accelButton
            controller.airspeedButton = airspeedButton
        }
    }

    Column {
        anchors.fill: parent

        QGCLabel {
            text: "SENSORS CONFIG"
            font.pointSize: screenTools.dpiAdjustedPointSize(20);
        }

        Item { height: 20; width: 10 } // spacer

        Row {
            readonly property int buttonWidth: 120

            spacing: 20

            QGCLabel { text: "Calibrate:"; anchors.baseline: compassButton.baseline }

            IndicatorButton {
                property Fact fact: Fact { name: "CAL_MAG0_ID" }

                id:             compassButton
                width:          parent.buttonWidth
                text:           "Compass"
                indicatorGreen: fact.value != 0
                onClicked: controller.calibrateCompass()
            }

            IndicatorButton {
                property Fact fact: Fact { name: "CAL_GYRO0_ID" }

                id:             gyroButton
                width:          parent.buttonWidth
                text:           "Gyroscope"
                indicatorGreen: fact.value != 0
                onClicked: controller.calibrateGyro()
            }

            IndicatorButton {
                property Fact fact: Fact { name: "CAL_ACC0_ID" }

                id:             accelButton
                width:          parent.buttonWidth
                text:           "Accelerometer"
                indicatorGreen: fact.value != 0
                onClicked: controller.calibrateAccel()
            }

            IndicatorButton {
                property Fact fact: Fact { name: "SENS_DPRES_OFF" }

                id:             airspeedButton
                width:          parent.buttonWidth
                text:           "Airspeed"
                visible:        controller.fixedWing
                indicatorGreen: fact.value != 0
                onClicked:      controller.calibrateAirspeed()
            }
        }

        Item { height: 20; width: 10 } // spacer

        ProgressBar {
            id: progressBar
            width: parent.width - rotationColumnWidth
        }

        Item { height: 10; width: 10 } // spacer

        Item {
            readonly property int calibrationAreaHeight: 300
            property int calDisplayAreaWidth: parent.width - rotationColumnWidth

            width:  parent.width
            height: parent.height - y

            TextArea {
                id:             statusTextArea
                width:          parent.calDisplayAreaWidth
                height:         parent.height
                readOnly:       true
                frameVisible:   false
                text:           "Sensor config is a work in progress. Not all visuals for all calibration types fully implemented.\n\n" +
                                "For Compass calibration you will need to rotate your vehicle through a number of positions. For this calibration is is best " +
                                "to be connected to you vehicle via radio instead of USB since the USB cable will likely get in the way.\n\n" +
                                "For Gyroscope calibration you will need to place your vehicle right side up on solid surface and leave it still.\n\n" +
                                "For Accelerometer calibration you will need to place your vehicle on all six sides and hold it there for a few seconds.\n\n" +
                                "For Airspeed calibration you will need to keep your airspeed sensor out of any wind.\n\n"

                style: TextAreaStyle {
                    textColor: qgcPal.text
                    backgroundColor: qgcPal.windowShade
                }
            }

            Rectangle {
                id:         gyroCalArea
                width:      parent.calDisplayAreaWidth
                height:     parent.height
                visible:    controller.showGyroCalArea
                color:      qgcPal.windowShade

                Column {
                    width: parent.width

                    QGCLabel {
                        text: "Place your vehicle upright on a solid surface and hold it still."
                    }

                    VehicleRotationCal {
                        calValid:       true
                        calInProgress:  controller.gyroCalInProgress
                        imageSource:    "qrc:///qml/VehicleDown.png"
                    }

                }
            }

            Rectangle {
                id:         orientationCalArea
                width:      parent.calDisplayAreaWidth
                height:     parent.height
                visible:    controller.showOrientationCalArea
                color:      qgcPal.windowShade

                QGCLabel {
                    id:         calAreaLabel
                    width:      parent.width
                    wrapMode:   Text.WordWrap

                    text: "Place your vehicle into each of the positions below and hold still. Once that position is completed you can move to another."
                }

                Flow {
                    y:          calAreaLabel.height
                    width:      parent.width
                    height:     parent.height - calAreaLabel.implicitHeight
                    spacing:    5

                    VehicleRotationCal {
                        calValid:           controller.orientationCalDownSideDone
                        calInProgress:      controller.orientationCalDownSideInProgress
                        calInProgressText:  controller.calInProgressText
                        imageSource:        "qrc:///qml/VehicleDown.png"
                    }
                    VehicleRotationCal {
                        calValid:           controller.orientationCalUpsideDownSideDone
                        calInProgress:      controller.orientationCalUpsideDownSideInProgress
                        calInProgressText:  controller.calInProgressText
                        imageSource:        "qrc:///qml/VehicleUpsideDown.png"
                    }
                    VehicleRotationCal {
                        calValid:           controller.orientationCalNoseDownSideDone
                        calInProgress:      controller.orientationCalNoseDownSideInProgress
                        calInProgressText:  controller.calInProgressText
                        imageSource:        "qrc:///qml/VehicleNoseDown.png"
                    }
                    VehicleRotationCal {
                        calValid:           controller.orientationCalTailDownSideDone
                        calInProgress:      controller.orientationCalTailDownSideInProgress
                        calInProgressText:  controller.calInProgressText
                        imageSource:        "qrc:///qml/VehicleTailDown.png"
                    }
                    VehicleRotationCal {
                        calValid:           controller.orientationCalLeftSideDone
                        calInProgress:      controller.orientationCalLeftSideInProgress
                        calInProgressText:  controller.calInProgressText
                        imageSource:        "qrc:///qml/VehicleLeft.png"
                    }
                    VehicleRotationCal {
                        calValid:           controller.orientationCalRightSideDone
                        calInProgress:      controller.orientationCalRightSideInProgress
                        calInProgressText:  controller.calInProgressText
                        imageSource:        "qrc:///qml/VehicleRight.png"
                    }
                }
            }

            Column {
                x: parent.width - rotationColumnWidth

                QGCLabel { text: "Autpilot Orientation" }

                FactComboBox {
                    id:     boardRotationCombo
                    width:  rotationColumnWidth;
                    model:  rotations
                    fact:   Fact { name: "SENS_BOARD_ROT" }
                }

                // Compass 0 rotation
                Component {
                    id: compass0ComponentLabel

                    QGCLabel { text: "Compass Orientation" }
                }
                Component {
                    id: compass0ComponentCombo

                    FactComboBox {
                        id:     compass0RotationCombo
                        width:  rotationColumnWidth
                        model:  rotations
                        fact:   Fact { name: "CAL_MAG0_ROT" }
                    }
                }
                Loader { sourceComponent: controller.showCompass0 ? compass0ComponentLabel : null }
                Loader { sourceComponent: controller.showCompass0 ? compass0ComponentCombo : null }

                // Compass 1 rotation
                Component {
                    id: compass1ComponentLabel

                    QGCLabel { text: "Compass 1 Orientation" }
                }
                Component {
                    id: compass1ComponentCombo

                    FactComboBox {
                        id:     compass1RotationCombo
                        width:  rotationColumnWidth
                        model:  rotations
                        fact:   Fact { name: "CAL_MAG1_ROT" }
                    }
                }
                Loader { sourceComponent: controller.showCompass1 ? compass1ComponentLabel : null }
                Loader { sourceComponent: controller.showCompass1 ? compass1ComponentCombo : null }

                // Compass 2 rotation
                Component {
                    id: compass2ComponentLabel

                    QGCLabel { text: "Compass 2 Orientation" }
                }
                Component {
                    id: compass2ComponentCombo

                    FactComboBox {
                        id:     compass1RotationCombo
                        width:  rotationColumnWidth
                        model:  rotations
                        fact:   Fact { name: "CAL_MAG2_ROT" }
                    }
                }
                Loader { sourceComponent: controller.showCompass2 ? compass2ComponentLabel : null }
                Loader { sourceComponent: controller.showCompass2 ? compass2ComponentCombo : null }
            }
        }
    }
}

