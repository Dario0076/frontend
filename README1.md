# Descripción de Microservicios - Sistema de Inventario Automatizado

## 1. UsuariosService (Puerto 8083)

### 📋 Nombre y Función
- **Nombre**: Servicio de Gestión de Usuarios y Autenticación
- **Función Principal**: Manejo de autenticación, autorización y gestión de usuarios del sistema
- **Responsabilidades**:
  - Autenticación de usuarios con credenciales
  - Generación y validación de tokens JWT
  - Gestión de roles y permisos (ADMIN, USER)
  - CRUD de usuarios del sistema
  - Control de sesiones y seguridad

### 🔄 Entradas y Salidas

#### Entradas:
- **Credenciales de login** (username, password)
- **Datos de registro** (username, email, password, rol)
- **Tokens JWT** para validación de sesiones
- **Solicitudes de información** de perfil de usuario

#### Salidas:
- **Tokens JWT** con información de usuario y rol
- **Datos de usuario** (sin contraseña) para perfil
- **Listas de usuarios** para administración
- **Códigos de estado** de autenticación (éxito/fallo)
- **Mensajes de error** de validación

#### Ejemplo de Flujo:
```json
// Entrada - Login
{
  "username": "admin",
  "password": "admin123"
}

// Salida - Token JWT
{
  "token": "eyJhbGciOiJIUzUxMiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwicm9sIjoiQURNSU4ifQ...",
  "usuario": {
    "id": 1,
    "username": "admin",
    "email": "admin@admin.com",
    "rol": "ADMIN"
  },
  "message": "Login exitoso"
}
```

### 🌐 Comunicación entre Microservicios
- **Protocolo**: REST API (HTTP/HTTPS)
- **Formato**: JSON para intercambio de datos
- **Autenticación**: JWT Bearer Token
- **Comunicación Saliente**: No realiza llamadas a otros microservicios (es el proveedor de autenticación)
- **Comunicación Entrante**: Todos los demás servicios validan tokens contra este servicio

---

## 2. ProductosService (Puerto 8084)

### 📋 Nombre y Función
- **Nombre**: Servicio de Gestión de Productos y Categorías
- **Función Principal**: Administración del catálogo completo de productos e inventario
- **Responsabilidades**:
  - CRUD completo de productos
  - Gestión de categorías de productos
  - Filtros avanzados y búsqueda de productos
  - Validación de datos de productos
  - Mantenimiento de relaciones producto-categoría

### 🔄 Entradas y Salidas

#### Entradas:
- **Datos de productos** (nombre, descripción, precio, cantidad, categoría)
- **Parámetros de filtros** (categoría, texto de búsqueda)
- **Datos de categorías** (nombre, descripción)
- **IDs** para consultas específicas
- **Tokens JWT** para autorización

#### Salidas:
- **Listas de productos** con información completa
- **Datos de categorías** disponibles
- **Productos filtrados** según criterios
- **Confirmaciones** de operaciones CRUD
- **Mensajes de error** de validación

#### Ejemplo de Flujo:
```json
// Entrada - Crear Producto
{
  "nombre": "Laptop Dell XPS 13",
  "descripcion": "Laptop ultrabook Dell XPS 13 pulgadas",
  "precio": 1299.99,
  "cantidad": 25,
  "categoria": {"id": 1}
}

// Salida - Producto Creado
{
  "id": 5,
  "nombre": "Laptop Dell XPS 13",
  "descripcion": "Laptop ultrabook Dell XPS 13 pulgadas",
  "precio": 1299.99,
  "cantidad": 25,
  "categoria": {
    "id": 1,
    "nombre": "Electrónicos",
    "descripcion": "Dispositivos electrónicos y tecnología"
  },
  "activo": true,
  "fechaCreacion": "2024-09-09T10:30:00"
}
```

### 🌐 Comunicación entre Microservicios
- **Protocolo**: REST API (HTTP/HTTPS)
- **Formato**: JSON para intercambio de datos
- **Comunicación Saliente**: 
  - Consulta a UsuariosService para validación de JWT
- **Comunicación Entrante**: 
  - StockService consulta información de productos
  - MovimientoService valida existencia de productos
  - Frontend consume todos los endpoints de productos

---

## 3. StockService (Puerto 8081)

### 📋 Nombre y Función
- **Nombre**: Servicio de Control de Inventario y Stock
- **Función Principal**: Gestión de niveles de inventario y sistema de alertas
- **Responsabilidades**:
  - Control de cantidades actuales de productos
  - Gestión de umbrales mínimos personalizados
  - Sistema de alertas por stock bajo
  - Sincronización con movimientos de inventario
  - Reportes de estado de inventario

### 🔄 Entradas y Salidas

#### Entradas:
- **IDs de productos** para consultas de stock
- **Umbrales mínimos** configurables por producto
- **Actualizaciones de cantidad** desde movimientos
- **Parámetros de filtros** para búsqueda de stock
- **Tokens JWT** para autorización

#### Salidas:
- **Niveles de stock actual** por producto
- **Alertas de stock bajo** con detalles
- **Listas de inventario** completo o filtrado
- **Confirmaciones** de actualización de stock
- **Indicadores visuales** de estado (normal/bajo/crítico)

