//
//  AppDelegate.swift
//  notchappkit
//
//  Created by YOONJONG on 9/16/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 윈도우 생성
        window = NSWindow(contentRect: NSMakeRect(0, 0, 400, 400),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered,
                          defer: false)
        window?.center()
        window?.title = "임시 타이틀 세팅"
        
        // ViewController 세팅
        let viewController = ViewController()
        window?.contentViewController = viewController
        
        // 윈도유 표시
        window?.makeKeyAndOrderFront(nil)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

