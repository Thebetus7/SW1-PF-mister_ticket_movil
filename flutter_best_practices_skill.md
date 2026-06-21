# Guía de Buenas Prácticas y Solución de Errores Comunes en Flutter

Este documento sirve como anexo técnico y "skill" de desarrollo para evitar y solucionar errores comunes de compilación y compatibilidad de librerías modernas en proyectos Flutter (especialmente para entornos Android con Gradle Kotlin DSL).

---

## 1. Error de Desugaring (Java 8 APIs) en Android
### El Problema
Al usar plugins modernos que hacen llamadas a APIs de Java 8 o posterior (como `flutter_local_notifications`), Gradle arrojará el siguiente error:
```
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.
```

### La Solución
Habilitar **Core Library Desugaring** en el archivo `build.gradle.kts` (Kotlin DSL) de la aplicación (`android/app/build.gradle.kts`):

1. **Configurar las opciones de compilación**:
   ```kotlin
   android {
       ...
       compileOptions {
           sourceCompatibility = JavaVersion.VERSION_17
           targetCompatibility = JavaVersion.VERSION_17
           isCoreLibraryDesugaringEnabled = true // <-- Habilitar aquí
       }
   }
   ```

2. **Agregar la dependencia de desugaring**:
   ```kotlin
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
   }
   ```

---

## 2. Conflicto de Ambigüedad en Métodos (Ej: `bigLargeIcon`)
### El Problema
En librerías de notificaciones locales (`flutter_local_notifications` anteriores a la versión `17.0.0`), al compilar con un `compileSdk` alto (como el SDK 34 o 35), el compilador Java falla indicando:
```
error: reference to bigLargeIcon is ambiguous
both method bigLargeIcon(Bitmap) in BigPictureStyle and method bigLargeIcon(Icon) in BigPictureStyle match
```

### La Solución
Actualizar la dependencia en `pubspec.yaml` a una versión que use firmas de métodos explícitas compatibles con los nuevos SDK de Android (versiones `^17.0.0` o superiores):
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0 # O superior
```
Posteriormente, correr:
```bash
flutter pub get
```

---

## 3. Compatibilidad de Versiones en Android (Kotlin DSL)
Cuando utilices las últimas versiones de Firebase y Flutter, asegúrate de mantener actualizados tus Gradle Plugins.

En `android/settings.gradle.kts`:
```kotlin
plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false // Para Firebase
}
```

---

## 4. Estructura de Navegación y Vistas con Scroll
Al usar `CustomScrollView`, es crítico asegurar la consistencia del árbol de widgets:
- Utiliza **Slivers** directamente en la propiedad `slivers: [...]` (ej. `SliverAppBar`, `SliverToBoxAdapter`, `SliverList`).
- No intentes renderizar widgets tradicionales de layout (como `Padding` o `Column`) directamente en `slivers` sin envolverlos antes en un `SliverToBoxAdapter`.
- Recuerda siempre cerrar cada constructor de widget, llave, corchete o paréntesis en su nivel correspondiente para evitar errores de análisis sintáctico que cancelen el `kernel_snapshot`.
