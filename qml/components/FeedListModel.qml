/*
* Copyright (C) 2023  Sander Klootwijk
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; version 3.
*
* wegwijs is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7
import QtQuick.XmlListModel 2.0

XmlListModel {
    id: feedListModel
    
    source: "https://www.verkeerplaza.nl/rssfeed"
    query: "/rss/channel/item"

    namespaceDeclarations: "declare namespace dc='http://purl.org/dc/elements/1.1/'; declare namespace content='http://purl.org/rss/1.0/modules/content/';"

    XmlRole { name: "title"; query: "title/string()"; }
    XmlRole { name: "description"; query: "description/string()";}
    XmlRole { name: "pubDate"; query: "pubDate/string()"; }
    XmlRole { name: "icon"; query: "enclosure/@url/string()"; }
}