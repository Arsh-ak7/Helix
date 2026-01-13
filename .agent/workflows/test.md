---
description: Run unit tests for the Helix project
---

To run tests for the Helix project, run:

```bash
xcodebuild -project Helix.xcodeproj -scheme Helix -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' test
```

// turbo
If `xcbeautify` is installed, you can use:

```bash
set -o pipefail && xcodebuild -project Helix.xcodeproj -scheme Helix -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' test | xcbeautify
```
