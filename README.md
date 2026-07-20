# Menu-Management

## Development Setup

Install NuGet CLI (required by the `audioplayers_windows` plugin to fetch native dependencies):

```
winget install Microsoft.NuGet
nuget sources add -Name nuget.org -Source https://api.nuget.org/v3/index.json
```

The second command adds the default package source, which may not be configured automatically after installation.

### Git hooks (optional but recommended)

This repo uses [lefthook](https://github.com/evilmartians/lefthook) to run a format check and `flutter analyze` before each commit, the same checks that run in CI. Install it once per clone:

```
winget install evilmartians.lefthook
lefthook install
```

`lefthook install` writes the git hooks into `.git/hooks`. After that, every `git commit` runs the checks automatically. If you skip this, CI still runs the same checks on every pull request.

## Release

To create a new release of the App execute in windows the file named `build_and_copy.bat`.
This will create a new portable release and copy it to the desktop.

Alternativelly you can just run the following command from the project's root:
```
flutter build windows; $destinationFolder = "C:\Users\$env:USERNAME\Desktop\Menu Management"; New-Item -ItemType Directory -Force -Path $destinationFolder; Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination $destinationFolder -Recurse -Force
```