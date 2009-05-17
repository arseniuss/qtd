/****************************************************************************
**
** Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies).
** Contact: Qt Software Information (qt-info@nokia.com)
**
** This file is part of the demonstration applications of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial Usage
** Licensees holding valid Qt Commercial licenses may use this file in
** accordance with the Qt Commercial License Agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Nokia.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain
** additional rights. These rights are described in the Nokia Qt LGPL
** Exception version 1.0, included in the file LGPL_EXCEPTION.txt in this
** package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
** If you are unsure which license is appropriate for your use, please
** contact the sales department at qt-sales@nokia.com.
** $QT_END_LICENSE$
**
****************************************************************************/
module cookiejar;

import QtNetwork.QNetworkCookieJar;

import QtCore.QAbstractItemModel;
import QtCore.QStringList;

import QtGui.QDialog;
import QtGui.QTableView;


#include "cookiejar.h"

#include "autosaver.h"

import QtCore.QDateTime;
import QtCore.QDir;
import QtCore.QFile;
import QtCore.QMetaEnum;
import QtCore.QSettings;
import QtCore.QUrl;

import QtGui.QCompleter;
import QtGui.QDesktopServices;
import QtGui.QFont;
import QtGui.QFontMetrics;
import QtGui.QHeaderView;
import QtGui.QKeyEvent;
import QtGui.QSortFilterProxyModel;

import QtWebKit.QWebSettings;

import QtCore.QDebug;

/*
QT_BEGIN_NAMESPACE
class QSortFilterProxyModel;
class QKeyEvent;
QT_END_NAMESPACE

class AutoSaver;
*/

static const unsigned int JAR_VERSION = 23;

QDataStream &operator<<(QDataStream &stream, const QList<QNetworkCookie> &list)
{
    stream << JAR_VERSION;
    stream << quint32(list.size());
    for (int i = 0; i < list.size(); ++i)
        stream << list.at(i).toRawForm();
    return stream;
}

QDataStream &operator>>(QDataStream &stream, QList<QNetworkCookie> &list)
{
    list.clear();

    quint32 version;
    stream >> version;

    if (version != JAR_VERSION)
        return stream;

    quint32 count;
    stream >> count;
    for(quint32 i = 0; i < count; ++i)
    {
        QByteArray value;
        stream >> value;
        QList<QNetworkCookie> newCookies = QNetworkCookie::parseCookies(value);
        if (newCookies.count() == 0 && value.length() != 0) {
            qWarning() << "CookieJar: Unable to parse saved cookie:" << value;
        }
        for (int j = 0; j < newCookies.count(); ++j)
            list.append(newCookies.at(j));
        if (stream.atEnd())
            break;
    }
    return stream;
}


class CookieJar : public QNetworkCookieJar
{
    friend class CookieModel;
    Q_OBJECT
    Q_PROPERTY(AcceptPolicy acceptPolicy READ acceptPolicy WRITE setAcceptPolicy)
    Q_PROPERTY(KeepPolicy keepPolicy READ keepPolicy WRITE setKeepPolicy)
    Q_PROPERTY(QStringList blockedCookies READ blockedCookies WRITE setBlockedCookies)
    Q_PROPERTY(QStringList allowedCookies READ allowedCookies WRITE setAllowedCookies)
    Q_PROPERTY(QStringList allowForSessionCookies READ allowForSessionCookies WRITE setAllowForSessionCookies)
    Q_ENUMS(KeepPolicy)
    Q_ENUMS(AcceptPolicy)

signals:
    void cookiesChanged();

public:
	enum AcceptPolicy {
		AcceptAlways,
		AcceptNever,
		AcceptOnlyFromSitesNavigatedTo
	};

	enum KeepPolicy {
		KeepUntilExpire,
		KeepUntilExit,
		KeepUntilTimeLimit
	};

