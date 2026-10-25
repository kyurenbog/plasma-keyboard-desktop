# SPDX-License-Identifier: GPL-3.0-only
"""Generate the English and Russian desktop layouts into an explicit staging folder."""
from pathlib import Path
import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
root = parser.parse_args().output
for locale in ['fallback', 'ru_RU']:
    (root/locale).mkdir(parents=True, exist_ok=True)

def key(label, code, weight=100):
    return f'        PcKey {{ text: "{label}"; key: {code}; weight: {weight} }}\n'

for locale, letters in [('fallback', ['qwertyuiop', 'asdfghjkl', 'zxcvbnm']), ('ru_RU', ['йцукенгшщзхъ', 'фывапролджэ', 'ячсмитьбю'])]:
    qml = '''// Extended desktop layout; stock system files remain untouched.
import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Components
import QtQuick.Controls as QQC2
import org.kde.plasma.keyboard.lib as PlasmaKeyboard
import org.kde.kirigami as Kirigami

KeyboardLayout {
    id: desktopLayout
    keyWeight: 100
    property int latchedModifiers: 0
    component PcKey: Key {
        property string eventText: text
        noKeyEvent: true
        onClicked: {
            var mods = desktopLayout.latchedModifiers | (InputContext.uppercase ? Qt.ShiftModifier : 0)
            var value = InputContext.uppercase ? eventText.toUpperCase() : eventText
            if (key >= Qt.Key_Escape) value = ""
            InputContext.sendKeyClick(key, value, mods)
            desktopLayout.latchedModifiers = 0
        }
    }
    component ModifierKey: Key {
        property int modifierFlag
        noKeyEvent: true
        functionKey: true
        highlighted: (desktopLayout.latchedModifiers & modifierFlag) !== 0
        onClicked: desktopLayout.latchedModifiers ^= modifierFlag
        keyPanelDelegate: PlasmaKeyboard.BreezeKeyPanel {
            id: modifierPanel
            color: control && control.highlighted
                ? Kirigami.Theme.highlightColor
                : control && control.pressed
                    ? PlasmaKeyboard.BreezeConstants.normalKeyPressedBackgroundColor
                    : PlasmaKeyboard.BreezeConstants.normalKeyBackgroundColor
            Item {
                QQC2.Label {
                    anchors.centerIn: parent
                    text: modifierPanel.control ? modifierPanel.control.displayText : ""
                    color: modifierPanel.control && modifierPanel.control.highlighted
                        ? Kirigami.Theme.highlightedTextColor
                        : PlasmaKeyboard.BreezeConstants.keyTextColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: PlasmaKeyboard.BreezeConstants.fontFamily
                        weight: Font.Light
                        pixelSize: 60 * PlasmaKeyboard.BreezeConstants.scaleHint
                    }
                }
            }
        }
    }
    KeyboardRow {
'''
    qml += key('Esc','Qt.Key_Escape')
    for n in range(1,13): qml += key('F'+str(n),'Qt.Key_F'+str(n))
    qml += '    }\n'
    for i,row in enumerate(letters):
        qml += '    KeyboardRow {\n'
        if i==0: qml += key('Tab','Qt.Key_Tab',150)
        if i==1: qml += '        FillerKey { weight: 175 }\n'
        if i==2: qml += '        ShiftKey { weight: 225 }\n'
        for c in row:
            qml += key(c,str(ord(c.upper())))
        if i==0 and locale=='fallback':
            qml += key('[','Qt.Key_BracketLeft')+key(']','Qt.Key_BracketRight')
        if i==0: qml += key('Backspace','Qt.Key_Backspace',150)
        if i==1:
            if locale=='fallback': qml += key(';','Qt.Key_Semicolon')+key("'",'Qt.Key_Apostrophe')
            qml += key('Enter','Qt.Key_Return',225)
        if i==2:
            if locale=='fallback': qml += key(',','Qt.Key_Comma')+key('.','Qt.Key_Period')+key('/','Qt.Key_Slash')
            else: qml += key('.','Qt.Key_Period')
            # Scale the 1750-unit bottom row to this 1500-unit letter row.
            # Down starts at 1450; the letter block ends at 1225 here.
            qml += '        FillerKey { weight: 125 / 7 }\n'+key('↑','Qt.Key_Up','600 / 7')+'        FillerKey { weight: 1200 / 7 }\n'
        qml += '    }\n'
    qml += '''    KeyboardRow {
        ModifierKey { text: "Ctrl"; modifierFlag: Qt.ControlModifier }
        ModifierKey { text: "Alt"; modifierFlag: Qt.AltModifier }
        ModifierKey { text: "Meta"; modifierFlag: Qt.MetaModifier }
        SymbolModeKey { }
        ChangeLanguageKey { }
        PcKey { text: "Space"; eventText: " "; key: Qt.Key_Space; weight: 350 }
'''
    for label,code in [('Home','Home'),('End','End'),('PgUp','PageUp'),('PgDn','PageDown'),('Del','Delete'),('←','Left'),('↓','Down'),('→','Right')]:
        qml += key(label,'Qt.Key_'+code)
    qml += '        HideKeyboardKey { }\n    }\n}\n'
    (root/locale/'main.qml').write_text(qml, encoding='utf-8')
print('Generated:',root)
