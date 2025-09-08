# REQUERIMIENTOS FUNCIONALES

## BASE CONCEPTUAL

Los siguientes temas de investigación constituyen la base teórica y conceptual del sistema de inventario automatizado:

➤ **Gestión de Inventarios:**
-	Sistemas de inventario automatizado y sus beneficios.
-	Métodos de control de stock (FIFO, LIFO, promedio ponderado).
-	Gestión de stock mínimo y máximo.
-	Indicadores de rotación de inventario.
-	Costos asociados al mantenimiento de inventario.

➤ **Arquitectura de Software:**
-	Patrones de arquitectura de microservicios.
-	API REST y principios de diseño RESTful.
-	Comunicación entre servicios distribuidos.
-	Balanceadores de carga y escalabilidad horizontal.
-	Tolerancia a fallos en sistemas distribuidos.

➤ **Autenticación y Seguridad:**
-	JSON Web Tokens (JWT) y su implementación.
-	Autenticación basada en tokens vs sesiones.
-	Roles y permisos en sistemas empresariales.
-	Seguridad en APIs REST (CORS, HTTPS, validación).
-	Mejores prácticas de seguridad en aplicaciones web.

➤ **Desarrollo Multiplataforma:**
-	Framework Flutter y desarrollo cross-platform.
-	Diferencias entre desarrollo nativo vs híbrido.
-	Gestión de estado en aplicaciones Flutter.
-	Responsive design y adaptabilidad móvil.
-	Optimización de rendimiento en aplicaciones móviles.

➤ **Base de Datos y Persistencia:**
-	Diseño de bases de datos relacionales.
-	Normalización de bases de datos (1FN, 2FN, 3FN).
-	Optimización de consultas SQL.
-	ORM (Object-Relational Mapping) con JPA/Hibernate.
-	Transacciones ACID y consistencia de datos.

➤ **Sistemas de Control de Stock:**
-	Algoritmos de reposición automática.
-	Sistemas de alertas y notificaciones.
-	Trazabilidad de productos y movimientos.
-	Auditoría de inventario y reconciliación.
-	Integración con sistemas ERP existentes.

➤ **Experiencia de Usuario (UX/UI):**
-	Principios de diseño Material Design.
-	Usabilidad en aplicaciones de gestión empresarial.
-	Interfaces responsivas y adaptativas.
-	Accesibilidad en aplicaciones web y móviles.
-	Patrones de navegación y flujos de usuario.

➤ **Metodologías de Desarrollo:**
-	Desarrollo ágil y metodologías Scrum.
-	Integración y despliegue continuo (CI/CD).
-	Testing automatizado (unitarias, integración, E2E).
-	Documentación técnica y de usuario.
-	Versionado de código con Git y GitHub.

➤ **Análisis de Requerimientos:**
-	Técnicas de levantamiento de requerimientos.
-	Modelado de procesos de negocio.
-	Casos de uso y historias de usuario.
-	Validación y verificación de requerimientos.
-	Gestión de cambios en requerimientos.

➤ **Performance y Escalabilidad:**
-	Optimización de aplicaciones web y móviles.
-	Cachéing y estrategias de almacenamiento temporal.
-	Monitoreo de aplicaciones en producción.
-	Métricas de rendimiento y KPIs técnicos.
-	Estrategias de escalamiento horizontal y vertical.

A continuación, se detallan los requerimientos funcionales que establecen el alcance del módulo de inventario automatizado:

➤ **Gestión de productos:**
-	Registrar nuevos productos con atributos como nombre, categoría, cantidad, precio.
-	eliminar productos existentes.
-	Consultar el listado del producto con filtros por categoría.
-	Búsqueda de productos por nombre o descripción en tiempo real.
-	Visualización compacta con formularios colapsables.
-	Contador de resultados y limpiar filtros.

➤ **Control de entrada y salida:**
-	Registrar entrada de productos por compra, devolución o reposición.
-	Registrar salidas de productos por venta, traslado o baja.
-	Actualizar automáticamente el stock disponible tras cada movimiento.

➤ **Alertas de Stock mínimo:**
-	Generar alertas cuando un producto alcanza el nivel mínimo de inventario definido.
-	Permitir la configuración personalizada del umbral de alerta por producto.

➤ **Historial de movimientos:**
-	Visualizar el historial completo de entradas y salidas por producto y el usuario que hizo el movimiento.