	this(QObject *parent = null)
	{
		super(parent);
		m_loaded = false;
		m_saveTimer = new AutoSaver(this);
		m_acceptCookies = AcceptOnlyFromSitesNavigatedTo;
	}
    
	~this()
	{
		if (m_keepCookies == KeepUntilExit)
			clear();
		m_saveTimer.saveIfNeccessary();
	}

    QList<QNetworkCookie> cookiesForUrl(const QUrl &url)
{
    CookieJar *that = const_cast<CookieJar*>(this);
    if (!m_loaded)
        that.load();

    QWebSettings *globalSettings = QWebSettings::globalSettings();
    if (globalSettings.testAttribute(QWebSettings::PrivateBrowsingEnabled)) {
        QList<QNetworkCookie> noCookies;
        return noCookies;
    }

    return QNetworkCookieJar::cookiesForUrl(url);
}
    
    
    bool setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
    if (!m_loaded)
        load();

    QWebSettings *globalSettings = QWebSettings::globalSettings();
    if (globalSettings.testAttribute(QWebSettings::PrivateBrowsingEnabled))
        return false;

    QString host = url.host();
    bool eBlock = qBinaryFind(m_exceptions_block.begin(), m_exceptions_block.end(), host) != m_exceptions_block.end();
    bool eAllow = qBinaryFind(m_exceptions_allow.begin(), m_exceptions_allow.end(), host) != m_exceptions_allow.end();
    bool eAllowSession = qBinaryFind(m_exceptions_allowForSession.begin(), m_exceptions_allowForSession.end(), host) != m_exceptions_allowForSession.end();

    bool addedCookies = false;
    // pass exceptions
    bool acceptInitially = (m_acceptCookies != AcceptNever);
    if ((acceptInitially && !eBlock)
        || (!acceptInitially && (eAllow || eAllowSession))) {
        // pass url domain == cookie domain
        QDateTime soon = QDateTime::currentDateTime();
        soon = soon.addDays(90);
        foreach(QNetworkCookie cookie, cookieList) {
            QList<QNetworkCookie> lst;
            if (m_keepCookies == KeepUntilTimeLimit
                && !cookie.isSessionCookie()
                && cookie.expirationDate() > soon) {
                    cookie.setExpirationDate(soon);
            }
            lst += cookie;
            if (QNetworkCookieJar::setCookiesFromUrl(lst, url)) {
                addedCookies = true;
            } else {
                // finally force it in if wanted
                if (m_acceptCookies == AcceptAlways) {
                    QList<QNetworkCookie> cookies = allCookies();
                    cookies += cookie;
                    setAllCookies(cookies);
                    addedCookies = true;
                }
#if 0
                else
                    qWarning() << "setCookiesFromUrl failed" << url << cookieList.value(0).toRawForm();
#endif
            }
        }
    }

    if (addedCookies) {
        m_saveTimer.changeOccurred();
        emit cookiesChanged();
    }
    return addedCookies;
}

	AcceptPolicy acceptPolicy()
	{
		if (!m_loaded)
			(const_cast<CookieJar*>(this)).load();
		return m_acceptCookies;
	}
    
	void setAcceptPolicy(AcceptPolicy policy)
	{
		if (!m_loaded)
			load();
		if (policy == m_acceptCookies)
			return;
		m_acceptCookies = policy;
		m_saveTimer.changeOccurred();
	}

	KeepPolicy keepPolicy()
	{
		if (!m_loaded)
			(const_cast<CookieJar*>(this)).load();
		return m_keepCookies;
	}

	void setKeepPolicy(KeepPolicy policy)
	{
		if (!m_loaded)
			load();
		if (policy == m_keepCookies)
			return;
		m_keepCookies = policy;
		m_saveTimer.changeOccurred();
	}


	QStringList blockedCookies()
	{
		if (!m_loaded)
			(const_cast<CookieJar*>(this)).load();
		return m_exceptions_block;
	}

	QStringList allowedCookies()
	{
		if (!m_loaded)
			(const_cast<CookieJar*>(this)).load();
		return m_exceptions_allow;
	}
    
	QStringList allowForSessionCookies()
	{
		if (!m_loaded)
			(const_cast<CookieJar*>(this)).load();
		return m_exceptions_allowForSession;
	}

	void setBlockedCookies(const QStringList &list)
	{
		if (!m_loaded)
			load();
		m_exceptions_block = list;
		qSort(m_exceptions_block.begin(), m_exceptions_block.end());
		m_saveTimer.changeOccurred();
	}
    
	void setAllowedCookies(const QStringList &list)
	{
		if (!m_loaded)
			load();
		m_exceptions_allow = list;
		qSort(m_exceptions_allow.begin(), m_exceptions_allow.end());
		m_saveTimer.changeOccurred();
	}
    
	void setAllowForSessionCookies(const QStringList &list)
	{
		if (!m_loaded)
			load();
		m_exceptions_allowForSession = list;
		qSort(m_exceptions_allowForSession.begin(), m_exceptions_allowForSession.end());
		m_saveTimer.changeOccurred();
	}

