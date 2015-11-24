//
//  LinkViewController.swift
//  Midi Manipulation
//
//  Created by Riley Testut on 11/15/15.
//  Copyright © 2015 USC Hackers. All rights reserved.
//

import UIKit

// TV = Client

enum CommunicatorEvent: Int16
{
    case SwipeUp
    case SwipeDown
    case SwipeLeft
    case SwipeRight
    case Shake
    case Tap
    case FingerTracking
    case FinishedFingerTracking
    case GuitarQRCode
    case NoGuitarQRCode
    case DrumsQRCode
    case NoDrumsQRCode
    case WatchTap
}

enum LinkViewControllerSection: Int
{
    case ConnectedPeers
    case NearbyPeers
}

class LinkViewController: UITableViewController
{
    private(set) var connectedPeers: [GBAPeer] = GBABluetoothLinkManager.sharedManager().connectedPeers as! [GBAPeer]
    private(set) var nearbyPeers: [GBAPeer] = GBABluetoothLinkManager.sharedManager().nearbyPeers as! [GBAPeer]
    
    required init()
    {
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Linking", comment: "")
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissLinkViewController:")
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        self.tableView.registerClass(GBALinkViewControllerTableViewCell.self, forCellReuseIdentifier: "LinkCell")
        self.tableView.registerClass(GBALinkNearbyPeersHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "NearbyPeersHeader")
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        GBABluetoothLinkManager.sharedManager().delegate = self
        
        self.enableLinking()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        GBABluetoothLinkManager.sharedManager().delegate = nil
        
        if UIDevice.currentDevice().userInterfaceIdiom == .TV
        {
            GBABluetoothLinkManager.sharedManager().stopScanningForPeers()
        }
        else
        {
            GBABluetoothLinkManager.sharedManager().stopAdvertisingPeer()
        }
    }
    
    func dismissLinkViewController(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

private extension LinkViewController
{
    func enableLinking()
    {
        let peerType = (UIDevice.currentDevice().userInterfaceIdiom == .TV) ? GBALinkPeerType.Client : GBALinkPeerType.Server
        
        GBABluetoothLinkManager.sharedManager().peerType = peerType
        GBABluetoothLinkManager.sharedManager().enabled = true
        
        if peerType == .Server
        {
            GBABluetoothLinkManager.sharedManager().startAdvertisingPeer()
        }
        else
        {
            GBABluetoothLinkManager.sharedManager().startScanningForPeers()
        }
    }
    
    func disableLinking()
    {
        GBABluetoothLinkManager.sharedManager().enabled = false
        
        if UIDevice.currentDevice().userInterfaceIdiom == .TV
        {
            GBABluetoothLinkManager.sharedManager().stopScanningForPeers()
        }
        else
        {
            GBABluetoothLinkManager.sharedManager().stopAdvertisingPeer()
        }
    }
    
    func connectPeer(peer: GBAPeer)
    {
        self.addConnectedPeer(peer)
        self.removeNearbyPeer(peer)
        
        GBABluetoothLinkManager.sharedManager().connectPeer(peer)
    }
    
    func addNearbyPeer(peer: GBAPeer)
    {
        if self.nearbyPeers.contains(peer) || self.connectedPeers.contains(peer)
        {
            return
        }
        
        self.nearbyPeers.append(peer)
        
        if self.nearbyPeers.count == 1
        {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: LinkViewControllerSection.NearbyPeers.rawValue)], withRowAnimation: .Fade)
            
            let headerFooterView = self.tableView.headerViewForSection(LinkViewControllerSection.NearbyPeers.rawValue) as! GBALinkNearbyPeersHeaderFooterView
            headerFooterView.showsActivityIndicator = true
        }
        else
        {
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.nearbyPeers.count - 1, inSection: LinkViewControllerSection.NearbyPeers.rawValue)], withRowAnimation: .Fade)
        }
    }
    
    func addConnectedPeer(peer: GBAPeer)
    {
        if let row = self.connectedPeers.indexOf(peer)
        {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection:  LinkViewControllerSection.ConnectedPeers.rawValue)], withRowAnimation: .Fade)
        }
        
        self.connectedPeers.append(peer)
        
        if self.connectedPeers.count == 1
        {
            self.tableView.reloadSections(NSIndexSet(index: LinkViewControllerSection.ConnectedPeers.rawValue), withRowAnimation: .Fade)
        }
        else
        {
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.connectedPeers.count - 1, inSection: LinkViewControllerSection.ConnectedPeers.rawValue)], withRowAnimation: .Fade)
        }
    }
    
    func removeNearbyPeer(peer: GBAPeer)
    {
        guard let row = self.nearbyPeers.indexOf(peer) else { return }
        
        self.nearbyPeers.removeAtIndex(row)
        
        if self.nearbyPeers.count == 0
        {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: LinkViewControllerSection.NearbyPeers.rawValue)], withRowAnimation: .Fade)
            
            let headerFooterView = self.tableView.headerViewForSection(LinkViewControllerSection.NearbyPeers.rawValue) as! GBALinkNearbyPeersHeaderFooterView
            headerFooterView.showsActivityIndicator = false
        }
        else
        {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: LinkViewControllerSection.NearbyPeers.rawValue)], withRowAnimation: .Fade)
        }
    }
    
    func removeConnectedPeer(peer: GBAPeer)
    {
        guard let row = self.connectedPeers.indexOf(peer) else { return }
        
        self.connectedPeers.removeAtIndex(row)
        
        if self.connectedPeers.count == 0
        {
            self.tableView.reloadSections(NSIndexSet(index:  LinkViewControllerSection.ConnectedPeers.rawValue), withRowAnimation: .Fade)
        }
        else
        {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: LinkViewControllerSection.ConnectedPeers.rawValue)], withRowAnimation: .Fade)
        }
    }
}