➤ **Gestión de usuarios:**
-	Acceso mediante credenciales a una interfaz web para gestionar el inventario.
-	Sistema de autenticación JWT con roles de usuario.

➤ **Gestión de categorías:**
-	Crear, editar y eliminar categorías de producto
-	Asignar productos a categorías específicas.
-	Filtrar productos por categoría en tiempo real.

➤ **Interfaz web y aplicación móvil:**
-	Acceso mediante credenciales a una interfaz web para gestionar el inventario.
-	Visualización amigable de productos, movimientos y alertas.
-	Aplicación multiplataforma (Web, Android, iOS).
-	Interfaz responsive con filtros avanzados y búsqueda en tiempo real.

➤ **API REST para integración:**
-	Exponer endpoints para operaciones CRUD de productos y movimientos.
-	Microservicios independientes para cada módulo del sistema.
-	Configuración automática de URLs según plataforma.

➤ **Gestión de stock:**
-	Visualizar el stock actual de todos los productos con información detallada.
-	Búsqueda de stock por ID del producto o nombre del producto.
-	Crear, editar y eliminar registros de stock.
-	Configurar umbral mínimo personalizado por producto.
-	Alertas visuales para productos con stock bajo.
-	Filtrado en tiempo real con contador de resultados.

## TECNOLOGÍAS Y HERRAMIENTAS UTILIZADAS

➤ **Frontend - Aplicación Móvil y Web:**
-	Flutter (Framework multiplataforma).
-	Dart (Lenguaje de programación).
-	Material Design (Sistema de diseño UI/UX).
-	HTTP (Comunicación con APIs REST).
-	Provider/setState (Gestión de estado).

➤ **Backend - Microservicios:**
-	Spring Boot (Framework Java para microservicios).
-	Java 17 (Lenguaje de programación).
-	Spring Security (Autenticación y autorización).
-	JWT (JSON Web Tokens para autenticación).
-	Maven (Gestión de dependencias y construcción).

➤ **Base de Datos:**
-	MySQL (Sistema de gestión de base de datos relacional).
-	JPA/Hibernate (Mapeo objeto-relacional).
-	Spring Data JPA (Acceso a datos simplificado).

➤ **Arquitectura y Comunicación:**
-	Arquitectura de Microservicios.
-	API REST (Comunicación entre servicios).
-	CORS (Cross-Origin Resource Sharing configurado).
-	JSON (Formato de intercambio de datos).

➤ **Herramientas de Desarrollo:**
-	Visual Studio Code (Editor de código).
-	Android Studio/Emulador Android (Desarrollo móvil).
-	Chrome/Edge DevTools (Debugging web).
-	Git (Control de versiones).
-	Hot Reload (Desarrollo ágil Flutter).

➤ **Configuración de Red:**
-	Localhost (Desarrollo web local).
-	10.0.2.2 (Configuración automática para emulador Android).
-	Configuración automática de URLs según plataforma.

➤ **Servicios Implementados:**
-	UsuariosService (Puerto 8083) - Gestión de usuarios y autenticación.
-	ProductosService (Puerto 8084) - CRUD de productos y categorías.
-	StockService (Puerto 8081) - Gestión de inventario y alertas.
-	MovimientoService (Puerto 8090) - Historial de entradas y salidas.

## ARQUITECTURA GENERAL DEL SISTEMA

### Diagrama de Alto Nivel - Arquitectura de Microservicios

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAPA DE PRESENTACIÓN                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Web App   │  │Android App  │  │  iOS App    │             │
│  │  (Chrome/   │  │ (Emulador/  │  │(Simulador/  │             │
│  │   Edge)     │  │ Dispositivo)│  │Dispositivo) │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│           │               │               │                    │
│           └───────────────┼───────────────┘                    │
│                          │                                     │
│                ┌─────────────────────┐                         │
│                │   FLUTTER FRONTEND  │                         │
│                │                     │                         │
│                │ • Material Design   │                         │
│                │ • Estado con        │                         │
│                │   Provider/setState │                         │
│                │ • HTTP Client       │                         │
│                │ • Auto URL Config   │                         │
│                └─────────────────────┘                         │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                    ┌─────────────────────┐
                    │    API GATEWAY      │
                    │   (Configuración    │
                    │    automática)      │
                    └─────────────────────┘
                              │
