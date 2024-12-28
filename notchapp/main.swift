//
//  main.swift
//  notchappkit
//
//  Created by YOONJONG on 9/19/24.
//

import Cocoa

 let delegate = AppDelegate() //alloc main app's delegate class
 NSApplication.shared.delegate = delegate //set as app's delegate
 NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv) //start of run loop