public slots:

	void clear()
	{
		setAllCookies(QList<QNetworkCookie>());
		m_saveTimer.changeOccurred();
		emit cookiesChanged();
	}

	void loadSettings()
	{
		QSettings settings;
		settings.beginGroup(QLatin1String("cookies"));
		QByteArray value = settings.value(QLatin1String("acceptCookies"),
				QLatin1String("AcceptOnlyFromSitesNavigatedTo")).toByteArray();
		QMetaEnum acceptPolicyEnum = staticMetaObject.enumerator(staticMetaObject.indexOfEnumerator("AcceptPolicy"));
		m_acceptCookies = acceptPolicyEnum.keyToValue(value) == -1 ?
				AcceptOnlyFromSitesNavigatedTo :
				static_cast<AcceptPolicy>(acceptPolicyEnum.keyToValue(value));

		value = settings.value(QLatin1String("keepCookiesUntil"), QLatin1String("KeepUntilExpire")).toByteArray();
		QMetaEnum keepPolicyEnum = staticMetaObject.enumerator(staticMetaObject.indexOfEnumerator("KeepPolicy"));
		m_keepCookies = keepPolicyEnum.keyToValue(value) == -1 ?
				KeepUntilExpire :
				static_cast<KeepPolicy>(keepPolicyEnum.keyToValue(value));

		if (m_keepCookies == KeepUntilExit)
		setAllCookies(QList<QNetworkCookie>());

		m_loaded = true;
		emit cookiesChanged();
	}

private slots:
void save()
{
    if (!m_loaded)
        return;
    purgeOldCookies();
    QString directory = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
    if (directory.isEmpty())
        directory = QDir::homePath() + QLatin1String("/.") + QCoreApplication::applicationName();
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }
    QSettings cookieSettings(directory + QLatin1String("/cookies.ini"), QSettings::IniFormat);
    QList<QNetworkCookie> cookies = allCookies();
    for (int i = cookies.count() - 1; i >= 0; --i) {
        if (cookies.at(i).isSessionCookie())
            cookies.removeAt(i);
    }
    cookieSettings.setValue(QLatin1String("cookies"), qVariantFromValue<QList<QNetworkCookie> >(cookies));
    cookieSettings.beginGroup(QLatin1String("Exceptions"));
    cookieSettings.setValue(QLatin1String("block"), m_exceptions_block);
    cookieSettings.setValue(QLatin1String("allow"), m_exceptions_allow);
    cookieSettings.setValue(QLatin1String("allowForSession"), m_exceptions_allowForSession);

    // save cookie settings
    QSettings settings;
    settings.beginGroup(QLatin1String("cookies"));
    QMetaEnum acceptPolicyEnum = staticMetaObject.enumerator(staticMetaObject.indexOfEnumerator("AcceptPolicy"));
    settings.setValue(QLatin1String("acceptCookies"), QLatin1String(acceptPolicyEnum.valueToKey(m_acceptCookies)));

    QMetaEnum keepPolicyEnum = staticMetaObject.enumerator(staticMetaObject.indexOfEnumerator("KeepPolicy"));
    settings.setValue(QLatin1String("keepCookiesUntil"), QLatin1String(keepPolicyEnum.valueToKey(m_keepCookies)));
}

