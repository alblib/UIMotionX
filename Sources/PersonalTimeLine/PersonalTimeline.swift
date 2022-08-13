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



#if os(watchOS) || os(tvOS)
/**
 fdf
 */
@available(*, unavailable)
internal class LooseLocationTracker{}
#else

/**
 fds
 
 Requires
 * must include the UIBackgroundModes key (with the location value) in their app’s Info.plist file.
 * Location Permission in info.plist
 * CLAuthorizationStatus=always
 */
@available(iOS 8, macOS 10.15, macCatalyst 13.1, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
internal class LooseLocationTracker: NSObject, CLLocationManagerDelegate{
    //@available(iOS 4.2, macOS 10.7, macCatalyst 13.1, *) // availability of significantLocationChanges
    //@available(iOS 6, macOS 10.9, macCatalyst 13.1, tvOS 9, watchOS 2, *) //locationManager(_:didUpdateLocations:) availability
    
    
    // PersonalTimelineRecorder
    private let locationManager = CLLocationManager()
    
    var suppressCLAuthorizationWarning: Bool = false{
        didSet{
            if suppressCLAuthorizationWarning == false{
                if #available(iOS 14, macOS 11, macCatalyst 14, *){
                    locationManagerDidChangeAuthorization(locationManager)
                }else{
                    locationManager(locationManager, didChangeAuthorization: CLLocationManager.authorizationStatus())
                }
            }
        }
    }
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
        if CLLocationManager.significantLocationChangeMonitoringAvailable(){
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    // MARK: Responding to Authorization Changes (and also init)
    @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, *)// watchOS 7, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        locationManager(manager, didChangeAuthorization: manager.authorizationStatus)
    }
    
    /** Alerts users to authorise the location service if user has denied the authorisation. */
    //@available(iOS 4.2, macOS 10.7, macCatalyst 13.1, tvOS 9.0, watchOS 2.0, *)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        guard suppressCLAuthorizationWarning == false else{ return }
        // Purpose of this method: alert user to change authorization.
        let alertTitle: String = "Allow Location Access"
        var alertMessage: String
        switch status{
        case .restricted:
            alertMessage = "This device restricts location services. Personal timeline recording has been disabled."
        case .denied:
            alertMessage = "You have denied to allow location access of this app, which disables personal timeline recording."
        case .authorizedWhenInUse:
            alertMessage = "You only authorized to use location when this app is running. Please allow location access 'Always' to use background personal timeline recording."
        default:
            return // even if 'undetermined', ask later when the authorization is explicitly called.
        }
        
        // Generating an alert object
        #if canImport(UIKit) // #available(iOS 8, macCatalyst 13.1, tvOS 9, *)
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default)
        let settingButton = UIAlertAction(title: "Settings", style: .default, handler: {_ in
            if let url = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(settingButton)
        alert.addAction(dismissButton)
        //alert.preferredAction = dismissButton
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
            
        #else
        
        #endif
            
    }
    
    // MARK: Handling Errors
    /** Tells the delegate that the location manager was unable to retrieve a location value. */
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error){
        // Purpose of this method: Killing all errors. (Don't pass any exceptions)
        // Notifying the user to change the authorization is done in locationManagerDidChangeAuthorization.
        if (error as? CLError)?.code == CLError.Code.denied{
            //locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    // MARK: Responding to Location Events
    /** Tells the delegate that new location data is available. */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //@available(iOS 6, macOS 10.9, macCatalyst 13.1, tvOS 9, watchOS 2, *)
        // before then, used func locationManager(_ manager: CLLocationManager, didUpdateTo newLocation: CLLocation, from oldLocation: CLLocation)
        
        
        
    }
    
}

#endif

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