extension LinkViewController: GBABluetoothLinkManagerDelegate
{
    func linkManager(linkManager: GBABluetoothLinkManager!, didDiscoverPeer peer: GBAPeer!)
    {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.beginUpdates()
            
            if self.connectedPeers.contains(peer)
            {
                self.tableView.reloadSections(NSIndexSet(index: LinkViewControllerSection.ConnectedPeers.rawValue), withRowAnimation: .Fade)
            }
            else if self.nearbyPeers.contains(peer)
            {
                self.tableView.reloadSections(NSIndexSet(index: LinkViewControllerSection.NearbyPeers.rawValue), withRowAnimation: .Fade)
            }
            else
            {
                self.addNearbyPeer(peer)
            }
            
            self.tableView.endUpdates()
        }
    }
    
    func linkManager(linkManager: GBABluetoothLinkManager!, didConnectPeer peer: GBAPeer!)
    {
        if self.connectedPeers.contains(peer)
        {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.beginUpdates()
            
            self.removeNearbyPeer(peer)
            self.addConnectedPeer(peer)
            
            self.tableView.endUpdates()
            
        }
    }
    
    func linkManager(linkManager: GBABluetoothLinkManager!, didFailToConnectPeer peer: GBAPeer!, error: NSError!)
    {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.beginUpdates()
            
            self.removeConnectedPeer(peer)
            self.addNearbyPeer(peer)
            
            self.tableView.endUpdates()
            
        }
    }
    
    func linkManager(linkManager: GBABluetoothLinkManager!, didDisconnectPeer peer: GBAPeer!, error: NSError!)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
            
            self.removeConnectedPeer(peer)
            self.addNearbyPeer(peer)
            
            self.tableView.endUpdates()
        }
    }
}

extension LinkViewController
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section != LinkViewControllerSection.NearbyPeers.rawValue
        {
            return
        }
        
        if indexPath.row == 0 && self.nearbyPeers.count == 0
        {
            return
        }
        
        self.connectPeer(self.nearbyPeers[indexPath.row])
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .TV
        {
            if GBABluetoothLinkManager.sharedManager().enabled
            {
                return 2
            }
        }
        else
        {
            if GBABluetoothLinkManager.sharedManager().enabled
            {
                return 1
            }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .TV
        {
            if section == LinkViewControllerSection.NearbyPeers.rawValue
            {
                let headerFooterView = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("NearbyPeersHeader") as! GBALinkNearbyPeersHeaderFooterView
                
                if self.nearbyPeers.count == 0
                {
                    headerFooterView.showsActivityIndicator = false
                }
                else
                {
                    headerFooterView.showsActivityIndicator = true
                }
                
                return headerFooterView
            }
        }
        
        return super.tableView(tableView, viewForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        guard section == LinkViewControllerSection.ConnectedPeers.rawValue else { return UITableViewAutomaticDimension }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .TV && self.connectedPeers.count == 0
        {
            return 1
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if section == LinkViewControllerSection.ConnectedPeers.rawValue
        {
            if UIDevice.currentDevice().userInterfaceIdiom == .TV && self.connectedPeers.count == 0
            {
                return 1
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == LinkViewControllerSection.ConnectedPeers.rawValue
        {
            if UIDevice.currentDevice().userInterfaceIdiom == .TV || self.connectedPeers.count > 0
            {
                return self.connectedPeers.count
            }
        }
        else if section == LinkViewControllerSection.NearbyPeers.rawValue
        {
            if self.nearbyPeers.count > 0
            {
                return self.nearbyPeers.count
            }
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == LinkViewControllerSection.ConnectedPeers.rawValue
        {
            return NSLocalizedString("Connected", comment: "")
        }
        else if section == LinkViewControllerSection.NearbyPeers.rawValue
        {
            return NSLocalizedString("Nearby Devices", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let identifier = "LinkCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if indexPath.section == LinkViewControllerSection.ConnectedPeers.rawValue
        {
            if self.connectedPeers.count == 0
            {
                cell.textLabel?.textColor = UIColor.grayColor()
                cell.textLabel?.text = NSLocalizedString("Waiting…", comment: "")
                cell.selectionStyle = .None
                
                if let cell = cell as? GBALinkViewControllerTableViewCell
                {
                    cell.showsActivityIndicator = true
                }
            }
            else
            {
                let peer = self.connectedPeers[indexPath.row]
                cell.textLabel?.text = peer.name
                cell.selectionStyle = .None
                
                if let cell = cell as? GBALinkViewControllerTableViewCell
                {
                    if peer.state == .Connected
                    {
                        cell.showsActivityIndicator = false
                    }
                    else
                    {
                        cell.showsActivityIndicator = true
                    }
                }
            }
        }
        else if indexPath.section == LinkViewControllerSection.NearbyPeers.rawValue
        {
            if self.nearbyPeers.count == 0
            {
                cell.textLabel?.textColor = UIColor.grayColor()
                cell.textLabel?.text = NSLocalizedString("Searching…", comment: "")
                cell.selectionStyle = .None
                
                if let cell = cell as? GBALinkViewControllerTableViewCell
                {
                    cell.showsActivityIndicator = true
                }
            }
            else
            {
                let peer = self.nearbyPeers[indexPath.row]
                cell.textLabel?.text = peer.name
                cell.selectionStyle = .Default
            }
        }
        
        return cell
    }
}





