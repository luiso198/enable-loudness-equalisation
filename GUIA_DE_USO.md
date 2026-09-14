# Guía Rápida de Uso

## 🌐 Opción 1: Descargar y ejecutar desde GitHub (Recomendado)

### En una sola línea:
Abre **PowerShell** y pega el siguiente comando:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; Invoke-WebRequest "https://raw.githubusercontent.com/luiso198/enable-loudness-equalisation/main/EnableLoudness.ps1" -OutFile "$HOME\EnableLoudness.ps1"; & "$HOME\EnableLoudness.ps1" -playbackDeviceName "Altavoces" -releaseTime 2
```

### O paso a paso:
```powershell
# 1. Descargar el script
Invoke-WebRequest "https://raw.githubusercontent.com/luiso198/enable-loudness-equalisation/main/EnableLoudness.ps1" -OutFile "$HOME\EnableLoudness.ps1"

# 2. Permitir la ejecución de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Ejecutar y activar (reemplaza "Altavoces" por el nombre de tu dispositivo si usas otro)
& "$HOME\EnableLoudness.ps1" -playbackDeviceName "Altavoces" -releaseTime 2
```

---

## 💻 Opción 2: Ejecutar localmente (si ya clonaste o descargaste la carpeta)

1. Abre PowerShell en la carpeta del proyecto.
2. Ejecuta:
```powershell
.\EnableLoudness.ps1
```
* Si tienes un solo dispositivo activo, se configurará automáticamente.
* Si tienes varios, el propio PowerShell te listará los dispositivos disponibles y te pedirá que ingreses el nombre.

*(Opcional) Ajustar velocidad para videojuegos (2 es el más rápido):*
```powershell
.\EnableLoudness.ps1 -playbackDeviceName "NombreDeTuDispositivo" -releaseTime 2
```

---

## 🔄 Alternar (Activar / Desactivar)
Para encender o apagar la mejora en cualquier momento:
```powershell
.\ToggleLoudness.ps1 -playbackDeviceName "NombreDeTuDispositivo"
```

---

## 📌 Notas importantes
* **Permanente:** Con ejecutarlo una sola vez queda guardado en el Registro de Windows para siempre (no necesitas repetirlo tras reiniciar).
* **Automático:** El script solicita permisos de Administrador y reinicia el servicio de audio por sí solo al terminar.




