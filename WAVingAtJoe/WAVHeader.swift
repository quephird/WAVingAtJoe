//
//  WAVHeader.swift
//  WAVingAtJoe
//
//  Created by Danielle Kefford on 10/14/24.
//

import Foundation

extension Numeric {
    var data: Data {
        return withUnsafePointer(to: self) { copy in
            Data(bytes: copy, count: MemoryLayout<Self>.size)
        }
    }
}

struct WAVHeader {
    public var fileTypeChunkID: [UInt8] = [0x52, 0x49, 0x46, 0x46]
    public var fileSize: UInt32
    public var fileFormatID: [UInt8] = [0x57, 0x41, 0x56, 0x45]
    public var formatChunkID: [UInt8] = [0x66, 0x6D, 0x74, 0x20]
    public var chunkSize: UInt32
    public var audioFormat: UInt16
    public var numberOfChannels: UInt16
    public var sampleRate: UInt32
    public var byteRate: UInt32
    public var blockAlignment: UInt16
    public var bitsPerSample: UInt16
    public var dataChunkID: [UInt8] = [0x64, 0x61, 0x74, 0x61]
    public var dataSize: UInt32

    var data: Data {
        var temp = Data(self.fileTypeChunkID)
        temp.append(self.fileSize.data)
        temp.append(Data(self.fileFormatID))
        temp.append(Data(self.formatChunkID))
        temp.append(self.chunkSize.data)
        temp.append(self.audioFormat.data)
        temp.append(self.numberOfChannels.data)
        temp.append(self.sampleRate.data)
        temp.append(self.byteRate.data)
        temp.append(self.blockAlignment.data)
        temp.append(self.bitsPerSample.data)
        temp.append(Data(self.dataChunkID))
        temp.append(self.dataSize.data)
        return temp
    }
}