#### Ejemplo de Flujo:
```json
// Entrada - Actualizar Umbral
{
  "productoId": 1,
  "umbralMinimo": 15
}

// Salida - Stock Actualizado
{
  "id": 1,
  "productoId": 1,
  "nombreProducto": "Acer Nitro V15",
  "cantidadActual": 40,
  "umbralMinimo": 15,
  "stockBajo": false,
  "diferencia": 25,
  "estadoStock": "NORMAL",
  "fechaUltimaActualizacion": "2024-09-09T11:15:00"
}

// Salida - Alertas de Stock Bajo
[
  {
    "productoId": 3,
    "nombreProducto": "Cable HDMI 2m",
    "cantidadActual": 3,
    "umbralMinimo": 10,
    "diferencia": -7,
    "prioridad": "ALTA",
    "diasSinReposicion": 5
  }
]
```

### 🌐 Comunicación entre Microservicios
- **Protocolo**: REST API (HTTP/HTTPS)
- **Formato**: JSON para intercambio de datos
- **Comunicación Saliente**: 
  - Consulta a ProductosService para obtener nombres de productos
  - Consulta a UsuariosService para validación de JWT
- **Comunicación Entrante**: 
  - MovimientoService actualiza stock tras registrar movimientos
  - Frontend consulta niveles de stock y alertas

---

## 4. MovimientoService (Puerto 8090)

### 📋 Nombre y Función
- **Nombre**: Servicio de Registro de Movimientos y Trazabilidad
- **Función Principal**: Auditoría completa de entradas y salidas de inventario
- **Responsabilidades**:
  - Registro detallado de todos los movimientos de inventario
  - Trazabilidad completa con usuario responsable
  - Historial temporal de cambios de stock
  - Validación de movimientos antes de registro
  - Sincronización automática con StockService

### 🔄 Entradas y Salidas

#### Entradas:
- **Datos de movimiento** (producto, usuario, tipo, razón, cantidad)
- **Información contextual** (precios, observaciones)
- **Parámetros de filtros** para consultas históricas
- **Rangos de fechas** para reportes temporales
- **Tokens JWT** para autorización

#### Salidas:
- **Registros de movimientos** con trazabilidad completa
- **Historial por producto** o usuario
- **Reportes de auditoría** con filtros temporales
- **Confirmaciones** de registro exitoso
- **Métricas de movimientos** para dashboard

#### Ejemplo de Flujo:
```json
// Entrada - Registrar Movimiento
{
  "productoId": 1,
  "usuarioId": 1,
  "tipoMovimiento": "ENTRADA",
  "razon": "COMPRA",
  "cantidad": 50,
  "precioUnitario": 899.99,
  "observaciones": "Compra mensual - Proveedor TechCorp - PO#2024-089"
}

// Salida - Movimiento Registrado
{
  "id": 25,
  "productoId": 1,
  "nombreProducto": "Acer Nitro V15",
  "usuarioId": 1,
  "nombreUsuario": "admin",
  "tipoMovimiento": "ENTRADA",
  "razon": "COMPRA",
  "cantidad": 50,
  "cantidadAnterior": 40,
  "cantidadNueva": 90,
  "precioUnitario": 899.99,
  "valorTotal": 44999.50,
  "observaciones": "Compra mensual - Proveedor TechCorp - PO#2024-089",
  "fechaMovimiento": "2024-09-09T12:45:30",
  "stockActualizado": true,
  "auditoria": {
    "ipOrigen": "192.168.1.100",
    "userAgent": "Flutter/3.0.0"
  }
}
```

### 🌐 Comunicación entre Microservicios
- **Protocolo**: REST API (HTTP/HTTPS)
- **Formato**: JSON para intercambio de datos
- **Comunicación Saliente**: 
  - Actualiza StockService tras registrar movimientos
  - Consulta ProductosService para validar existencia de productos
  - Consulta UsuariosService para validar usuarios y JWT
- **Comunicación Entrante**: 
  - Frontend registra nuevos movimientos
  - Otros servicios consultan historial para auditoría

---

## 🔗 Arquitectura de Comunicación General

### Patrones de Comunicación Implementados:

#### 1. **Comunicación Síncrona (REST API)**
```
Frontend Flutter ←→ API Gateway ←→ Microservicios
```
- **Protocolo**: HTTP/HTTPS con JSON
- **Autenticación**: JWT Bearer Token
- **Timeout**: 30 segundos por request
- **Retry Logic**: 3 intentos con backoff exponencial

#### 2. **Flujo de Datos Entre Servicios**
```
UsuariosService → JWT Token → Todos los servicios
ProductosService → Información de productos → StockService + MovimientoService
MovimientoService → Actualizaciones de stock → StockService
StockService → Alertas → Frontend (Dashboard)
```

#### 3. **Configuración de Red Multiplataforma**
```
Web Browser: http://localhost:puerto
Android Emulator: http://10.0.2.2:puerto
iOS Simulator: http://localhost:puerto
Dispositivos Físicos: http://[IP_RED_LOCAL]:puerto
```

### Características de Comunicación:

- **🔒 Seguridad**: Todas las comunicaciones protegidas con JWT
- **🌐 CORS**: Configurado para permitir requests cross-origin
- **📊 Logging**: Auditoría completa de requests entre servicios
- **⚡ Performance**: Caché local en frontend para datos frecuentes
- **🔄 Resilencia**: Circuit breaker pattern para tolerancia a fallos
- **📱 Multiplataforma**: Auto-detección de URLs según plataforma

### Ventajas de la Arquitectura:

1. **Independencia**: Cada microservicio puede desarrollarse y desplegarse independientemente
2. **Escalabilidad**: Servicios pueden escalarse según demanda específica
3. **Mantenibilidad**: Responsabilidades claramente separadas
4. **Flexibilidad**: Fácil adición de nuevos servicios o funcionalidades
5. **Robustez**: Fallo de un servicio no afecta completamente el sistema