┌─────────────────────────────┼───────────────────────────────────┐
│                        CAPA DE SERVICIOS                        │
├─────────────────────────────┼───────────────────────────────────┤
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐       │
│    │ USUARIOS    │    │ PRODUCTOS   │    │   STOCK     │       │
│    │ SERVICE     │    │  SERVICE    │    │  SERVICE    │       │
│    │             │    │             │    │             │       │
│    │Puerto: 8083 │    │Puerto: 8084 │    │Puerto: 8081 │       │
│    │             │    │             │    │             │       │
│    │• Auth JWT   │    │• CRUD       │    │• Inventario │       │
│    │• Roles      │    │• Categorías │    │• Alertas    │       │
│    │• Login      │    │• Filtros    │    │• Umbrales   │       │
│    └─────────────┘    └─────────────┘    └─────────────┘       │
│           │                   │                   │            │
│           │                   │                   │            │
│    ┌─────────────┐           │                   │            │
│    │MOVIMIENTOS  │           │                   │            │
│    │  SERVICE    │           │                   │            │
│    │             │           │                   │            │
│    │Puerto: 8090 │           │                   │            │
│    │             │           │                   │            │
│    │• Entradas   │           │                   │            │
│    │• Salidas    │           │                   │            │
│    │• Historial  │           │                   │            │
│    │• Trazab.    │           │                   │            │
│    └─────────────┘           │                   │            │
│           │                   │                   │            │
└───────────┼───────────────────┼───────────────────┼────────────┘
            │                   │                   │
┌───────────┼───────────────────┼───────────────────┼────────────┐
│                           CAPA DE DATOS                        │
├───────────┼───────────────────┼───────────────────┼────────────┤
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐       │
│    │   MySQL     │    │   MySQL     │    │   MySQL     │       │
│    │  USUARIOS   │    │ PRODUCTOS   │    │   STOCK     │       │
│    │             │    │             │    │             │       │
│    │• usuarios   │    │• productos  │    │• stock      │       │
│    │• roles      │    │• categorias │    │• alertas    │       │
│    │             │    │             │    │             │       │
│    └─────────────┘    └─────────────┘    └─────────────┘       │
│           │                   │                   │            │
│    ┌─────────────┐           │                   │            │
│    │   MySQL     │           │                   │            │
│    │MOVIMIENTOS  │           │                   │            │
│    │             │           │                   │            │
│    │• movimientos│           │                   │            │
│    │• historial  │           │                   │            │
│    │             │           │                   │            │
│    └─────────────┘           │                   │            │
└───────────────────────────────────────────────────────────────┘
```

### Comunicación entre Componentes:

**Frontend → Backend:**
- HTTP REST API calls
- JWT Token Authentication
- JSON Data Exchange
- CORS Configuration

**Inter-Service Communication:**
- REST API calls between microservices
- Shared database schemas (optional)
- Event-driven updates (future enhancement)

**Network Configuration:**
- Web: localhost:puerto
- Android Emulator: 10.0.2.2:puerto
- Auto-detection by platform

## MODELADO DE DATOS - ESQUEMAS DE BASE DE DATOS

### 1. UsuariosService - Base de Datos de Autenticación

```sql
-- Tabla: usuarios
CREATE TABLE usuarios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol ENUM('ADMIN', 'USER') DEFAULT 'USER',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla: roles (opcional para expansión futura)
CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    permisos JSON
);
```

### 2. ProductosService - Base de Datos de Productos

```sql
-- Tabla: categorias
CREATE TABLE categorias (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: productos
CREATE TABLE productos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    cantidad INTEGER DEFAULT 0,
    categoria_id BIGINT,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    INDEX idx_categoria (categoria_id),
    INDEX idx_nombre (nombre),
    INDEX idx_activo (activo)
);
```

### 3. StockService - Base de Datos de Inventario

```sql
-- Tabla: stock
CREATE TABLE stock (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    producto_id BIGINT UNIQUE NOT NULL,
    cantidad_actual INTEGER NOT NULL DEFAULT 0,
    umbral_minimo INTEGER NOT NULL DEFAULT 0,
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_producto (producto_id),
    INDEX idx_stock_bajo (cantidad_actual, umbral_minimo),
    
    -- Constraint para evitar stock negativo
    CHECK (cantidad_actual >= 0),
    CHECK (umbral_minimo >= 0)
);

