//
//  Waving.swift
//  WAVingAtJoe
//
//  Created by Danielle Kefford on 10/14/24.
//

import Foundation

@main
struct MakeWAV {
    private var fileName: String
    private var wavData = Data()
    private var wavSize = 0
    private var accumulator = 0.0

    init(fileName: String) {
        self.fileName = fileName
        self.writeInitialHeader()
    }

    static func main() {
        let args = CommandLine.arguments.dropFirst()
        if args.count != 1 {
            usage()
            exit(2)
        }

        guard let fileName = args.first else {
            usage()
            exit(2)
        }

        var instance = MakeWAV(fileName: fileName)
        for frequency in [440.0, 495.0, 550.0, 586.7, 660.0, 733.3, 825.0, 880.0] {
            instance.writeTone(duration: 0.5, frequency: frequency)
        }
        instance.saveFile()
    }

    private static func usage() {
        print("Usage: makewav filename.wav")
    }

    mutating private func writeInitialHeader() {
        let initialHeader = WAVHeader(fileSize: 0,
                                      chunkSize: 16,
                                      audioFormat: 1,
                                      numberOfChannels: 1,
                                      sampleRate: 44100,
                                      byteRate: 88200,
                                      blockAlignment: 16,
                                      bitsPerSample: 16,
                                      dataSize: 0)
        self.wavData.append(initialHeader.data)
    }

    mutating private func writeTone(duration: Double,
                                    frequency: Double) {
        var sampleBuffer: [Int16] = [Int16](repeating: 0, count: 4096)

        var sampleCount = Int(duration * 44100.0)
        let delta = (2.0 * frequency)/44100.0
        let numBlocks = (sampleCount + 4095)/4096

        var block = 0
        while block < numBlocks {
            let numSamples = sampleCount < 4096 ? sampleCount : 4096

            for i in 0 ..< numSamples {
                let sample = sin(Double.pi * self.accumulator)
                sampleBuffer[i] = Int16(32767.0 * sample)
                self.accumulator += delta
                if self.accumulator > 1.0 {
                    self.accumulator -= 2.0
                }
            }

            let size = MemoryLayout<Int16>.size * numSamples
            sampleBuffer.withUnsafeBytes { bufferPointer in
                self.wavData.append(contentsOf: bufferPointer[..<size])
            }
            self.wavSize += size

            block += 1
            sampleCount -= 4096
        }
    }

    mutating private func finalizeHeader() {
        wavData.withUnsafeMutableBytes { rawBufferPointer in
            // We're kinda cheating here, taking advantage of the fact that the
            // fields that we need to mutate are on 32-bit boundaries, and so we
            // access the buffer (well, it's header at any rate) as if it were c
            // omposed of elements of type UInt32.
            rawBufferPointer.withMemoryRebound(to: UInt32.self) { bufferPointer in
                // Here, we know that the size of the header is 44 bytes;
                // afaik, there is no reliable way to computer this in Swift.
                let actualFileSize = UInt32(44 - 8 + self.wavSize)
                let actualDataSize = UInt32(self.wavSize)

                bufferPointer[1] = actualFileSize
                bufferPointer[10] = actualDataSize
            }
        }
    }

    mutating private func saveFile() {
        self.finalizeHeader()
        do {
            let desktopDirectoryUrl = try FileManager.default.url(for: .desktopDirectory,
                                                                  in: .userDomainMask,
                                                                  appropriateFor: nil,
                                                                  create: false)
            let fileUrl = desktopDirectoryUrl.appendingPathComponent(self.fileName)
            try self.wavData.write(to: fileUrl)
        } catch {
            print(error)
            exit(2)
        }
    }
}
