---
description: Build the Helix project using xcodebuild
---

To build the Helix project, run:

```bash
xcodebuild -project Helix.xcodeproj -scheme Helix -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

// turbo
If `xcbeautify` is installed, you can use:

```bash
set -o pipefail && xcodebuild -project Helix.xcodeproj -scheme Helix -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build | xcbeautify
```