private:
    void purgeOldCookies()
{
    QList<QNetworkCookie> cookies = allCookies();
    if (cookies.isEmpty())
        return;
    int oldCount = cookies.count();
    QDateTime now = QDateTime::currentDateTime();
    for (int i = cookies.count() - 1; i >= 0; --i) {
        if (!cookies.at(i).isSessionCookie() && cookies.at(i).expirationDate() < now)
            cookies.removeAt(i);
    }
    if (oldCount == cookies.count())
        return;
    setAllCookies(cookies);
    emit cookiesChanged();
}

	void load()
	{
		if (m_loaded)
			return;
		// load cookies and exceptions
		qRegisterMetaTypeStreamOperators<QList<QNetworkCookie> >("QList<QNetworkCookie>");
		QSettings cookieSettings(QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QLatin1String("/cookies.ini"), QSettings::IniFormat);
		setAllCookies(qvariant_cast<QList<QNetworkCookie> >(cookieSettings.value(QLatin1String("cookies"))));
		cookieSettings.beginGroup(QLatin1String("Exceptions"));
		m_exceptions_block = cookieSettings.value(QLatin1String("block")).toStringList();
		m_exceptions_allow = cookieSettings.value(QLatin1String("allow")).toStringList();
		m_exceptions_allowForSession = cookieSettings.value(QLatin1String("allowForSession")).toStringList();
		qSort(m_exceptions_block.begin(), m_exceptions_block.end());
		qSort(m_exceptions_allow.begin(), m_exceptions_allow.end());
		qSort(m_exceptions_allowForSession.begin(), m_exceptions_allowForSession.end());

		loadSettings();
	}

	bool m_loaded;
	AutoSaver *m_saveTimer;

	AcceptPolicy m_acceptCookies;
	KeepPolicy m_keepCookies;

	QStringList m_exceptions_block;
	QStringList m_exceptions_allow;
	QStringList m_exceptions_allowForSession;
}

class CookieModel : public QAbstractTableModel
{
    Q_OBJECT

public:
	this(CookieJar *jar, QObject *parent = null	)
	{
		super(parent);
		m_cookieJar = cookieJar;
		connect(m_cookieJar, SIGNAL(cookiesChanged()), this, SLOT(cookiesChanged()));
		m_cookieJar.load();
	}

QVariant headerData(int section, Qt.Orientation orientation, int role)
{
    if (role == Qt.SizeHintRole) {
        QFont font;
        font.setPointSize(10);
        QFontMetrics fm(font);
        int height = fm.height() + fm.height()/3;
        int width = fm.width(headerData(section, orientation, Qt.DisplayRole).toString());
        return QSize(width, height);
    }

    if (orientation == Qt.Horizontal) {
        if (role != Qt.DisplayRole)
            return QVariant();

        switch (section) {
            case 0:
                return tr("Website");
            case 1:
                return tr("Name");
            case 2:
                return tr("Path");
            case 3:
                return tr("Secure");
            case 4:
                return tr("Expires");
            case 5:
                return tr("Contents");
            default:
                return QVariant();
        }
    }
    return QAbstractTableModel.headerData(section, orientation, role);
}


