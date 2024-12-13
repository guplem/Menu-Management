flutter build windows; 
$destinationFolder = "C:\Users\$env:USERNAME\Desktop\Menu Management"; 
New-Item -ItemType Directory -Force -Path $destinationFolder; 
Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination $destinationFolder -Recurse -Force;
Read-Host "Press Enter to exit"