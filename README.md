# ZQFlexibleTool

`ZQFlexibleTool` is a CocoaPods-ready UIKit component library written in Swift.

## Modules

- `ZQNavigationBar` and `ZQNavigationController`
- `ZQTabBarController` with red-dot / badge support
- `ZQFileManagerService` for sandbox file operations
- `ZQPermissionManager` for unified permission checking and requesting
- `ZQBaseViewController` with a TangramKit-powered scrollable content container
- `ZQDailyTool` with common Swift utilities and extensions

## Install

```ruby
pod 'ZQFlexibleTool'
```

`ZQFlexibleTool` depends on `TangramKit`.
Minimum iOS version: 13.0.

## Notes

- The repository URL, homepage, and author in `ZQFlexibleTool.podspec` should be replaced with your real publication information before pushing to CocoaPods.
- The base view controller uses TangramKit's `TGLinearLayout` inside a scroll view so content can grow vertically and scroll automatically.

## Quick Start

```swift
final class HomeViewController: ZQBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "首页"
        let label = UILabel()
        label.text = "Hello ZQFlexibleTool"
        addContentSubview(label)
    }
}
```

## Example

The `Example/ZQFlexibleToolExample` folder contains a UIKit demo app that shows:

- custom navigation bar behavior
- tab bar red-dot support
- file read/write/delete
- permission request and settings jump
- daily tool extensions

To run it in Xcode:

1. Open or generate `Example/ZQFlexibleToolExample.xcodeproj`.
2. Run `pod install` inside `Example/`.
3. Open the generated workspace and run the `ZQFlexibleToolExample` target.
