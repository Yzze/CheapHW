import UIKit

import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

class Storage: Thread {
    private var count = 0
    var storage = [Chip]()
    var isAvailable = false
    var condition = NSCondition()
    
    var isEmpty: Bool {
        storage.isEmpty
    }
    
    func pop() -> Chip {
        condition.lock()
        if !isAvailable {
            condition.wait()
            print("Режим ожидания")
        }
        isAvailable = false
        condition.unlock()
        return storage.removeLast()
    }
    
    func push(item: Chip) {
        condition.lock()
        isAvailable = true
        storage.append(item)
        count += 1
        print("Чип \(count) добавлен в хранилище")
        condition.signal()
        print("Обработка")
        condition.unlock()
    }
}

class Generating: Thread {
    private let storage: Storage
    private var timer = Timer()
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    override func main() {
        timer = Timer(timeInterval: 2, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 20))
    }
    @objc func startTimer() {
        storage.push(item: Chip.make())
    }
}

class Worker: Thread {
    private var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    override func main() {
        while storage.isEmpty || storage.isAvailable {
            storage.pop().sodering()
            print("Припайка микросхемы")
        }
    }
}

let storage = Storage()
let generationThread = Generating(storage: storage)
let workerThread = Worker(storage: storage)
generationThread.start()
workerThread.start()
sleep(20)
generationThread.cancel()
