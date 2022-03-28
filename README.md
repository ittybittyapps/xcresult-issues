# xcresult-issues

A Swift command line tool that parses `xcresulttool` JSON output and report on issues found.

## Example Usage

```
xcrun xcresulttool get --format json --path MyProject.xcresult | xcresult-issues --format github-actions-logging
```

The above command takes the results written out by `xcresulttool` and formats them as log messages for GitHub Actions.