-- Tabla: alertas_stock (opcional para historial de alertas)
CREATE TABLE alertas_stock (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    producto_id BIGINT NOT NULL,
    tipo_alerta ENUM('STOCK_BAJO', 'STOCK_CRITICO', 'SIN_STOCK') NOT NULL,
    cantidad_actual INTEGER NOT NULL,
    umbral_minimo INTEGER NOT NULL,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    
    INDEX idx_producto_alerta (producto_id),
    INDEX idx_fecha (fecha_alerta),
    INDEX idx_tipo (tipo_alerta)
);
```

### 4. MovimientoService - Base de Datos de Movimientos

```sql
-- Tabla: movimientos
CREATE TABLE movimientos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    producto_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA') NOT NULL,
    razon ENUM('COMPRA', 'VENTA', 'DEVOLUCION', 'AJUSTE', 'TRASLADO', 'BAJA') NOT NULL,
    cantidad INTEGER NOT NULL,
    cantidad_anterior INTEGER NOT NULL,
    cantidad_nueva INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2),
    observaciones TEXT,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_producto (producto_id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_tipo (tipo_movimiento),
    INDEX idx_fecha (fecha_movimiento),
    INDEX idx_razon (razon),
    
    -- Constraints
    CHECK (cantidad > 0),
    CHECK (cantidad_anterior >= 0),
    CHECK (cantidad_nueva >= 0)
);

-- Tabla: auditoria_movimientos (para trazabilidad completa)
CREATE TABLE auditoria_movimientos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    movimiento_id BIGINT NOT NULL,
    accion ENUM('CREADO', 'MODIFICADO', 'ELIMINADO') NOT NULL,
    datos_anteriores JSON,
    datos_nuevos JSON,
    usuario_id BIGINT NOT NULL,
    fecha_auditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (movimiento_id) REFERENCES movimientos(id),
    INDEX idx_movimiento_audit (movimiento_id),
    INDEX idx_fecha_audit (fecha_auditoria)
);
```

### Diagrama Entidad-Relación Conceptual

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│    USUARIOS     │      │   CATEGORIAS    │      │    PRODUCTOS    │
├─────────────────┤      ├─────────────────┤      ├─────────────────┤
│ id (PK)         │      │ id (PK)         │      │ id (PK)         │
│ username        │      │ nombre          │      │ nombre          │
│ email           │      │ descripcion     │      │ descripcion     │
│ password        │      │ activa          │      │ precio          │
│ rol             │      │ fecha_creacion  │      │ cantidad        │
│ activo          │      └─────────────────┘      │ categoria_id(FK)│
│ fecha_creacion  │               │               │ activo          │
│ fecha_actualiz. │               │               │ fecha_creacion  │
└─────────────────┘               │               │ fecha_actualiz. │
         │                        │               └─────────────────┘
         │                        │                        │
         │                        └── tiene ──────────────┘
         │                                                 │
         │                                                 │
         │                                        ┌─────────────────┐
         │                                        │     STOCK       │
         │                                        ├─────────────────┤
         │                                        │ id (PK)         │
         │                                        │ producto_id(FK) │
         │                                        │ cantidad_actual │
         │                                        │ umbral_minimo   │
         │                                        │ fecha_ultima_   │
         │                                        │ actualizacion   │
         │                                        └─────────────────┘
         │                                                 │
         │                                        controla │
         │                                                 │
         │                                                 │
         │                               ┌─────────────────┐
         │                               │   MOVIMIENTOS   │
         │                               ├─────────────────┤
         │                               │ id (PK)         │
         │                               │ producto_id(FK) │
         │── registra ───────────────────│ usuario_id (FK) │
                                         │ tipo_movimiento │
                                         │ razon           │
                                         │ cantidad        │
                                         │ cantidad_anterior│
                                         │ cantidad_nueva  │
                                         │ precio_unitario │
                                         │ observaciones   │
                                         │ fecha_movimiento│
                                         └─────────────────┘
```

### Relaciones Principales:

1. **Usuarios → Movimientos** (1:N)
   - Un usuario puede registrar múltiples movimientos

2. **Categorías → Productos** (1:N)
   - Una categoría puede tener múltiples productos

3. **Productos → Stock** (1:1)
   - Cada producto tiene un registro de stock único

4. **Productos → Movimientos** (1:N)
   - Un producto puede tener múltiples movimientos de entrada/salida

5. **Cross-Service References:**
   - MovimientoService referencia producto_id y usuario_id
   - StockService referencia producto_id
   - Sincronización a través de APIs REST
