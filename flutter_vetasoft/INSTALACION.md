# 📦 Instalación de Dependencias - VetaSoft Flutter

## Dependencias requeridas

Las siguientes dependencias han sido agregadas al proyecto y son necesarias para el funcionamiento completo:

### 🌐 Networking
- **http** (^1.1.0) - Peticiones HTTP al backend
- **connectivity_plus** (^5.0.2) - Verificación de conectividad de red

### 💾 Almacenamiento de Datos
- **shared_preferences** (^2.2.2) - Almacenamiento local (tokens, preferencias del usuario)
- **intl** (^0.19.0) - Manejo y formateo de fechas/números

### 🎨 UI & Diseño
- **cupertino_icons** (^1.0.8) - Iconos de diseño iOS (Material Design)
- **cached_network_image** (^3.3.1) - Caché y carga optimizada de imágenes

### 🔄 State Management
- **provider** (^6.1.0) - Gestión de estado reactivo

### 🌍 Localización
- **flutter_localizations** (sdk: flutter) - Soporte para múltiples idiomas

---

## 🚀 Instalación

### Paso 1: Instalar todas las dependencias
```bash
cd flutter_vetasoft
flutter pub get
```

### Paso 2: Obtener dependencias específicas de plataforma

**Para iOS:**
```bash
cd ios
pod install
cd ..
```

**Para Android:**
No requiere pasos adicionales (gradle manejará las dependencias automáticamente)

### Paso 3: Verificar instalación
```bash
flutter pub outdated
flutter doctor
```

---

## 📋 Checklist antes de ejecutar

- [ ] Backend VetaSoft corriendo en `http://localhost:4000`
- [ ] `flutter pub get` completado exitosamente
- [ ] Base de datos PostgreSQL/Neon accesible
- [ ] Emulador/Dispositivo físico conectado

---

## ✅ Comando final para ejecutar

```bash
flutter run
```

---

## ⚠️ Notas importantes

1. **Token de autenticación**: Es necesario implementar un login para obtener el JWT token
2. **AndroidManifest.xml**: Necesita permisos de internet
3. **Info.plist (iOS)**: Necesita configuración de NSLocalNetworkUsageDescription

---

## 🔧 Solución de problemas

**Si `flutter pub get` falla:**
```bash
flutter clean
flutter pub cache clean
flutter pub get
```

**Si hay conflictos de dependencias:**
```bash
flutter pub upgrade
```

