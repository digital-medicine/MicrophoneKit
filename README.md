# MicrophoneKit

MicrophoneKit is a Swift framework designed to simplify audio recording and microphone handling in iOS applications.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/digital-medicine/MicrophoneKit.git", from: "1.0.0")
```

Or use Xcode:

1. Go to **File > Add Packages...**
2. Enter the repository URL:  
   `https://github.com/digital-medicine/MicrophoneKit`
3. Select the desired version.

## Usage

### Basic Setup

```swift
import MicrophoneKit

MicrophoneRecordingView(fileName: "testfilename", title: "Title") { url in
  print(url)
} closeAction: {
  print("closed")
}
```

## Requirements

- iOS 13.0+
- Swift 5.0+
## Authors

- [digital-medicine](https://github.com/digital-medicine)

---

> **Note**: This is a generic README template. Please update usage examples and installation instructions based on the actual implementation details in the repository.
