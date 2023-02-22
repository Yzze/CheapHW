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
    var isAvaibale = false
    var condition = NSCondition()
    
    var isEmpty: Bool {
        storage.isEmpty
    }
    
    func pop() -> Chip {
        condition.lock()
        if !isAvaibale {
            condition.wait()
            print("Режим ожидания")
        }
        isAvaibale = false
        condition.unlock()
        return storage.removeLast()
    }
    
    func push(item: Chip) {
        condition.lock()
        isAvaibale = true
        storage.append(item)
        count += 1
        print("Чип добавлен в хранилище")
        condition.signal()
        print("Обработка")
        condition.unlock()
    }
}

class Generating: Thread {
    
}

class Worker: Thread {
    
}
