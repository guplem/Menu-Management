# Menu-Management

To create a new release of the App execute in windows the file named `build_and_copy.bat`.
This will create a new portable release and copy it to the desktop.

Alternativelly you can just run the following command from the project's root:
```
flutter build windows; $destinationFolder = "C:\Users\$env:USERNAME\Desktop\Menu Management"; New-Item -ItemType Directory -Force -Path $destinationFolder; Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination $destinationFolder -Recurse -Force
```