	QVariant data(const QModelIndex &index, int role = Qt.DisplayRole)
	{
		QList<QNetworkCookie> lst;
		if (m_cookieJar)
		lst = m_cookieJar.allCookies();
		if (index.row() < 0 || index.row() >= lst.size())
		return QVariant();

		switch (role) {
			case Qt.DisplayRole:
			case Qt.EditRole: {
			QNetworkCookie cookie = lst.at(index.row());
				switch (index.column()) {
				    case 0:
					return cookie.domain();
				    case 1:
					return cookie.name();
				    case 2:
					return cookie.path();
				    case 3:
					return cookie.isSecure();
				    case 4:
					return cookie.expirationDate();
				    case 5:
					return cookie.value();
				}
			}
			case Qt.FontRole:{
				QFont font;
				font.setPointSize(10);
				return font;
			}
		}

		return QVariant();
	}

	int columnCount(const QModelIndex &parent = QModelIndex())
	{
		return (parent.isValid()) ? 0 : 6;
	}


	int rowCount(const QModelIndex &parent = QModelIndex())
	{
		return (parent.isValid() || !m_cookieJar) ? 0 : m_cookieJar.allCookies().count();
	}


	bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex())
	{
		if (parent.isValid() || !m_cookieJar)
			return false;
		int lastRow = row + count - 1;
		beginRemoveRows(parent, row, lastRow);
		QList<QNetworkCookie> lst = m_cookieJar.allCookies();
		for (int i = lastRow; i >= row; --i) {
			lst.removeAt(i);
		}
		m_cookieJar.setAllCookies(lst);
		endRemoveRows();
		return true;
	}

private slots:
	
	void cookiesChanged()
	{
		reset();
	}

private:
	CookieJar *m_cookieJar;
}

#include "ui_cookies.h"
#include "ui_cookiesexceptions.h"

class CookiesDialog : public QDialog, public Ui_CookiesDialog
{
    Q_OBJECT

public:

	this(CookieJar *cookieJar, QWidget *parent = this) : QDialog(parent)
	{
		setupUi(this);
		setWindowFlags(Qt.Sheet);
		CookieModel *model = new CookieModel(cookieJar, this);
		m_proxyModel = new QSortFilterProxyModel(this);
		connect(search, SIGNAL(textChanged(QString)),
		    m_proxyModel, SLOT(setFilterFixedString(QString)));
		connect(removeButton, SIGNAL(clicked()), cookiesTable, SLOT(removeOne()));
		connect(removeAllButton, SIGNAL(clicked()), cookiesTable, SLOT(removeAll()));
		m_proxyModel.setSourceModel(model);
		cookiesTable.verticalHeader().hide();
		cookiesTable.setSelectionBehavior(QAbstractItemView::SelectRows);
		cookiesTable.setModel(m_proxyModel);
		cookiesTable.setAlternatingRowColors(true);
		cookiesTable.setTextElideMode(Qt.ElideMiddle);
		cookiesTable.setShowGrid(false);
		cookiesTable.setSortingEnabled(true);
		QFont f = font();
		f.setPointSize(10);
		QFontMetrics fm(f);
		int height = fm.height() + fm.height()/3;
		cookiesTable.verticalHeader().setDefaultSectionSize(height);
		cookiesTable.verticalHeader().setMinimumSectionSize(-1);
		for (int i = 0; i < model.columnCount(); ++i){
			int header = cookiesTable.horizontalHeader().sectionSizeHint(i);
			switch (i) {
				case 0:
					header = fm.width(QLatin1String("averagehost.domain.com"));
					break;
				case 1:
					header = fm.width(QLatin1String("_session_id"));
					break;
				case 4:
					header = fm.width(QDateTime::currentDateTime().toString(Qt.LocalDate));
					break;
			}
			int buffer = fm.width(QLatin1String("xx"));
			header += buffer;
			cookiesTable.horizontalHeader().resizeSection(i, header);
		}
		cookiesTable.horizontalHeader().setStretchLastSection(true);
	}
	
private:

	QSortFilterProxyModel *m_proxyModel;
}

