//
//  LiveBluetoothDebuggerTableViewController.swift
//  Sonar
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

#if DEBUG || INTERNAL

class LiveBTLEDebuggerTableViewController: UITableViewController, ContactEventRepositoryDelegate {

    var persistence: Persisting = (UIApplication.shared.delegate as! AppDelegate).persistence
    
    var broadcastIdGenerator: BroadcastPayloadGenerator? = ((UIApplication.shared.delegate as! AppDelegate).bluetoothNursery as! ConcreteBluetoothNursery).broadcastIdGenerator
    
    @objc var repository: PersistingContactEventRepository = (UIApplication.shared.delegate as! AppDelegate).bluetoothNursery.contactEventRepository as! PersistingContactEventRepository
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repository.delegate = self
    }
    
    // MARK: - ContactEventRepositoryDelegate
    
    func repository(_ repository: ContactEventRepository, didRecord broadcastPayload: IncomingBroadcastPayload, for peripheral: BTLEPeripheral) {
        tableView.reloadData()
    }

    func repository(_ repository: ContactEventRepository, didRecordRSSI RSSI: Int, for peripheral: BTLEPeripheral) {
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "My Sonar ID"
        case 1: return "My Encrypted Broadcast ID"
        case 2: return "Visible Devices"
        default: preconditionFailure("No section \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return repository.contactEvents.count
            
        default:
            preconditionFailure("No section \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! DebuggerTableViewCell

        cell.textLabel?.numberOfLines = 1
        switch (indexPath.section, indexPath.row) {

        case (0, _):
            let sonarId = persistence.registration?.id.uuidString ?? "<not yet registered>"
            cell.textLabel?.text = sonarId
            cell.gradientColorData = sonarId.data(using: .utf8)
            
        case (1, _):
            cell.textLabel?.text = broadcastIdGenerator?.broadcastPayload()?.cryptogram.base64EncodedString()
            cell.gradientColorData = broadcastIdGenerator?.broadcastPayload()?.cryptogram

            // TODO: This is going to be broken until we chase the BroadcastPayload back up through
        case (2, let row):
            cell.textLabel?.text = repository.contactEvents[row].encryptedRemoteContactId?.base64EncodedString()
            cell.gradientColorData = repository.contactEvents[row].encryptedRemoteContactId
            
        default:
            preconditionFailure("No cell at indexPath \(indexPath)")
        }

        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Data {
    func asCGColor(alpha: CGFloat) -> CGColor {
        return asUIColor(alpha: alpha).cgColor
    }

    func asUIColor(alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(self[1]) / 255.0, green: CGFloat(self[2]) / 255.0, blue: CGFloat(self[3]) / 255.0, alpha: alpha)
    }
}

#endif
