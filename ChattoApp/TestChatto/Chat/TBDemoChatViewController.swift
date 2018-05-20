//
//  TBDemoChatViewController
//  TestChatto
//
//  Created by Nguyen Trong Bang on 20/5/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit

class TBDemoChatViewController: DemoChatViewController {
    var randomMessageTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(
            title: "Mute",
            style: .plain,
            target: self,
            action: #selector(muteNotification)
        )
        self.navigationItem.rightBarButtonItem = button
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        randomMessageTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addRandomMessage), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    private func stopTimer() {
        randomMessageTimer?.invalidate()
        randomMessageTimer = nil
    }
    
    //MARK: Actions
    @objc private func muteNotification() {
        
    }
    
    @objc private func addRandomMessage() {
        self.dataSource.addRandomIncomingMessage()
        print("Received new message")
    }
}
