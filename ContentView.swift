//  ContentView.swift
//  CloudKitPractice2022
//  Created by Scott D. Bowen on 19-Mar-2022.

import SwiftUI
import CloudKit

struct ContentView: View {
    var body: some View {
        VStack {
        Text("Hello, world!")
            .padding()
            Button("Init CloudKit Container", action: {
                CKContainer.default()
            })
        Button("Do CloudKit Save", action: {
            print()
            print("Do CloudKit stuff (100x)...")
            
            let db = CKContainer.init(identifier: "iCloud.CloudKitPractice2022").publicCloudDatabase
            
            let date_start = Date()
            var date_finish = TimeInterval()
            
            for iter in 1...100 {
                
                let tweet = CKRecord(recordType: "Tweet")
                let date = Date()
                tweet["text"] = "Text to save to the database... \(date.description)"
                
                let tweeter = CKRecord(recordType: "TwitterUser")
                tweet["tweeter"] = CKRecord.Reference(record: tweeter, action: .deleteSelf)
                
                db.save(tweet) { ( savedRecord: CKRecord?, error: Error? ) -> Void in
                    if error == nil {
                        print("CloudKit Operation Worked Fine.")
                        // print(savedRecord as Any)
                        date_finish = -date_start.timeIntervalSinceNow
                        print("Iter:", iter, "Time taken:", date_finish)
                    }
                    else {
                        print("A type of error occured!")
                        print(error!.localizedDescription)
                        date_finish = -date_start.timeIntervalSinceNow
                        print("Iter:", iter, "Time taken:", date_finish)
                    }
                }
            }
            
            print("Time taken:", date_finish)
            print()
        })
            
        Button("Do CloudKit Query", action: {
            
            print()
            print("Do CloudKit Query (1x)...")
            
            let db = CKContainer.init(identifier: "iCloud.CloudKitPractice2022").publicCloudDatabase
            
            var date_start = Date()
            var date_finish = TimeInterval()
            
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            let query = CKQuery(recordType: "Tweet", predicate: predicate)
            
            // Prime the qCursor:
            var qCursor : CKQueryOperation.Cursor?
            
            db.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 50) { (recordResults) -> Void in
                print("*** CloudKit Fetch Operation... with qCursor (<=100x) ***")
                date_finish = -date_start.timeIntervalSinceNow
                qCursor = try! recordResults.get().queryCursor
                print("Time taken:", date_finish)
                print("Match Results:", try! recordResults.get().matchResults.count )
            }
            
            for loop in 1...100 {
                // We 'sleep' here to simulate user inactivity for 750ms
                Thread.sleep(forTimeInterval: 0.750)
                
                if (qCursor != nil) {
                    
                    db.fetch(withCursor: qCursor!, resultsLimit: 50) { (recordResults2) -> Void in
                        date_finish = -date_start.timeIntervalSinceNow
                        qCursor = try! recordResults2.get().queryCursor
                        print("Loop:", loop)
                        print("Time taken:", date_finish)
                        print("Match Results:", try! recordResults2.get().matchResults.count )
                        print("qCursor Count:", qCursor.debugDescription.count)
                    }
                } else {
                    print("*** End of qCursor ***")
                    break
                }
            }
            
            print("*** Interdependent Fetches *** ")
            let ckRecordID = [ CKRecord.init(recordType: "Tweet").recordID ]
            // let loopedFetches = Array(repeating: CKFetchRecordsOperation(recordIDs: ckRecordID), count: 1)
            //    print(" - CKFetchRecordsOperation of Tweets") }, count: 8)
            let loopedFetches = CKFetchRecordsOperation(recordIDs: ckRecordID)
            
            // for iter in 0..<loopedFetches.count {
                loopedFetches.desiredKeys = [ "Tweet" ]
                loopedFetches.database = db
            loopedFetches.fetchRecordsResultBlock = { _ in print(" - CKFetchRecordsOperation of Tweets") }
                // loopedFetches[iter].addDependency(loopedFetches[iter - 1])
            // }
            
            date_start = Date()
            let queue = OperationQueue()
            queue.addOperations([loopedFetches], waitUntilFinished: true)
            date_finish = -date_start.timeIntervalSinceNow
            print("Interdependent Fetch Time:", date_finish)
            
            db.perform(query, inZoneWith: nil) { (records, error) -> Void in
                if error == nil {
                    print("*** CloudKit Query Worked Fine. ***")
                    // print(savedRecord as Any)
                    date_finish = -date_start.timeIntervalSinceNow
                    print("Time taken:", date_finish)
                    print("Record Count:", records!.count)
                    // print(records)
                }
                else {
                    print("A type of error occured!")
                    print(error!.localizedDescription)
                    date_finish = -date_start.timeIntervalSinceNow
                    print("Time taken:", date_finish)
                }
            }
        })
            
        Spacer(minLength: 32)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
