//
//  LinphoneManager.swift
//  linphone-swift-demo
//
//  Created by Hamza Öztürk on 25.12.2019.
//  Copyright © 2019 Busoft. All rights reserved.
//

import Foundation

class LinphoneManager: NSObject {

    static let shared = LinphoneManager()
    
    private var linphoneCore: OpaquePointer?
    private var linphoneLoggingService: OpaquePointer?
    private static var iterateTimer: Timer?

    private override init() {}

    private let registrationStateChanged: LinphoneCoreRegistrationStateChangedCb  = {
        (lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) in
        
        LinphoneManager.shared.registrationStateChanged(lc: lc, proxyConfig: proxyConfig, state: state, message: message)
    } as LinphoneCoreRegistrationStateChangedCb
    
    private let callStateChanged: LinphoneCoreCallStateChangedCb = {
        (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, state: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
        
        LinphoneManager.shared.callStateChanged(lc: lc, call: call, state: state, message: message)
    }
    
    private func registrationStateChanged(lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) {
        var stateMessage = ""
        if let message = message {
            stateMessage = String(cString: message)
        }
        
        switch state{
        case LinphoneRegistrationNone:
            print("registrationStateChanged -> LinphoneRegistrationNone -> \(stateMessage)")
        case LinphoneRegistrationProgress:
            print("registrationStateChanged -> LinphoneRegistrationProgress -> \(stateMessage)")
        case LinphoneRegistrationOk:
            print("registrationStateChanged -> LinphoneRegistrationOk -> \(stateMessage)")
        case LinphoneRegistrationCleared:
            print("registrationStateChanged -> LinphoneRegistrationCleared -> \(stateMessage)")
        case LinphoneRegistrationFailed:
            print("registrationStateChanged -> LinphoneRegistrationFailed -> \(stateMessage)")
        default:
            return
        }
    }
    
    private func callStateChanged(lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, state: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) {
        var stateMessage = ""
        if let message = message {
            stateMessage = String(cString: message)
        }
        switch state {
        case LinphoneCallStateIdle:
            print("callStateChanged -> LinphoneCallStateIdle -> \(stateMessage)")
        case LinphoneCallStateIncomingReceived:
            print("callStateChanged -> LinphoneCallStateIncomingReceived -> \(stateMessage)")
            
            ms_usleep(3 * 1000 * 1000); // Wait 3 seconds to pickup
            linphone_call_accept(call)
        case LinphoneCallStateOutgoingInit:
            print("callStateChanged -> LinphoneCallStateOutgoingInit -> \(stateMessage)")
        case LinphoneCallStateOutgoingProgress:
            print("callStateChanged -> LinphoneCallStateOutgoingProgress -> \(stateMessage)")
        case LinphoneCallStateOutgoingRinging:
            print("callStateChanged -> LinphoneCallStateOutgoingRinging -> \(stateMessage)")
        case LinphoneCallStateOutgoingEarlyMedia:
            print("callStateChanged -> LinphoneCallStateOutgoingEarlyMedia -> \(stateMessage)")
        case LinphoneCallStateConnected:
            print("callStateChanged -> LinphoneCallStateConnected -> \(stateMessage)")
        case LinphoneCallStateStreamsRunning:
            print("callStateChanged -> LinphoneCallStateStreamsRunning -> \(stateMessage)")
        case LinphoneCallStatePausing:
            print("callStateChanged -> LinphoneCallStatePausing -> \(stateMessage)")
        case LinphoneCallStatePaused:
            print("callStateChanged -> LinphoneCallStatePaused -> \(stateMessage)")
        case LinphoneCallStateResuming:
            print("callStateChanged -> LinphoneCallStateResuming -> \(stateMessage)")
        case LinphoneCallStateReferred:
            print("callStateChanged -> LinphoneCallStateReferred -> \(stateMessage)")
        case LinphoneCallStateError:
            print("callStateChanged -> LinphoneCallStateError -> \(stateMessage)")
        case LinphoneCallStateEnd:
            print("callStateChanged -> LinphoneCallStateEnd -> \(stateMessage)")
        case LinphoneCallStatePausedByRemote:
            print("callStateChanged -> LinphoneCallStatePausedByRemote -> \(stateMessage)")
        case LinphoneCallStateUpdatedByRemote:
            print("callStateChanged -> LinphoneCallStateUpdatedByRemote -> \(stateMessage)")
        case LinphoneCallStateIncomingEarlyMedia:
            print("callStateChanged -> LinphoneCallStateIncomingEarlyMedia -> \(stateMessage)")
        case LinphoneCallStateUpdating:
            print("callStateChanged -> LinphoneCallStateUpdating -> \(stateMessage)")
        case LinphoneCallStateReleased:
            print("callStateChanged -> LinphoneCallStateReleased -> \(stateMessage)")
        case LinphoneCallStateEarlyUpdatedByRemote:
            print("callStateChanged -> LinphoneCallStateEarlyUpdatedByRemote -> \(stateMessage)")
        case LinphoneCallStateEarlyUpdating:
            print("callStateChanged -> LinphoneCallStateEarlyUpdating -> \(stateMessage)")
        default:
            return
        }
    }
    
    func initialize() {

        linphoneLoggingService = linphone_logging_service_get()        
        linphone_logging_service_set_log_level(linphoneLoggingService, LinphoneLogLevelFatal)
        
        let configFileName = documentFile("linphonerc")
        let factoryConfigFileName = bundleFile("linphonerc-factory")

        let configFileNamePtr: UnsafePointer<Int8> = configFileName.cString(using: String.Encoding.utf8.rawValue)!
        let factoryConfigFilenamePtr = UnsafeMutablePointer<Int8>(mutating: (factoryConfigFileName! as NSString).utf8String)
        
        let config = linphone_config_new_with_factory(configFileNamePtr, factoryConfigFilenamePtr)
        
        if let ring = bundleFile("notes_of_the_optimistic", "caf") {
            let unsafePointer = UnsafeMutablePointer<Int8>(mutating: (ring as NSString).utf8String)

            linphone_config_set_string(config, "sound", "local_ring", unsafePointer)
        }
        
        if let ringback = bundleFile("ringback", "wav") {
            let unsafePointer = UnsafeMutablePointer<Int8>(mutating: (ringback as NSString).utf8String)

            linphone_config_set_string(config, "sound", "remote_ring", unsafePointer)
        }
        
        if let hold = bundleFile("hold", "mkv") {
            let unsafePointer = UnsafeMutablePointer<Int8>(mutating: (hold as NSString).utf8String)

            linphone_config_set_string(config, "sound", "hold_music", unsafePointer)
        }
        
        let factory = linphone_factory_get()
        let callBacks = linphone_factory_create_core_cbs(factory)
        linphone_core_cbs_set_registration_state_changed(callBacks, registrationStateChanged)
        linphone_core_cbs_set_call_state_changed(callBacks, callStateChanged)
        
        linphoneCore = linphone_factory_create_core_with_config_3(factory, config, nil)
        linphone_core_add_callbacks(linphoneCore, callBacks)
        linphone_core_start(linphoneCore)

        linphone_core_cbs_unref(callBacks)
        linphone_config_unref(config)
    }
    
    fileprivate func bundleFile(_ name: String, _ ext: String? = nil) -> String? {
        return Bundle.main.path(forResource: name, ofType: ext)
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    func demo() {
//        makeCall()
//        receiveCall()
        idle()
    }
    
    func makeCall(){
        let calleeAccount = "544636456344"
        
        guard let _ = setIdentify() else {
            print("no identity")
            return;
        }
        linphone_core_invite(linphoneCore, calleeAccount)
        setTimer()
    }
    
    func receiveCall(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
    }
    
    func idle(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
    }
    
    func setIdentify() -> OpaquePointer? {
        guard
            let path = bundleFile("Secret", "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let username = dict["username"] as? String,
            let password = dict["password"] as? String,
            let domain = dict["domain"] as? String,
            let port = dict["port"] as? String
            else { return nil }
        
        let identity = "sip:" + username + "@" + domain + ":" + port
            
        guard let temp_address = linphone_address_new(identity) else {
            print("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org")
            return nil
        }
        
        let address = linphone_address_new(nil)
        linphone_address_set_username(address, linphone_address_get_username(temp_address))
        linphone_address_set_domain(address, linphone_address_get_domain(temp_address))
        linphone_address_set_port(address, linphone_address_get_port(temp_address))
        linphone_address_set_transport(address, linphone_address_get_transport(temp_address))
        
        let config = linphone_core_create_proxy_config(linphoneCore)
        linphone_proxy_config_set_identity_address(config, address)
        linphone_proxy_config_set_route(config, "\(domain):\(port)")
        linphone_proxy_config_set_server_addr(config, "\(domain):\(port)")
        linphone_proxy_config_enable_register(config, 0)
        linphone_proxy_config_enable_publish(config, 0)
                
        linphone_core_add_proxy_config(linphoneCore, config)
        linphone_core_set_default_proxy_config(linphoneCore, config)
        
        let info = linphone_auth_info_new(username, nil, password, nil, nil, nil)
        linphone_core_add_auth_info(linphoneCore, info)
        
        linphone_proxy_config_unref(config)
        linphone_auth_info_unref(info)
        linphone_address_unref(address)
        
        return config
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_enable_register(proxy_cfg, 1); /* activate registration for this proxy config*/
    }
    
    func shutdown(){
        print("Shutdown..")
        
        type(of: self).iterateTimer = nil

        guard let linphoneCore = linphoneCore else { return } // just in case application terminate before linphone core initialization
        
        let config = linphone_core_get_default_proxy_config(linphoneCore)
        linphone_proxy_config_edit(config)
        linphone_proxy_config_enable_register(config, 0)
        linphone_proxy_config_done(config)
        
        while(linphone_proxy_config_get_state(config) != LinphoneRegistrationCleared) {
            linphone_core_iterate(linphoneCore)
            ms_usleep(50000);
        }
        
        linphone_core_unref(linphoneCore)
    }
    
    @objc private func iterate(){
        if let linphoneCore = linphoneCore {
            linphone_core_iterate(linphoneCore); /* first iterate initiates registration */
        }
    }
    
    fileprivate func setTimer(){
        type(of: self).iterateTimer = Timer.scheduledTimer (
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
}
