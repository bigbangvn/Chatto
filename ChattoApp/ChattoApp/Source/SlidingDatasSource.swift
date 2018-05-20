/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import Foundation

public enum InsertPosition {
    case top
    case bottom
}

public class SlidingDataSource<Element> {
    typealias LoadBlock = (_ loadedItems: [Element]) -> Void
    
    private var isLoading: Bool = false
    private var pageSize: Int
    private var windowOffset: Int
    private var windowCount: Int
    private var itemGenerator: (() -> Element)?
    private var items = [Element]()
    private var itemsOffset: Int
    public var itemsInWindow: [Element] {
        let offset = self.windowOffset - self.itemsOffset
        return Array(items[offset..<offset+self.windowCount])
    }

    public init(count: Int, pageSize: Int, itemGenerator: (() -> Element)?) {
        self.windowOffset = count
        self.itemsOffset = count
        self.windowCount = 0
        self.pageSize = pageSize
        self.itemGenerator = itemGenerator
        self.generateItems(min(pageSize, count), position: .top)
    }

    public convenience init(items: [Element], pageSize: Int) {
        self.init(count: 0, pageSize: pageSize, itemGenerator: nil)
        for item in items {
            self.insertItem(item, position: .bottom)
        }
    }

    private func generateItems(_ count: Int, position: InsertPosition) {
        guard count > 0 else { return }
        guard let itemGenerator = self.itemGenerator else {
            fatalError("Can't create messages without a generator")
        }
        for _ in 0..<count {
            self.insertItem(itemGenerator(), position: .top)
        }
    }
    
    private func loadMoreItems(_ numItemNeeded: Int, position: InsertPosition, completion: @escaping LoadBlock) {
        guard let itemGenerator = self.itemGenerator else {
            fatalError()
        }
        var items = [Element]()
        for _ in 0..<numItemNeeded {
            items.append(itemGenerator())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { //Simulate delay when load from server
            completion(items)
        }
    }

    public func insertItems(_ items: [Element], position: InsertPosition) {
        let n = items.count
        if position == .top {
            self.items.insert(contentsOf: items, at: 0)
            let shouldExpandWindow = self.itemsOffset == self.windowOffset
            self.itemsOffset -= n
            if shouldExpandWindow {
                self.windowOffset -= n
                self.windowCount += n
            } else {
                assertionFailure()
            }
        } else {
            let shouldExpandWindow = self.itemsOffset + self.items.count == self.windowOffset + self.windowCount
            if shouldExpandWindow {
                self.windowCount += n
            } else {
                assertionFailure()
            }
            self.items.append(contentsOf: items);
        }
    }
    
    public func insertItem(_ item: Element, position: InsertPosition) {
        if position == .top {
            self.items.insert(item, at: 0)
            let shouldExpandWindow = self.itemsOffset == self.windowOffset
            self.itemsOffset -= 1
            if shouldExpandWindow {
                self.windowOffset -= 1
                self.windowCount += 1
            }
        } else {
            let shouldExpandWindow = self.itemsOffset + self.items.count == self.windowOffset + self.windowCount
            if shouldExpandWindow {
                self.windowCount += 1
            }
            self.items.append(item)
        }
    }

    public func hasPrevious() -> Bool {
        return self.windowOffset > 0
    }

    public func hasMore() -> Bool {
        return self.windowOffset + self.windowCount < self.itemsOffset + self.items.count
    }

    public func loadPrevious(_ completion: EmptyBlock?) {
        guard self.isLoading == false else {
            return
        }
        self.isLoading = true
        print("\(#function)")
        
        let pSize = self.pageSize + Int(arc4random() % 10) //Test variable page size
        let nextWindowOffset = max(0, self.windowOffset - pSize)
        let messagesNeeded = self.itemsOffset - nextWindowOffset
        if messagesNeeded > 0 {
            let position = InsertPosition.top
            self.loadMoreItems(messagesNeeded, position: position) {[weak self] (items) in
                guard let me = self else { return }
                print("\(#function) finished: \(items.count)")
                me.insertItems(items, position: position)
                completion?()
                me.isLoading = false
            }
        }
    }
    
    public func loadPrevious() {
        let pSize = self.pageSize + Int(arc4random() % 10)
        let previousWindowOffset = self.windowOffset
        let previousWindowCount = self.windowCount
        let nextWindowOffset = max(0, self.windowOffset - pSize)
        let messagesNeeded = self.itemsOffset - nextWindowOffset
        if messagesNeeded > 0 {
            self.generateItems(messagesNeeded, position: .top)
        }
        let newItemsCount = previousWindowOffset - nextWindowOffset
        self.windowOffset = nextWindowOffset
        self.windowCount = previousWindowCount + newItemsCount
    }

    public func loadNext() {
        guard self.items.count > 0 else { return }
        
        let pSize = self.pageSize + Int(arc4random() % 10)
        
        let itemCountAfterWindow = self.itemsOffset + self.items.count - self.windowOffset - self.windowCount
        self.windowCount += min(pSize, itemCountAfterWindow)
    }

    @discardableResult
    public func adjustWindow(focusPosition: Double, maxWindowSize: Int) -> Bool {
        assert(0 <= focusPosition && focusPosition <= 1, "")
        guard 0 <= focusPosition && focusPosition <= 1 else {
            assert(false, "focus should be in the [0, 1] interval")
            return false
        }
        let sizeDiff = self.windowCount - maxWindowSize
        guard sizeDiff > 0 else { return false }
        self.windowOffset +=  Int(focusPosition * Double(sizeDiff))
        self.windowCount = maxWindowSize
        return true
    }
}