class CookieExceptionsModel : public QAbstractTableModel
{
    Q_OBJECT
    friend class CookiesExceptionsDialog;

public:
	zhis(CookieJar *cookieJar, QObject *parent = null)
	{
		super(parent);
		m_cookieJar = cookiejar;
		m_allowedCookies = m_cookieJar.allowedCookies();
		m_blockedCookies = m_cookieJar.blockedCookies();
		m_sessionCookies = m_cookieJar.allowForSessionCookies();
	}

	QVariant headerData(int section, Qt.Orientation orientation, int role)
	{
		if (role == Qt.SizeHintRole) {
			QFont font;
			font.setPointSize(10);
			QFontMetrics fm(font);
			int height = fm.height() + fm.height()/3;
			int width = fm.width(headerData(section, orientation, Qt.DisplayRole).toString());
			return QSize(width, height);
		}

		if (orientation == Qt.Horizontal && role == Qt.DisplayRole) {
			switch (section) {
				case 0:
					return tr("Website");
				case 1:
					return tr("Status");
			}
		}
		return QAbstractTableModel::headerData(section, orientation, role);
	}



	QVariant data(const QModelIndex &index, int role = Qt.DisplayRole)
	{
		if (index.row() < 0 || index.row() >= rowCount())
		return QVariant();

		switch (role) {
			case Qt.DisplayRole:
			case Qt.EditRole: {
			int row = index.row();
			if (row < m_allowedCookies.count()) {
			    switch (index.column()) {
				case 0:
				    return m_allowedCookies.at(row);
				case 1:
				    return tr("Allow");
			    }
			}
			row = row - m_allowedCookies.count();
			if (row < m_blockedCookies.count()) {
			    switch (index.column()) {
				case 0:
				    return m_blockedCookies.at(row);
				case 1:
				    return tr("Block");
			    }
			}
			row = row - m_blockedCookies.count();
			if (row < m_sessionCookies.count()) {
				switch (index.column()) {
					case 0:
						return m_sessionCookies.at(row);
					case 1:
						return tr("Allow For Session");
				}
			}
			}
			case Qt.FontRole:{
			QFont font;
			font.setPointSize(10);
			return font;
			}
		}
		return QVariant();
	}

	int columnCount(const QModelIndex &parent = QModelIndex());
	{
		return (parent.isValid()) ? 0 : 2;
	}
	
	int rowCount(const QModelIndex &parent = QModelIndex())
	{
		return (parent.isValid() || !m_cookieJar) ? 0 : m_allowedCookies.count() + m_blockedCookies.count() + m_sessionCookies.count();
	}

	bool removeRows(int row, int count, const QModelIndex &parent)
	{
		if (parent.isValid() || !m_cookieJar)
			return false;

		int lastRow = row + count - 1;
		beginRemoveRows(parent, row, lastRow);
		for (int i = lastRow; i >= row; --i) {
			if (i < m_allowedCookies.count()) {
				m_allowedCookies.removeAt(row);
				continue;
			}
			i = i - m_allowedCookies.count();
			if (i < m_blockedCookies.count()) {
				m_blockedCookies.removeAt(row);
				continue;
			}
			i = i - m_blockedCookies.count();
			if (i < m_sessionCookies.count()) {
				m_sessionCookies.removeAt(row);
				continue;
			}
		}
		
		m_cookieJar.setAllowedCookies(m_allowedCookies);
		m_cookieJar.setBlockedCookies(m_blockedCookies);
		m_cookieJar.setAllowForSessionCookies(m_sessionCookies);
		endRemoveRows();
		return true;
	}
private:
	CookieJar *m_cookieJar;

	// Domains we allow, Domains we block, Domains we allow for this session
	QStringList m_allowedCookies;
	QStringList m_blockedCookies;
	QStringList m_sessionCookies;
}

