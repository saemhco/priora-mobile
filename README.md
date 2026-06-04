# Priora Mobile 📱

Este es el repositorio de la aplicación móvil de **Priora**, construida con **Expo** (v56) y **React Native**.

---

## 🚀 Requisitos Previos

Asegúrate de tener instalado:
* **Node.js** (LTS recomendado)
* **Bun** o **Yarn**
* Para compilar nativo:
  * **Android:** Android Studio y Android SDK configurado.
  * **iOS:** Xcode (solo macOS) y CocoaPods.

---

## 📦 Instalación de Dependencias

Ejecuta uno de los siguientes comandos en la raíz del proyecto para instalar las dependencias:

### Con Bun (Recomendado)
```bash
bun install
```

### Con Yarn
```bash
yarn install
```

---

## 💻 Levantamiento y Desarrollo

Para levantar el servidor de desarrollo de Metro:

### Con Bun
```bash
bun run start
```

### Con Yarn
```bash
yarn start
```

Una vez que Metro esté corriendo, puedes presionar:
* `a` para abrir en el emulador de Android.
* `i` para abrir en el simulador de iOS (macOS).
* `w` para abrir en el navegador web.

---

## ⚙️ Generación de Carpetas Nativas (Prebuild)

Si las carpetas `/android` o `/ios` no están presentes en el repositorio, debes generarlas ejecutando:

```bash
npx expo prebuild
```

---

## 🛠️ Ejecución y Compilación en Nativo

Este proyecto utiliza compilaciones nativas de desarrollo (`expo-dev-client`). Una vez generadas las carpetas `/android` e `/ios`:

### Desde la Consola (CLI)

Para compilar e instalar la app nativa en un emulador o dispositivo físico conectado:

#### Android
```bash
# Con Bun
bun run android

# Con Yarn o NPX
npx expo run:android
```

#### iOS (solo macOS)
```bash
# Con Bun
bun run ios

# Con Yarn o NPX
npx expo run:ios
```

### Usando las Herramientas Nativas (IDEs)

Si prefieres compilar, depurar o firmar la aplicación directamente desde los entornos de desarrollo oficiales:

#### Android Studio
1. Abre **Android Studio**.
2. Selecciona **Open an existing project**.
3. Elige la carpeta `android/` en la raíz de este proyecto.
4. Espera a que termine la sincronización de Gradle y haz clic en **Run** (botón de Play).

#### Xcode (solo macOS)
1. Ve al directorio `ios/` del proyecto.
2. Abre el espacio de trabajo de Xcode usando el archivo `.xcworkspace` (no el `.xcodeproj`):
   ```bash
   open ios/prioraapp.xcworkspace
   ```
3. Selecciona tu simulador o dispositivo de destino y presiona `Cmd + R` para compilar e iniciar.

---

## 📂 Estructura del Proyecto

* `src/app/`: Enrutamiento basado en archivos con Expo Router.
  * `_layout.tsx`: Layout raíz y proveedor de temas.
  * `index.tsx`: Entrada principal (redirige a onboarding).
  * `onboarding.tsx`: Pantalla de bienvenida principal.
* `src/components/`: Componentes UI reutilizables y modulares.
  * `ui/button.tsx`: Botón personalizable (sólido y contorneado).
  * `ui/glass-badge.tsx`: Credencial flotante con efecto cristalino (glassmorphism).
* `src/constants/theme.ts`: Paleta de colores e identidades visuales para modos claro y oscuro.
