# 📦 Inventarium

[![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Inventarium** es una aplicación móvil moderna de gestión de inventarios, pensada para brindar control total sobre productos, categorías y ubicaciones físicas. Funciona de manera offline para evitar la pérdida de datos y permite la generación de reportes exportables.

---

## ✨ Características principales

- 🛍️ Gestión de productos: SKU, stock, precios, código de barras.
- 💂 Categorías personalizables de productos.
- 📦 Asignación de ubicaciones físicas (estanterías, depósitos).
- ⚡ Funciona offline en cortes de energía o pérdida de conexión.
- 📊 Exportación de reportes seleccionados.

---

## 📱 Capturas de pantalla

> _Aquí podrías agregar screenshots de tu app_
> 
> Ejemplo:
> ```markdown
> ![Inventarium Home](assets/images/screenshot_home.png)
> ```

---

## 🚀 Instalación y configuración

1. **Clonar el repositorio:**

   ```bash
   git clone https://github.com/JimenaRW/inventarium-app.git
   cd inventarium
   ```

2. **Instalar dependencias:**

   ```bash
   flutter pub get
   ```

3. **Configurar el ícono de la app:**  
   Asegurate de tener tu logo en `assets/images/logo.png` y agrega en `pubspec.yaml`:

   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1

   flutter_icons:
     android: true
     ios: true
     image_path: "assets/images/logo.png"
     min_sdk_android: 21
   ```

   Ejecutá:

   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Correr la aplicación:**

   ```bash
   flutter run
   ```

---

## 💂 Estructura del proyecto

```
inventarium/
├── lib/
│   └── (código Dart)
├── assets/
│   └── images/
│       └── logo_inventarium.png
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Requisitos previos

- Flutter SDK 3.19 o superior
- Android Studio / Xcode
- Emulador o dispositivo físico para pruebas

---

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.  
Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autores

Desarrollado por **Emiliano Moretta, Cesar Montes, Jimena Witencamps, Julian Taiter y Alejandro Lee**.  
¡Contribuciones y sugerencias son bienvenidas!

---