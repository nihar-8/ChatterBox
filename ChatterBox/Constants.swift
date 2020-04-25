//  Constants.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import Firebase

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let users = databaseRoot.child("Users")
        static let chats = databaseRoot.child("Chats")
        static let groups = databaseRoot.child("Groups")
        static let groupChats = databaseRoot.child("GroupChats")
        static let storage = Storage.storage().reference()
        static let UserStorage = storage.child("Users")
        static let GroupStorage = storage.child("Groups")
    }
}
