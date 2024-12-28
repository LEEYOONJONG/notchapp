//
//  ViewController.swift
//  notchappkit
//
//  Created by YOONJONG on 9/16/24.
//

import Cocoa
import Combine
import MediaPlayer
import Foundation
import CoreFoundation
import AppKit

class ViewController: NSViewController {
    lazy var songField: NSTextField = {
        let textField = NSTextField()
        textField.stringValue = "title field"
        textField.backgroundColor = .red
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var albumField: NSTextField = {
        let textField = NSTextField()
        textField.stringValue = "album field"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var artistField: NSTextField = {
        let textField = NSTextField()
        textField.stringValue = "artist field"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var imageView: NSImageView = {
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer?.cornerRadius = 8
        return imageView
    }()
    
    
    
    var observers: [NSObjectProtocol] = []
    @Published var artist: String?
    @Published var song: String?
    @Published var album: String?
    var cancelBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeObserver()

        addObserver()
        bind()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        removeObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0,0,400,400))
        view.wantsLayer = true
        view.layer?.borderWidth = 2
        view.layer?.borderColor = NSColor.red.cgColor
        self.view = view
        
        setLayout()
    }
    
    func removeObserver() {
        _ = observers.map {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    func setLayout() {
        [imageView, songField, albumField, artistField].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            songField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            songField.heightAnchor.constraint(equalToConstant: 30),
            songField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            songField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        NSLayoutConstraint.activate([
            albumField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumField.topAnchor.constraint(equalTo: songField.bottomAnchor, constant: 10),
            albumField.heightAnchor.constraint(equalToConstant: 30),
            albumField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            albumField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        
        NSLayoutConstraint.activate([
            artistField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistField.topAnchor.constraint(equalTo: albumField.bottomAnchor, constant: 10),
            artistField.heightAnchor.constraint(equalToConstant: 30),
            artistField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            artistField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    func bind() {
        $artist.sink { value in
            guard let value else { return }
            self.artistField.stringValue = value
        }.store(in: &cancelBag)
        
        $song.sink { value in
            guard let value else { return }
            self.songField.stringValue = value
        }.store(in: &cancelBag)
        
        $album.sink { value in
            guard let value else { return }
            self.albumField.stringValue = value
        }.store(in: &cancelBag)
    }
    
    func addObserver() {
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(
            bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString
        )
        typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
        let MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)

        let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
            bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
            MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self
        )
        
        let playingInfoChangeNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
                                                                                   object: nil,
                                                                                   queue: nil) { (notification) in
            MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { information in
                self.artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String
                self.song = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String
                self.album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String
                if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                    let image = NSImage(data: artworkData)
                    self.imageView.image = image
                }
                self.print(information: information)
                
            })
        }

        observers.append(playingInfoChangeNotification)

        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main);
    }
    
    private func print(information: [AnyHashable: Any]) {
        debugPrint("====================================")
        debugPrint(information["kMRMediaRemoteNowPlayingInfoTitle"] as? String)
        debugPrint(information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? NSNumber)
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}
