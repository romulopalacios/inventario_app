# Inventario Fácil

Una aplicación móvil Flutter para gestión de inventario dirigida a micro y pequeños negocios (tiendas, ferreterías, papelerías).

## 🎯 Propuesta de Valor

- **Funciona offline-first**: Los dueños no dependen de WiFi
- **Simple**: No es un ERP pesado que asusta
- **Puede exportar reportes** y mostrar alertas de stock bajo
- **Escalable** a varios negocios (modelo SaaS)

## 💰 Modelo de Negocio

- **Gratis**: Hasta 50 productos
- **Pro (4–8 USD/mes)**: Ilimitado + exportación PDF/Excel + multiusuario + lector de códigos de barra

## 🚀 Funcionalidades

### Fase 1 – MVP (versión mínima usable) ✅
- [x] CRUD de productos: nombre, código, categoría, precio compra, precio venta, stock, foto
- [x] Entradas y salidas de stock (ajustes, ventas, compras)
- [x] Reporte básico: total productos, valor del inventario
- [x] Modo offline con Drift (SQLite) y sincronización manual a Supabase/Firebase

### Fase 2 – Escalado (En desarrollo)
- [ ] Escaneo de código de barras (paquete mobile_scanner)
- [ ] Historial de movimientos por producto
- [ ] Exportar CSV/PDF
- [ ] Alertas de stock mínimo

### Fase 3 – Pro (Planificado)
- [ ] Multiusuario (roles: admin, vendedor)
- [ ] Dashboard de ventas y ganancias
- [ ] Integración de pagos (Stripe/MercadoPago) para cobrar suscripción
- [ ] Sincronización automática en background

## 🏗️ Arquitectura

- **Frontend**: Flutter 3.x
- **Estado**: Riverpod (simple y escalable)
- **Persistencia local**: Drift (SQLite)
- **Backend y sync**: Supabase (Postgres + Auth + Storage)
- **Fotos de producto**: Supabase Storage
- **Rutas**: go_router

## 📊 Modelo de Datos

### Local (Drift)

#### Products
- id (AutoIncrement)
- uuid (Unique)
- name (Text, required)
- code (Text, nullable)
- category (Text, nullable)
- purchasePrice (Real, default 0)
- salePrice (Real, default 0)
- stock (Integer, default 0)
- minStock (Integer, default 0)
- description (Text, nullable)
- imagePath (Text, nullable)
- createdAt (DateTime)
- updatedAt (DateTime)
- isDeleted (Boolean, default false)
- isSynced (Boolean, default false)

#### StockMovements
- id (AutoIncrement)
- uuid (Unique)
- productUuid (Text, foreign key)
- type (Text: 'entrada', 'salida', 'ajuste')
- quantity (Integer)
- previousStock (Integer)
- newStock (Integer)
- unitPrice (Real, nullable)
- reason (Text, nullable)
- notes (Text, nullable)
- createdAt (DateTime)
- isSynced (Boolean, default false)

#### Categories
- id (AutoIncrement)
- uuid (Unique)
- name (Text, required)
- description (Text, nullable)
- createdAt (DateTime)
- updatedAt (DateTime)
- isDeleted (Boolean, default false)
- isSynced (Boolean, default false)

#### UserSettings
- id (AutoIncrement)
- key (Text, unique)
- value (Text)
- createdAt (DateTime)
- updatedAt (DateTime)

## 🎨 UI / Pantallas

### Implementadas ✅
1. **Login / Registro** (Placeholder)
2. **Lista de productos**
   - Foto, nombre, stock, precio venta
   - Botón "+" → nuevo producto
   - Filtro por categoría / búsqueda
3. **Detalle de producto**
   - Info completa + historial de movimientos
   - Botón "Entrada" y "Salida" para ajustar stock
4. **Agregar/Editar producto**
   - Formulario completo con validaciones
5. **Agregar movimiento**
   - Seleccionar producto, tipo, cantidad, nota
6. **Reportes** (Placeholder)
7. **Configuración** (Placeholder)

### Home Screen
- Dashboard con estadísticas del inventario
- Alertas de stock bajo
- Accesos rápidos a funciones principales

## 🛠️ Tecnologías y Paquetes

### Estado
- `flutter_riverpod`: Gestión de estado

### Base de Datos Local
- `drift`: ORM para SQLite
- `drift_flutter`: Integración con Flutter
- `sqlite3_flutter_libs`: Librerías SQLite
- `path_provider`: Rutas del sistema
- `path`: Manipulación de rutas

### Backend y Sincronización
- `supabase_flutter`: Backend como servicio

### Navegación
- `go_router`: Enrutamiento declarativo

### Funcionalidades Futuras
- `mobile_scanner`: Códigos de barra (Fase 2)
- `pdf` + `printing`: Exportar PDF (Fase 2)
- `csv`: Exportar CSV (Fase 2)
- `image_picker`: Selección de imágenes

### Utilidades
- `uuid`: Generación de IDs únicos
- `intl`: Internacionalización y formato de números
- `shared_preferences`: Preferencias del usuario

## 🚦 Cómo Ejecutar

1. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

2. **Generar código Drift**:
   ```bash
   dart run build_runner build
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── database/
│   │   ├── database.dart          # Definición de base de datos Drift
│   │   └── database.g.dart        # Código generado por Drift
│   ├── providers/
│   │   └── database_providers.dart # Providers de Riverpod
│   ├── router/
│   │   └── app_router.dart        # Configuración de rutas
│   └── services/
│       └── inventory_service.dart  # Lógica de negocio
├── features/
│   ├── auth/
│   │   └── presentation/screens/
│   ├── home/
│   │   └── presentation/screens/
│   ├── products/
│   │   └── presentation/screens/
│   ├── reports/
│   │   └── presentation/screens/
│   └── settings/
│       └── presentation/screens/
└── main.dart                      # Punto de entrada de la aplicación
```

## 🔄 Flujo Offline → Online (Próxima versión)

1. Usuario crea/edita datos → guardado en Drift
2. Si hay internet y usuario está logueado → sincroniza con Supabase
3. Sincronización bidireccional:
   - Datos nuevos del servidor → se guardan en local
   - Datos nuevos/actualizados en local → se suben
4. Resolver conflictos por `updated_at` más reciente

## 🎉 Estado Actual

La aplicación está en **Fase 1 - MVP** con las siguientes características implementadas:

- ✅ Gestión completa de productos (CRUD)
- ✅ Control de inventario con entradas, salidas y ajustes
- ✅ Base de datos local con Drift
- ✅ Interfaz de usuario intuitiva
- ✅ Alertas de stock bajo
- ✅ Estadísticas básicas del inventario
- ✅ Búsqueda y filtrado de productos
- ✅ Historial de movimientos

### Próximos pasos:
1. Implementar sincronización con Supabase
2. Agregar funcionalidad de escaneo de códigos de barra
3. Exportación de reportes PDF/CSV
4. Sistema de autenticación completo

---

**Inventario Fácil** - Simplificando la gestión de inventario para pequeños negocios 📦✨