class CookiesExceptionsDialog : public QDialog, public Ui_CookiesExceptionsDialog
{
    Q_OBJECT

public:
	this(CookieJar *cookieJar, QWidget *parent = null)
	: QDialog(parent)
	{
		m_cookieJar = cookieJar;
		setupUi(this);
		setWindowFlags(Qt.Sheet);
		connect(removeButton, SIGNAL(clicked()), exceptionTable, SLOT(removeOne()));
		connect(removeAllButton, SIGNAL(clicked()), exceptionTable, SLOT(removeAll()));
		exceptionTable.verticalHeader().hide();
		exceptionTable.setSelectionBehavior(QAbstractItemView::SelectRows);
		exceptionTable.setAlternatingRowColors(true);
		exceptionTable.setTextElideMode(Qt.ElideMiddle);
		exceptionTable.setShowGrid(false);
		exceptionTable.setSortingEnabled(true);
		m_exceptionsModel = new CookieExceptionsModel(cookieJar, this);
		m_proxyModel = new QSortFilterProxyModel(this);
		m_proxyModel.setSourceModel(m_exceptionsModel);
		connect(search, SIGNAL(textChanged(QString)),
		m_proxyModel, SLOT(setFilterFixedString(QString)));
		exceptionTable.setModel(m_proxyModel);

		CookieModel *cookieModel = new CookieModel(cookieJar, this);
		domainLineEdit.setCompleter(new QCompleter(cookieModel, domainLineEdit));

		connect(domainLineEdit, SIGNAL(textChanged(const QString &)),
		this, SLOT(textChanged(const QString &)));
		connect(blockButton, SIGNAL(clicked()), this, SLOT(block()));
		connect(allowButton, SIGNAL(clicked()), this, SLOT(allow()));
		connect(allowForSessionButton, SIGNAL(clicked()), this, SLOT(allowForSession()));

		QFont f = font();
		f.setPointSize(10);
		QFontMetrics fm(f);
		int height = fm.height() + fm.height()/3;
		exceptionTable.verticalHeader().setDefaultSectionSize(height);
		exceptionTable.verticalHeader().setMinimumSectionSize(-1);
		for (int i = 0; i < m_exceptionsModel.columnCount(); ++i){
			int header = exceptionTable.horizontalHeader().sectionSizeHint(i);
			switch (i) {
				case 0:
				header = fm.width(QLatin1String("averagebiglonghost.domain.com"));
				break;
				case 1:
				header = fm.width(QLatin1String("Allow For Session"));
				break;
			}
			int buffer = fm.width(QLatin1String("xx"));
			header += buffer;
			exceptionTable.horizontalHeader().resizeSection(i, header);
		}
	}

private slots:
	void block()
	{
		if (domainLineEdit.text().isEmpty())
			return;
		m_exceptionsModel.m_blockedCookies.append(domainLineEdit.text());
		m_cookieJar.setBlockedCookies(m_exceptionsModel.m_blockedCookies);
		m_exceptionsModel.reset();
	}

	void allow()
	{
		if (domainLineEdit.text().isEmpty())
			return;
		m_exceptionsModel.m_allowedCookies.append(domainLineEdit.text());
		m_cookieJar.setAllowedCookies(m_exceptionsModel.m_allowedCookies);
		m_exceptionsModel.reset();
	}
	void allowForSession()
	{
		if (domainLineEdit.text().isEmpty())
			return;
		m_exceptionsModel.m_sessionCookies.append(domainLineEdit.text());
		m_cookieJar.setAllowForSessionCookies(m_exceptionsModel.m_sessionCookies);
		m_exceptionsModel.reset();
	}
	
	void textChanged(const QString &text)
	{
		bool enabled = !text.isEmpty();
		blockButton.setEnabled(enabled);
		allowButton.setEnabled(enabled);
		allowForSessionButton.setEnabled(enabled);
	}
	
private:
	
	CookieExceptionsModel *m_exceptionsModel;
	QSortFilterProxyModel *m_proxyModel;
	CookieJar *m_cookieJar;
}
