# App Flutter – Consumo de API con Manejo de Secretos (.env)

## Descripción

Esta aplicación Flutter demuestra cómo **consumir una API REST de forma segura**, utilizando un archivo `.env` para proteger las claves API y credenciales sensibles.  
El proyecto implementa una interfaz sencilla para mostrar información obtenida desde **OpenWeatherMap** (clima) o **NewsAPI** (noticias), manejando correctamente los estados de carga, error y resultados vacíos.

La app fue probada exitosamente en un **dispositivo Android físico (Moto G9 Play)**.

---

## Objetivo del proyecto

- Aprender a consumir APIs REST de forma segura en Flutter.
- Aplicar buenas prácticas de seguridad (manejo de secretos, validación de entrada y control de errores).
- Mostrar los datos obtenidos mediante una interfaz visual amigable.

---

## Funcionalidades principales

✅ Consumo de datos desde una API REST (clima o noticias).  
✅ Manejo de variables de entorno con `flutter_dotenv`.  
✅ Manejo de estados: cargando, éxito, error y vacío.  
✅ Control de errores HTTP (timeouts, 404, 429, etc.).  
✅ UI moderna con `Material Design`.  
✅ Probada en dispositivo físico Android.

---

## Estructura del proyecto

lib/
├── main.dart # Punto de entrada principal
├── services/
│ └── api_service.dart # Lógica de conexión y parseo JSON
├── screens/
│ └── home_screen.dart # Pantalla principal con UI reactiva
.env # Archivo con claves privadas (no subir a GitHub)
pubspec.yaml # Configuración y dependencias
README.md # Este archivo


---

## Archivo `.env`

Crea un archivo en la raíz del proyecto llamado `.env` y coloca tu API key, por ejemplo:

```env
OPENWEATHER_API_KEY=tu_api_key_aqui
