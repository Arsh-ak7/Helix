---
description: Run unit tests for the Helix project with xcbeautify
---

To run tests for the Helix project with clean logs, run:

```bash
set -o pipefail && xcodebuild -project Helix.xcodeproj -scheme Helix -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' test | xcbeautify
```

// turbo
If `xcbeautify` is not installed, use the raw command:

```bash
xcodebuild -project Helix.xcodeproj -scheme Helix -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' test
```
