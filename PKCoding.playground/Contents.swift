import Cocoa

extension Data {
  struct HexEncodingOptions: OptionSet {
    let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
  }
  
  func hexEncodedString(options: HexEncodingOptions = []) -> String {
    let format = options.contains(.upperCase) ? "0x%02hhX" : "0x%02hhx"
    return self.map { String(format: format, $0) }.joined(separator: ", ")
  }
  
  func read<T>(fromOffset offset: inout Data.Index) -> T {
    let start = offset
    offset = offset.advanced(by: MemoryLayout<T>.stride)
    
    // TODO: check bounds
    // TODO: check & adopt how swift-nio-ssh parses these fields / writes out binary data
    
    return subdata(in: start..<offset).reversed().withUnsafeBytes { $0.load(as: T.self) }
  }
  
  func readStringBytes(fromOffset offset: inout Data.Index) -> Data {
    // read length of string
    let strlen: UInt32 = read(fromOffset: &offset)
    
    // TODO: check bounds
    let begin = offset
    offset += Int(strlen)
    return subdata(in: begin..<offset)
  }
  
  func readString(fromOffset offset: inout Data.Index) -> String? {
    String(decoding: readStringBytes(fromOffset: &offset), as: UTF8.self)
  }
}

// TODO: propper return type
struct Decoded {
  var name: String
  var identifier: String
  var q: Data
}
func decode(raw: String) -> Decoded? {
  guard let data = Data(base64Encoded: raw) else { return nil }
  var index = data.startIndex
  
  guard let name = data.readString(fromOffset: &index),
        let identifier = data.readString(fromOffset: &index)
  else { return nil }
  let q = data.readStringBytes(fromOffset: &index)
  
  return Decoded(name: name, identifier: identifier, q: q)
}

if let decoded = decode(raw: "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGfBeJN9OSUXtxRR5pIDskxoxYF8nJXfsCJc5752gJxvQOwOGgma2bGO9dW3cfYVxr+s/3bEgHHB3l+3XE2F1sc=") {
  let myQ: [UInt8] = [4, 103, 193, 120, 147, 125, 57, 37, 23, 183, 20, 81, 230, 146, 3, 178, 76, 104, 197, 129, 124, 156, 149, 223, 176, 34, 92, 231, 190, 118, 128, 156, 111, 64, 236, 14, 26, 9, 154, 217, 177, 142, 245, 213, 183, 113, 246, 21, 198, 191, 172, 255, 118, 196, 128, 113, 193, 222, 95, 183, 92, 77, 133, 214, 199]

  print(decoded)
  print(decoded.q.map { $0 } == myQ)
}
