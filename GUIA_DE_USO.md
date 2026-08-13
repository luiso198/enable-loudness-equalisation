# Guía Rápida de Uso

### 1. Permitir ejecución de scripts (solo la primera vez)
Abre PowerShell y ejecuta:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### 2. Activar Loudness Equalisation
Ejecuta el script:
```powershell
.\EnableLoudness.ps1
```
* Si tienes un solo dispositivo activo, se configurará automáticamente.
* Si tienes varios, el propio PowerShell te listará los dispositivos disponibles y te pedirá que ingreses el nombre.

*(Opcional) Si quieres ajustar la velocidad para videojuegos (2 es el más rápido):*
```powershell
.\EnableLoudness.ps1 -playbackDeviceName "NombreDeTuDispositivo" -releaseTime 2
```

---

### 3. Alternar (Activar / Desactivar)
Para encender o apagar la mejora en cualquier momento:
```powershell
.\ToggleLoudness.ps1 -playbackDeviceName "NombreDeTuDispositivo"
```

---

### 📌 Notas importantes
* **Permanente:** Con ejecutarlo una sola vez queda guardado en el Registro de Windows para siempre (no necesitas repetirlo tras reiniciar).
* **Automático:** El script solicita permisos de Administrador y reinicia el servicio de audio por sí solo al terminar.



