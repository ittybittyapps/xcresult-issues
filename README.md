# xcresult-issues

A Swift command line tool that parses `xcresulttool` JSON output and report on issues found.

Note that this tool just reads the `ResultIssueSummaries` from the top of the xcresult JSON and doesn't get all issues from the xcodebuild log output. This is usually enough in most cases but it might not find all issues that occured in your build (script build phases, linker issues, etc).

## Example Usage

```
xcrun xcresulttool get --format json --path MyProject.xcresult | xcresult-issues --format github-actions-logging
```

The above command takes the results written out by `xcresulttool` and formats them as log messages for GitHub Actions.

## Suppressing Warnings & Warnings as Errors

Warnings can be supressed (or raised up to errors) using regular expressions.  To do this you can supply a YML file on the command line (via the `-w` argument) that contains regularexpress matching rules.  The format is as follows:

```yaml
rules:
  - regex: ^Main actor-isolated static property '(_previews|_platform)' cannot be used to satisfy nonisolated protocol requirement$
    action: suppress
  - regex: ^Cannot form key path that captures non-sendable type 'KeyPath<[\w\.]+, [\w\.]+>'$
    action: error
```

The available actions are `suppress` to suppress the output of the warning and `error` to turn the warning into an error.

## Exit Code

When the `-e` command-line flag is used, if `xcresult-issues` finds any errors or test failures it will exit with a non-zero exit code.
