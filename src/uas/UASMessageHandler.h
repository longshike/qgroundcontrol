/*=====================================================================

QGroundControl Open Source Ground Control Station

(c) 2009 - 2011 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>

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

/*!
 * @file
 *   @brief Message Handler
 *   @author Gus Grubba <mavlink@grubba.com>
 */

#ifndef QGCMESSAGEHANDLER_H
#define QGCMESSAGEHANDLER_H

#include <QObject>
#include <QVector>
#include <QMutex>

#include "QGCSingleton.h"

class UASInterface;
class UASMessageHandler;

/*!
 * @class UASMessage
 * @brief Message element
 */
class UASMessage
{
    friend class UASMessageHandler;
public:
    /**
     * @brief Get message source component ID
     */
    int getComponentID()        { return _compId; }
    /**
     * @brief Get message severity (from MAV_SEVERITY_XXX enum)
     */
    int getSeverity()           { return _severity; }
    /**
     * @brief Get message text (e.g. "[pm] sending list")
     */
    QString getText()           { return _text; }
    /**
     * @brief Get (html) formatted text (in the form: "[11:44:21.137 - COMP:50] Info: [pm] sending list")
     */
    QString getFormatedText()   { return _formatedText; }
private:
    UASMessage(int componentid, int severity, QString text);
    void _setFormatedText(const QString formatedText) { _formatedText = formatedText; }
    int _compId;
    int _severity;
    QString _text;
    QString _formatedText;
};

class UASMessageHandler : public QGCSingleton
{
    Q_OBJECT
    DECLARE_QGC_SINGLETON(UASMessageHandler, UASMessageHandler)
public:
    explicit UASMessageHandler(QObject *parent = 0);
    ~UASMessageHandler();
    /**
     * @brief Locks access to the message list
     */
    void lockAccess()   {_mutex.lock(); }
    /**
     * @brief Unlocks access to the message list
     */
    void unlockAccess() {_mutex.unlock(); }
    /**
     * @brief Access to the message list
     */
    const QVector<UASMessage*>& messages() { return _messages; }
    /**
     * @brief Clear messages
     */
    void clearMessages();
    /**
     * @brief Get error message count (Resets count once read)
     */
    int getErrorCount();
    /**
     * @brief Get warning message count (Resets count once read)
     */
    int getWarningCount();
    /**
     * @brief Get normal message count (Resets count once read)
     */
    int getNormalCount();
public slots:
    /**
     * @brief Set currently active UAS
     * @param uas The current active UAS
     */
    void setActiveUAS(UASInterface* uas);
    /**
     * @brief Handle text message from current active UAS
     * @param uasid UAS Id
     * @param componentid Component Id
     * @param severity Message severity
     * @param text Message Text
     */
    void handleTextMessage(int uasid, int componentid, int severity, QString text);
signals:
    /**
     * @brief Sent out when new message arrives
     * @param message A pointer to the message. NULL if resetting (new UAS assigned)
     */
    void textMessageReceived(UASMessage* message);
    /**
     * @brief Sent out when the message count changes
     * @param count The new message count
     */
    void textMessageCountChanged(int count);
private:
    // Stores the UAS that we're currently receiving messages from.
    UASInterface* _activeUAS;
    QVector<UASMessage*> _messages;
    QMutex _mutex;
    int _errorCount;
    int _warningCount;
    int _normalCount;
};

#endif // QGCMESSAGEHANDLER_H
