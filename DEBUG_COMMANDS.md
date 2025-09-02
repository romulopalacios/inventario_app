# Debugging Profesional - Comandos y Scripts

## 🚀 Scripts de Flutter Development

### Debug con logs detallados
```powershell
flutter run -d 2201117SL --debug --verbose
```

### Debug con observatory (para performance profiling)
```powershell
flutter run -d 2201117SL --debug --enable-vmservice
```

### Profile mode (para testing de performance)
```powershell
flutter run -d 2201117SL --profile
```

### Release mode (testing final)
```powershell
flutter run -d 2201117SL --release
```

### Debug con hot reload automático
```powershell
flutter run -d 2201117SL --hot
```

## 🔍 Comandos de Análisis

### Análisis completo del código
```powershell
flutter analyze --verbose
```

### Testing con coverage
```powershell
flutter test --coverage
```

### Performance profiling
```powershell
flutter run --profile --trace-startup --verbose-logging
```

### Build con información detallada
```powershell
flutter build apk --debug --verbose
```

## 📱 Android Debugging

### Logs de Android en tiempo real
```powershell
adb -s 2201117SL logcat -v time | findstr "flutter\|dart\|inventario"
```

### Información del dispositivo
```powershell
adb -s 2201117SL shell getprop | findstr "ro.build\|ro.product"
```

### Limpiar logs de Android
```powershell
adb -s 2201117SL logcat -c
```

### Ver procesos de la app
```powershell
adb -s 2201117SL shell ps | findstr "inventario"
```

## 🛠 Debugging Avanzado

### Generar build con símbolos de debug
```powershell
flutter build apk --debug --split-debug-info=./debug-symbols
```

### Inspector de widgets
```powershell
flutter run -d 2201117SL --debug --enable-vmservice
# Luego abrir: http://localhost:9100
```

### Memory profiling
```powershell
flutter run -d 2201117SL --profile --trace-startup
```

## 🔧 Troubleshooting Commands

### Limpiar completamente
```powershell
flutter clean
flutter pub get
flutter pub deps
```

### Verificar configuración
```powershell
flutter doctor -v
flutter config
```

### Regenerar archivos nativos
```powershell
flutter create --platforms android .
```

### Verificar dependencias
```powershell
flutter pub deps --style=compact
flutter pub outdated
```

## 📊 Monitoring en Tiempo Real

### CPU y memoria (requiere profile mode)
```powershell
flutter run -d 2201117SL --profile --trace-startup --verbose-logging
```

### Network debugging
```powershell
flutter run -d 2201117SL --debug --observatory-port=9100
```

## 🐛 Error Debugging

### Capturar stack traces completos
```powershell
flutter run -d 2201117SL --debug --verbose --enable-vmservice --observatory-port=9100
```

### Logging específico por tag
```powershell
adb -s 2201117SL logcat -v time -s "flutter:*,dart:*"
```

### Debug de assets
```powershell
flutter run -d 2201117SL --debug --verbose --trace-startup
```

## 📋 Uso de las herramientas de debug integradas

### En el código Dart:
```dart
// Logging profesional
Logger.debug('Debug message');
Logger.error('Error message', error: e, stackTrace: st);
Logger.info('Info message', tag: 'DATABASE');

// Performance measurement
DebugTools.startTimer('operation');
// ... código ...
DebugTools.stopTimer('operation');

// Inspección de objetos
DebugTools.inspect(myObject, name: 'MyObject');

// Checkpoints
DebugTools.checkpoint('After API call', {
  'status': 'success',
  'data_length': data.length,
});
```

### Debug overlay en UI:
- El overlay aparece automáticamente en debug mode
- Botón flotante naranja en la esquina superior derecha
- Muestra información del dispositivo y logs recientes
- Botones para limpiar logs y ver información de memoria

## 🎯 Quick Debug Session

1. **Abrir app en debug:**
   ```powershell
   flutter run -d 2201117SL --debug --verbose
   ```

2. **En otra terminal, monitoring:**
   ```powershell
   adb -s 2201117SL logcat -v time | findstr "flutter\|InventarioApp"
   ```

3. **Hot reload con R en consola**
4. **Hot restart con Shift+R en consola**
5. **Quit con Q en consola**

## 🔄 Comandos de CI/CD

### Build de testing
```powershell
flutter build apk --debug --verbose --build-name=debug-$(Get-Date -Format "yyyyMMdd-HHmm")
```

### Testing automatizado
```powershell
flutter test --coverage --verbose
flutter analyze --fatal-infos
```
