import Foundation

extension String {
    
    func levenshteinDistance(_ string: String) -> Int {
        let empty = Array<Int>(repeating:0, count: self.count)
        var last = [Int](0...self.count)
        
        for (i, testLetter) in string.enumerated() {
            var cur = [i + 1] + empty
            for (j, keyLetter) in self.enumerated() {
                cur[j + 1] = testLetter == keyLetter ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last.last!
    }
}
