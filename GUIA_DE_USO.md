# Guía Rápida de Uso

## 🌐 Opción 1: Descargar y ejecutar desde GitHub (Recomendado)

### En una sola línea:
Abre **PowerShell** y pega el siguiente comando:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; Invoke-WebRequest "https://raw.githubusercontent.com/luiso198/enable-loudness-equalisation/main/EnableLoudness.ps1" -OutFile "$HOME\EnableLoudness.ps1"; & "$HOME\EnableLoudness.ps1" -releaseTime 2
```
* Si tienes un solo dispositivo activo, se configurará automáticamente.
* Si tienes varios dispositivos, el terminal te mostrará la lista para que elijas tu dispositivo directamente ingresando su número (ej. `1`, `2`, etc.).

---

### O paso a paso:
```powershell
# 1. Descargar el script
Invoke-WebRequest "https://raw.githubusercontent.com/luiso198/enable-loudness-equalisation/main/EnableLoudness.ps1" -OutFile "$HOME\EnableLoudness.ps1"

# 2. Permitir la ejecución de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Ejecutar y activar (te permitirá seleccionar el dispositivo en pantalla)
& "$HOME\EnableLoudness.ps1" -releaseTime 2
```

---

## 💻 Opción 2: Ejecutar localmente (si ya clonaste o descargaste la carpeta)

1. Abre PowerShell en la carpeta del proyecto.
2. Ejecuta:
```powershell
.\EnableLoudness.ps1 -releaseTime 2
```
* Si tienes un solo dispositivo activo, se configurará automáticamente.
* Si tienes varios, te listará los dispositivos numerados y podrás escribir el número o nombre directamente en el terminal.

*(Opcional) Si deseas especificar el dispositivo directamente sin pasar por el menú:*
```powershell
.\EnableLoudness.ps1 -playbackDeviceName "NombreDeTuDispositivo" -releaseTime 2
```

---

## 🔄 Alternar (Activar / Desactivar)
Para encender o apagar la mejora en cualquier momento:
```powershell
.\ToggleLoudness.ps1
```
*(Al igual que el activador, si tienes varios dispositivos te permitirá elegir cuál alternar desde el terminal, o puedes pasar `-playbackDeviceName "Nombre"`).*

---

## 📌 Notas importantes
* **Permanente:** Con ejecutarlo una sola vez queda guardado en el Registro de Windows para siempre (no necesitas repetirlo tras reiniciar).
* **Automático:** El script solicita permisos de Administrador y reinicia el servicio de audio por sí solo al terminar.




