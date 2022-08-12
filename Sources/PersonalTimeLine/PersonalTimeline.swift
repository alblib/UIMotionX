//
//  PersonalTimeline.swift
//  
//
//  Created by Albertus Liberius on 2022/08/10.
//

import Foundation
import CoreLocation
import Darwin

/*
#if canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
*/

#if os(watchOS)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/*
 References:
 
 Handling Location Events in the Background
 https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/handling_location_events_in_the_background
 
 https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant-change_location_service
 
 https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services
 
 */


protocol PersonalTimelineProtocol{
    public(get) var path:[CLLocation]
}

/**
 fds
 
 Requires
 * must include the UIBackgroundModes key (with the location value) in their app’s Info.plist file.
 * Location Permission in info.plist
 * CLAuthorizationStatus=always
 */
internal class LooseLocationTracker: NSObject, CLLocationManagerDelegate{
    // PersonalTimelineRecorder
    private let locationManager = CLLocationManager()
    
    //var pathNavigation: Bool
    
    
    override init(){
        super.init()
        // MARK: Default Settings
        locationManager.delegate = self
        if #available(iOS 6, macOS 10.15, macCatalyst 13.1, watchOS 4, *) {
            locationManager.activityType = .otherNavigation // general transportations
            locationManager.allowsBackgroundLocationUpdates = true
        }
        // always monitoring
        if #available(iOS 6, macOS 10.15, macCatalyst 13.1, *) {
            locationManager.pausesLocationUpdatesAutomatically = false
        }// if this feature is not available, still FALSE is the default.
        
        
        // MARK: Start Monitoring
        if #available(iOS 8, macOS 10.15, macCatalyst 13.1, watchOS 2, *){
            locationManager.requestAlwaysAuthorization()
        } // result is dealt in locationManagerDidChangeAuthorization
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: Responding to Authorization Changes (and also init)
    @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, watchOS 7, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        locationManager(manager, didChangeAuthorization: manager.authorizationStatus)
    }
    
    /** Alerts users to authorise the location service if user has denied the authorisation. */
    @available(iOS 4.2, macOS 10.7, macCatalyst 13.1, tvOS 9.0, watchOS 2.0, *)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        // Purpose of this method: alert user to change authorization.
        var message: String
        switch status{
        case .restricted:
            message = "This device restricts location services. Personal timeline recording has been disabled."
        case .denied:
            message = "You have denied to allow location access of this app, which disables personal timeline recording."
        case .authorizedWhenInUse:
            message = "You only authorized to use location when this app is running. Please allow location access 'Always' to use background personal timeline recording."
        default:
            break
        }
        
        // Generating an alert object
        #if os(watchOS)
        if #available(watchOS 2, *){
            let alert = WKAlertAction
        }
            
        #elseif canImport(UIKit)
            if #available(iOS 8, macCatalyst 13.1, tvOS 9, *){
                let alert = UIAlertController(title: "Allow Location Access", message: message, preferredStyle: .alert)
                let dismissButton = UIAlertAction(title: "Dismiss", style: .default)
                let settingButton = UIAlertAction(title: "Settings", style: .default, handler: {(action) in
                    if let url = URL(string: UIApplication.openSettingsURLString){
                        //await
                        UIApplication.shared.open(url)
                    }
                }
                )
            }
        #else
        #endif
            
    }
    
    // MARK: Handling Errors
    /** Tells the delegate that the location manager was unable to retrieve a location value. */
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error){
        // Purpose of this method: Killing all errors. (Don't pass any exceptions)
        // Notifying the user to change the authorization is done in locationManagerDidChangeAuthorization.
        if (error as? CLError)?.code == CLError.Code.denied{
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    // MARK: Responding to Location Events
    /** Tells the delegate that new location data is available. */
    @available(iOS 6, macOS 10.9, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
    }
    
    // Obsolete: see locationManager(_:didUpdateLocations:)
    func locationManager(_ manager: CLLocationManager, didUpdateTo newLocation: CLLocation,
                         from oldLocation: CLLocation)
    {
        locationManager(manager, didUpdateLocations: [newLocation])
    }

}

/*

struct PersonalTimeline: Codable{
    
    // MARK: Location Tracking
    
    private let locationManager = CLLocationManager()
    var currentTime: Date{
        Date() //Date.now for iOS15, iPadOS15, macOS12, macCatalyst15, tvOS15, watchOS8, Xcode13
    }
    var currentTimeZone: TimeZone{
        
    }
    
}
*/
