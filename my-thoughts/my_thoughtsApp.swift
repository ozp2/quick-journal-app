//
//  my_thoughtsApp.swift
//  my-thoughts
//
//  Created by Olivia on 7/11/25.
//

import SwiftUI
import AppKit

@main
struct my_thoughtsApp: App {
    // Create the popover and status item
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        // No main window group
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            // Use custom icon from asset catalog
            if let image = NSImage(named: "thoughts") {
                // Configure the image for menu bar display
                image.size = NSSize(width: 18, height: 18)
                image.isTemplate = true // This makes it adapt to light/dark menu bar
                button.image = image
            } else {
                // Fallback to system symbol if custom image not found
                button.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: "Olivia's Thoughts")
            }
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
