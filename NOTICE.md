# Credits and licensing

- The C++ patch modifies KDE Plasma Keyboard **v6.7.5**. Original files retain their KDE/Qt copyright notices and GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL license choices. This project distributes its modifications under GPL-3.0-only.
- The layouts use Qt Virtual Keyboard's public QML components and follow the layouts shipped by KDE/Qt. Original Qt layouts credit The Qt Company Ltd. and are available under LicenseRef-Qt-Commercial OR GPL-3.0-only. This package uses the GPL-3.0-only option.
- `protocols/fake-input.xml` comes from KDE plasma-wayland-protocols. Copyright 2015 Martin Gräßlin, LGPL-2.1-or-later. Its original notice is preserved in the file. The supplied LGPL 2.1 text applies with the upstream "or later" option intact.
- The fake-input approach follows KDE Plasma Keyboard upstream's `KWinFakeInput` implementation by Devin Lin. The supplied patch adapts the mechanism to the v6.7.5 event handler and includes a serialized shortcut queue.

Upstream projects:

- https://invent.kde.org/plasma/plasma-keyboard
- https://invent.kde.org/libraries/plasma-wayland-protocols
- https://code.qt.io/cgit/qt/qtvirtualkeyboard.git/

No SSH settings, passwords, private keys, or machine-specific account details are needed for installation.
