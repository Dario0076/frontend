# Sistema de Inventario Automatizado

## Desglose de Actividades de Desarrollo

### 📋 Fase 1: Análisis y Diseño del Sistema

#### 1.1 Levantamiento de Requerimientos
- **Análisis de necesidades del negocio**
  - Identificación de procesos de inventario actuales
  - Definición de requerimientos funcionales y no funcionales
  - Establecimiento de casos de uso principales
  - Documentación de historias de usuario

- **Definición de alcance del proyecto**
  - Gestión de productos con categorías
  - Control de entradas y salidas de inventario
  - Sistema de alertas por stock mínimo
  - Historial de movimientos con trazabilidad
  - Autenticación y autorización de usuarios

#### 1.2 Diseño de Arquitectura
- **Selección de arquitectura de microservicios**
  - Definición de 4 servicios independientes
  - Establecimiento de comunicación vía API REST
  - Configuración de puertos específicos por servicio
  - Diseño de interoperabilidad entre servicios

- **Diseño de la base de datos**
  - **Modelado entidad-relación por microservicio**
    - **UsuariosService**: Entidad `usuarios` independiente con atributos de autenticación (id, nombre, correo, rol, contraseña hash)
    - **ProductosService**: Entidades `productos` y `categorias` con relación 1:N (un producto pertenece a una categoría)
    - **StockService**: Entidad `stock` que referencia productos por ID externo, manteniendo separación de concerns
    - **MovimientoService**: Entidad `movimientos` con referencias a producto_id y usuario_id para trazabilidad completa
    - **Relaciones inter-servicios**: Comunicación mediante IDs externos sin foreign keys físicas entre bases de datos
    
  - **Normalización de esquemas (1FN, 2FN, 3FN)**
    - **Primera Forma Normal (1FN)**: Eliminación de grupos repetitivos y valores atómicos
      - Cada celda contiene un solo valor (sin arrays de categorías en productos)
      - Filas únicas identificadas por clave primaria
      - Orden de filas irrelevante para la funcionalidad
    - **Segunda Forma Normal (2FN)**: Eliminación de dependencias parciales
      - Separación de categorías en tabla independiente para evitar redundancia
      - Atributos no clave dependen completamente de la clave primaria
      - `productos.categoria_id` referencia a `categorias.id` en lugar de almacenar nombre repetido
    - **Tercera Forma Normal (3FN)**: Eliminación de dependencias transitivas
      - Información de usuario en movimientos referenciada por ID, no duplicada
      - Stock actual calculado/almacenado independientemente, no derivado de otros campos
      - Precios y cantidades almacenados donde corresponde funcionalmente
      
  - **Definición de claves primarias y foráneas**
    - **Claves Primarias**: AUTO_INCREMENT BIGINT en todas las tablas (id)
    - **Claves Foráneas Internas**:
      - `productos.categoria_id` → `categorias.id` (CASCADE UPDATE, RESTRICT DELETE)
    - **Referencias Externas** (sin FK físicas para independencia de microservicios):
      - `stock.producto_id` → productos(id) en ProductosService
      - `movimientos.producto_id` → productos(id) en ProductosService  
      - `movimientos.usuario_id` → usuarios(id) en UsuariosService
    - **Claves Únicas**: email y nombre de usuario para evitar duplicados
    - **Índices Compuestos**: (producto_id, fecha) en movimientos para consultas temporales eficientes
    
  - **Establecimiento de constraints e índices**
    - **Constraints de Dominio**:
      - `CHECK (cantidad_actual >= 0)` en stock para evitar inventario negativo
      - `CHECK (umbral_minimo >= 0)` para valores lógicos de alertas
      - `CHECK (cantidad > 0)` en movimientos para transacciones válidas
      - `CHECK (precio >= 0)` en productos para precios no negativos
    - **Constraints de Entidad**:
      - `UNIQUE (email)` y `UNIQUE (nombre)` en usuarios
      - `UNIQUE (producto_id)` en stock para un solo registro por producto
      - `NOT NULL` en campos críticos (nombres, emails, cantidades)
    - **Índices de Rendimiento**:
      - `INDEX idx_producto_categoria (categoria_id)` para filtros por categoría
      - `INDEX idx_movimientos_producto (producto_id)` para historial por producto
      - `INDEX idx_movimientos_fecha (fecha_movimiento)` para consultas temporales
      - `INDEX idx_movimientos_usuario (usuario_id)` para auditoría por usuario
      - `INDEX idx_stock_umbral (umbral_minimo, cantidad_actual)` para alertas eficientes
    - **Constraints de Referencia** (lógicas, no físicas):
      - Validación a nivel de aplicación para consistencia entre microservicios
      - Soft deletes con campo `activo/eliminado` para mantener integridad referencial
      - Logs de auditoría para tracking de cambios en datos críticos
```sql
-- Creación de esquema de usuarios
CREATE DATABASE usuarios_db;

-- Tabla principal de usuarios
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

-- Datos de prueba
INSERT INTO usuarios (username, email, password, rol) VALUES 
('admin', 'admin@admin.com', '$2a$10$hashedpassword', 'ADMIN'),
('user1', 'user1@test.com', '$2a$10$hashedpassword', 'USER');
```

#### 2.2 ProductosService - Base de Datos de Productos
```sql
-- Creación de esquema de productos
CREATE DATABASE productos_db;

-- Tabla de categorías
CREATE TABLE categorias (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos
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
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Datos de prueba de categorías
INSERT INTO categorias (nombre, descripcion) VALUES 
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Deportes', 'Artículos deportivos y recreación'),
('Oficina', 'Suministros y equipos de oficina');

-- Datos de prueba de productos
INSERT INTO productos (nombre, descripcion, precio, cantidad, categoria_id) VALUES 
('Acer Nitro V15', 'Laptop gaming Acer Nitro V15', 899.99, 40, 1),
('Pelota de fútbol', 'Pelota oficial FIFA', 25.50, 100, 2),
('Lenovo Legion 5(2022)', 'Laptop gaming Legion 5', 1200.00, 30, 1);
```

#### 2.3 StockService - Base de Datos de Inventario
```sql
-- Creación de esquema de stock
CREATE DATABASE stock_db;

-- Tabla de stock
CREATE TABLE stock (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    producto_id BIGINT UNIQUE NOT NULL,
    cantidad_actual INTEGER NOT NULL DEFAULT 0,
    umbral_minimo INTEGER NOT NULL DEFAULT 0,
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (cantidad_actual >= 0),
    CHECK (umbral_minimo >= 0)
);

-- Datos de prueba de stock
INSERT INTO stock (producto_id, cantidad_actual, umbral_minimo) VALUES 
(1, 40, 10),  -- Acer Nitro V15
(2, 100, 10), -- Pelota de fútbol
(3, 30, 5);   -- Lenovo Legion 5
```

#### 2.4 MovimientoService - Base de Datos de Movimientos
```sql
-- Creación de esquema de movimientos
CREATE DATABASE movimientos_db;

-- Tabla de movimientos
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
    CHECK (cantidad > 0)
);
```

### 🛠️ Fase 3: Desarrollo de Microservicios Backend

#### 3.1 Configuración del Entorno de Desarrollo
- **Instalación de herramientas**
  - **Java 17 JDK**: OpenJDK o Oracle JDK con configuración de JAVA_HOME
  - **Maven 3.8+**: Para gestión de dependencias y construcción de proyectos
  - **MySQL Server 8.0**: Base de datos principal con configuración UTF-8
  - **MySQL Workbench**: Cliente gráfico para administración de base de datos
  - **Postman**: Herramienta para testing y documentación de APIs REST
  - **Visual Studio Code**: Editor principal con extensiones Java (Extension Pack for Java)
  - **Git**: Control de versiones con configuración de usuario global

- **Configuración de variables de entorno**
```bash
# Variables de sistema requeridas
JAVA_HOME=C:\Program Files\Java\jdk-17
MAVEN_HOME=C:\Program Files\Apache\maven\apache-maven-3.8.6
PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%

# Variables de base de datos
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password
```

- **Configuración inicial de MySQL**
```sql
-- Creación de usuario para el proyecto
CREATE USER 'inventario_user'@'localhost' IDENTIFIED BY 'inventario_pass';
GRANT ALL PRIVILEGES ON *.* TO 'inventario_user'@'localhost';
FLUSH PRIVILEGES;

-- Configuración de timezone
SET GLOBAL time_zone = '+00:00';
```

#### 3.2 UsuariosService (Puerto 8083)
- **Configuración inicial del proyecto**
```xml
<!-- pom.xml - Dependencias principales -->
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt</artifactId>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
    </dependency>
</dependencies>
```

- **Estructura de código implementada**
  - **`Entity/Usuario.java`** - Modelo de datos con anotaciones JPA
```java
@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    @Enumerated(EnumType.STRING)
    private Rol rol = Rol.USER;
    
    @Column(nullable = false)
    private Boolean activo = true;
    
    @CreationTimestamp
    private LocalDateTime fechaCreacion;
    
    @UpdateTimestamp
    private LocalDateTime fechaActualizacion;
}
```

  - **`Repository/UsuarioRepository.java`** - Interfaz de acceso a datos con consultas personalizadas
```java
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByUsername(String username);
    Optional<Usuario> findByEmail(String email);
    List<Usuario> findByActivoTrue();
    List<Usuario> findByRol(Rol rol);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
```

  - **`Service/UsuarioService.java`** - Lógica de negocio con validaciones y seguridad
```java
@Service
@Transactional
public class UsuarioService {
    
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    public Usuario crearUsuario(Usuario usuario) {
        // Validaciones de negocio
        if (usuarioRepository.existsByUsername(usuario.getUsername())) {
            throw new IllegalArgumentException("El nombre de usuario ya existe");
        }
        
        // Encriptar contraseña
        usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
        
        return usuarioRepository.save(usuario);
    }
    
    public String autenticar(String username, String password) {
        Usuario usuario = usuarioRepository.findByUsername(username)
            .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
            
        if (!passwordEncoder.matches(password, usuario.getPassword())) {
            throw new IllegalArgumentException("Contraseña incorrecta");
        }
        
        return jwtUtil.generateToken(usuario);
    }
}
```

  - **`Controller/UsuarioController.java`** - Controlador REST con validaciones
```java
@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = {"http://localhost:3000", "http://10.0.2.2:3000"})
@Validated
public class UsuarioController {
    
    @Autowired
    private UsuarioService usuarioService;
    
    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(
            @Valid @RequestBody LoginRequest request) {
        try {
            String token = usuarioService.autenticar(request.getUsername(), request.getPassword());
            Map<String, String> response = new HashMap<>();
            response.put("token", token);
            response.put("message", "Login exitoso");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(401).body(
                Map.of("error", e.getMessage())
            );
        }
    }
}
```

  - **`Config/SecurityConfig.java`** - Configuración de Spring Security con JWT
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/usuarios/login", "/api/usuarios/register").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/usuarios").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

  - **`Util/JwtUtil.java`** - Utilidades para manejo de JWT tokens
```java
@Component
public class JwtUtil {
    
    private String secret = "inventario_secret_key_2024";
    private int jwtExpiration = 86400000; // 24 horas
    
    public String generateToken(Usuario usuario) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("rol", usuario.getRol().name());
        claims.put("email", usuario.getEmail());
        return createToken(claims, usuario.getUsername());
    }
    
    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }
    
    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = getUsernameFromToken(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
}
```

- **Endpoints implementados**
  - **`POST /api/usuarios/login`** - Autenticación de usuario con validaciones
```json
// Request
{
  "username": "admin",
  "password": "admin123"
}

// Response (200 OK)
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "message": "Login exitoso",
  "usuario": {
    "id": 1,
    "username": "admin",
    "email": "admin@admin.com",
    "rol": "ADMIN"
  }
}
```

  - **`POST /api/usuarios/register`** - Registro de nuevo usuario con validaciones
```json
// Request
{
  "username": "nuevouser",
  "email": "nuevo@test.com",
  "password": "password123",
  "rol": "USER"
}

// Response (201 Created)
{
  "id": 2,
  "username": "nuevouser",
  "email": "nuevo@test.com",
  "rol": "USER",
  "activo": true,
  "fechaCreacion": "2024-09-07T10:30:00"
}
```

  - **`GET /api/usuarios/profile`** - Perfil del usuario autenticado (requiere JWT)
```json
// Headers: Authorization: Bearer <token>
// Response (200 OK)
{
  "id": 1,
  "username": "admin",
  "email": "admin@admin.com",
  "rol": "ADMIN",
  "activo": true,
  "fechaCreacion": "2024-09-01T08:00:00"
}
```

  - **`GET /api/usuarios`** - Listar todos los usuarios (solo ADMIN)
```json
// Headers: Authorization: Bearer <admin_token>
// Response (200 OK)
[
  {
    "id": 1,
    "username": "admin",
    "email": "admin@admin.com",
    "rol": "ADMIN",
    "activo": true
  },
  {
    "id": 2,
    "username": "user1",
    "email": "user1@test.com",
    "rol": "USER",
    "activo": true
  }
]
```

#### 3.3 ProductosService (Puerto 8084)
- **Entidades implementadas**
  - **`Entity/Producto.java`** - Modelo de producto con relaciones
```java
@Entity
@Table(name = "productos")
public class Producto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String nombre;
    
    @Column(columnDefinition = "TEXT")
    private String descripcion;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal precio = BigDecimal.ZERO;
    
    @Column(nullable = false)
    private Integer cantidad = 0;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "categoria_id")
    private Categoria categoria;
    
    @Column(nullable = false)
    private Boolean activo = true;
    
    @CreationTimestamp
    private LocalDateTime fechaCreacion;
    
    @UpdateTimestamp
    private LocalDateTime fechaActualizacion;
}
```

  - **`Entity/Categoria.java`** - Modelo de categoría con validaciones
```java
@Entity
@Table(name = "categorias")
public class Categoria {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false, length = 100)
    private String nombre;
    
    @Column(columnDefinition = "TEXT")
    private String descripcion;
    
    @Column(nullable = false)
    private Boolean activa = true;
    
    @CreationTimestamp
    private LocalDateTime fechaCreacion;
    
    @OneToMany(mappedBy = "categoria", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Producto> productos = new ArrayList<>();
}
```

- **Servicios desarrollados**
  - **`Service/ProductoService.java`** - CRUD completo con validaciones de negocio
```java
@Service
@Transactional
public class ProductoService {
    
    @Autowired
    private ProductoRepository productoRepository;
    
    @Autowired
    private CategoriaRepository categoriaRepository;
    
    public List<Producto> listarProductos(Long categoriaId, String busqueda) {
        Specification<Producto> spec = Specification.where(null);
        
        if (categoriaId != null) {
            spec = spec.and((root, query, cb) -> 
                cb.equal(root.get("categoria").get("id"), categoriaId));
        }
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            spec = spec.and((root, query, cb) -> 
                cb.or(
                    cb.like(cb.lower(root.get("nombre")), "%" + busqueda.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("descripcion")), "%" + busqueda.toLowerCase() + "%")
                ));
        }
        
        spec = spec.and((root, query, cb) -> cb.isTrue(root.get("activo")));
        
        return productoRepository.findAll(spec);
    }
    
    public Producto crearProducto(Producto producto) {
        // Validaciones de negocio
        if (producto.getPrecio().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("El precio no puede ser negativo");
        }
        
        if (producto.getCantidad() < 0) {
            throw new IllegalArgumentException("La cantidad no puede ser negativa");
        }
        
        // Verificar que la categoría existe
        if (producto.getCategoria() != null && producto.getCategoria().getId() != null) {
            Categoria categoria = categoriaRepository.findById(producto.getCategoria().getId())
                .orElseThrow(() -> new IllegalArgumentException("Categoría no encontrada"));
            producto.setCategoria(categoria);
        }
        
        return productoRepository.save(producto);
    }
}
```

  - **`Service/CategoriaService.java`** - Gestión de categorías con control de referencias
```java
@Service
@Transactional
public class CategoriaService {
    
    @Autowired
    private CategoriaRepository categoriaRepository;
    
    @Autowired
    private ProductoRepository productoRepository;
    
    public List<Categoria> listarCategoriasActivas() {
        return categoriaRepository.findByActivaTrue();
    }
    
    public Categoria crearCategoria(Categoria categoria) {
        if (categoriaRepository.existsByNombre(categoria.getNombre())) {
            throw new IllegalArgumentException("Ya existe una categoría con ese nombre");
        }
        return categoriaRepository.save(categoria);
    }
    
    public void eliminarCategoria(Long id) {
        Categoria categoria = categoriaRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Categoría no encontrada"));
            
        // Verificar que no tenga productos asociados
        long productosAsociados = productoRepository.countByCategoriaIdAndActivoTrue(id);
        if (productosAsociados > 0) {
            throw new IllegalStateException(
                "No se puede eliminar la categoría porque tiene " + productosAsociados + " productos asociados");
        }
        
        categoria.setActiva(false); // Soft delete
        categoriaRepository.save(categoria);
    }
}
```

- **API REST endpoints**
  - **`GET /api/productos`** - Listar productos con filtros avanzados
```http
GET /api/productos?categoriaId=1&busqueda=laptop
// Response: Array de productos filtrados con información de categoría
```

  - **`POST /api/productos`** - Crear nuevo producto con validaciones
```json
// Request
{
  "nombre": "MacBook Pro M2",
  "descripcion": "Laptop profesional Apple",
  "precio": 2500.00,
  "cantidad": 15,
  "categoria": {"id": 1}
}
```

  - **`PUT /api/productos/{id}`** - Actualizar producto existente
  - **`DELETE /api/productos/{id}`** - Eliminación lógica (soft delete)
  - **`GET /api/categorias`** - Listar categorías activas para filtros
  - **`POST /api/categorias`** - Crear nueva categoría con validación de unicidad

#### 3.4 StockService (Puerto 8081)
- **Funcionalidades implementadas**
  - **Gestión de inventario en tiempo real** con sincronización automática
  - **Sistema de alertas por stock mínimo** con indicadores visuales
  - **Configuración de umbrales personalizados** por producto
  - **Validaciones de consistencia** para evitar stock negativo
  - **Logs de auditoría** para cambios de stock

- **Modelo de datos optimizado**
```java
@Entity
@Table(name = "stock")
public class Stock {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private Long productoId;
    
    @Column(nullable = false)
    private Integer cantidadActual = 0;
    
    @Column(nullable = false)
    private Integer umbralMinimo = 0;
    
    @UpdateTimestamp
    private LocalDateTime fechaUltimaActualizacion;
    
    // Campo calculado para alertas
    @Transient
    private Boolean stockBajo;
    
    @PostLoad
    private void calcularStockBajo() {
        this.stockBajo = this.cantidadActual <= this.umbralMinimo;
    }
}
```

- **Endpoints desarrollados**
  - **`GET /api/stock`** - Listar todo el stock con información de productos
```json
// Response
[
  {
    "id": 1,
    "productoId": 1,
    "nombreProducto": "Acer Nitro V15",
    "cantidadActual": 40,
    "umbralMinimo": 10,
    "stockBajo": false,
    "fechaUltimaActualizacion": "2024-09-07T15:30:00"
  }
]
```

  - **`POST /api/stock`** - Crear registro de stock con validaciones
  - **`PUT /api/stock/{id}`** - Actualizar stock o umbral mínimo
  - **`DELETE /api/stock/{id}`** - Eliminar registro (solo si no hay movimientos)
  - **`GET /api/stock/alertas`** - Productos con stock bajo para dashboard
```json
// Response: Array de productos que requieren atención
[
  {
    "productoId": 3,
    "nombreProducto": "Cable HDMI",
    "cantidadActual": 2,
    "umbralMinimo": 5,
    "diferencia": -3,
    "prioridad": "ALTA"
  }
]
```

#### 3.5 MovimientoService (Puerto 8090)
- **Sistema de trazabilidad completa**
  - **Registro automático** de cantidad anterior y nueva
  - **Historial detallado** por producto y usuario responsable
  - **Auditoría completa** con timestamps y razones específicas
  - **Validaciones de consistencia** antes de registrar movimientos
  - **Integración con StockService** para actualización automática

- **Modelo de auditoría robusto**
```java
@Entity
@Table(name = "movimientos")
public class Movimiento {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private Long productoId;
    
    @Column(nullable = false)
    private Long usuarioId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoMovimiento tipoMovimiento; // ENTRADA, SALIDA
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RazonMovimiento razon; // COMPRA, VENTA, DEVOLUCION, AJUSTE, TRASLADO, BAJA
    
    @Column(nullable = false)
    private Integer cantidad;
    
    @Column(nullable = false)
    private Integer cantidadAnterior;
    
    @Column(nullable = false)
    private Integer cantidadNueva;
    
    @Column(precision = 10, scale = 2)
    private BigDecimal precioUnitario;
    
    @Column(columnDefinition = "TEXT")
    private String observaciones;
    
    @CreationTimestamp
    private LocalDateTime fechaMovimiento;
    
    // Campos adicionales para auditoría
    private String ipOrigen;
    private String userAgent;
}
```

- **API implementada**
  - **`GET /api/movimientos`** - Historial de movimientos con filtros
```http
GET /api/movimientos?productoId=1&tipo=ENTRADA&fechaDesde=2024-09-01&fechaHasta=2024-09-07
```

  - **`POST /api/movimientos`** - Registrar nuevo movimiento con validaciones
```json
// Request
{
  "productoId": 1,
  "usuarioId": 1,
  "tipoMovimiento": "ENTRADA",
  "razon": "COMPRA",
  "cantidad": 50,
  "precioUnitario": 899.99,
  "observaciones": "Compra a proveedor XYZ - Factura #12345"
}

// Response automático tras validaciones y actualización de stock
{
  "id": 15,
  "productoId": 1,
  "usuarioId": 1,
  "tipoMovimiento": "ENTRADA",
  "razon": "COMPRA",
  "cantidad": 50,
  "cantidadAnterior": 40,
  "cantidadNueva": 90,
  "precioUnitario": 899.99,
  "observaciones": "Compra a proveedor XYZ - Factura #12345",
  "fechaMovimiento": "2024-09-07T16:45:30",
  "stockActualizado": true
}
```

  - **`GET /api/movimientos/producto/{id}`** - Movimientos específicos por producto
  - **`GET /api/movimientos/usuario/{id}`** - Auditoría por usuario responsable
  - **`GET /api/movimientos/resumen`** - Dashboard con métricas de movimientos

#### 3.6 Configuración de CORS y Seguridad
```java
// Configuración CORS global para todos los servicios
@Configuration
@EnableWebMvc
public class CorsConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(
                    "http://localhost:3000",     // Flutter Web
                    "http://10.0.2.2:3000",     // Android Emulator
                    "http://127.0.0.1:3000"     // Alternative localhost
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}

// Configuración específica en cada controlador
@CrossOrigin(
    origins = {"http://localhost:3000", "http://10.0.2.2:3000"},
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE},
    allowedHeaders = {"Authorization", "Content-Type"},
    exposedHeaders = {"X-Total-Count"}
)
@RestController
@RequestMapping("/api/productos")
public class ProductoController {
    
    // Middleware de seguridad para endpoints protegidos
    @PreAuthorize("hasRole('ADMIN') or hasRole('USER')")
    @GetMapping
    public ResponseEntity<List<Producto>> listarProductos(
            @RequestParam(required = false) Long categoriaId,
            @RequestParam(required = false) String busqueda,
            HttpServletRequest request) {
        
        // Log de auditoría para tracking
        logger.info("Usuario {} consultó productos con filtros: categoriaId={}, busqueda={}",
                   request.getRemoteUser(), categoriaId, busqueda);
                   
        List<Producto> productos = productoService.listarProductos(categoriaId, busqueda);
        
        // Headers adicionales para paginación futura
        HttpHeaders headers = new HttpHeaders();
        headers.add("X-Total-Count", String.valueOf(productos.size()));
        
        return ResponseEntity.ok().headers(headers).body(productos);
    }
    
    // Manejo global de excepciones
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleValidationException(IllegalArgumentException e) {
        Map<String, String> error = new HashMap<>();
        error.put("error", e.getMessage());
        error.put("timestamp", LocalDateTime.now().toString());
        return ResponseEntity.badRequest().body(error);
    }
}

// Configuración de seguridad JWT en application.properties
# Configuración JWT
jwt.secret=inventario_secret_key_2024_super_secure
jwt.expiration=86400000
jwt.header=Authorization
jwt.prefix=Bearer 

# Configuración CORS adicional
cors.allowed-origins=http://localhost:3000,http://10.0.2.2:3000
cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
cors.allowed-headers=*
cors.exposed-headers=X-Total-Count,X-Page-Number
cors.allow-credentials=true
cors.max-age=3600
```

### 📱 Fase 4: Desarrollo del Frontend Flutter

#### 4.1 Configuración del Proyecto Flutter
- **Inicialización del proyecto**
```bash
flutter create frontend
cd frontend
flutter pub get
```

- **Dependencias agregadas en pubspec.yaml**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  provider: ^6.0.5
  shared_preferences: ^2.0.15
```

#### 4.2 Estructura de Archivos Implementada
```
lib/
├── main.dart                     # Punto de entrada de la aplicación
├── models/                       # Modelos de datos
│   ├── usuario_model.dart
│   ├── producto_model.dart
│   ├── categoria_model.dart
│   ├── stock_model.dart
│   └── movimiento_model.dart
├── services/                     # Servicios de API
│   ├── api_config.dart          # Configuración de URLs
│   ├── auth_service.dart
│   ├── productos_api_service.dart
│   ├── categoria_service.dart
│   ├── stock_api_service.dart
│   └── movimiento_service.dart
├── screens/                      # Pantallas principales
│   ├── login_screen.dart
│   └── home_screen.dart
└── widgets/                      # Componentes reutilizables
    ├── productos_tab.dart
    ├── stock_tab.dart
    ├── movimientos_tab.dart
    ├── usuarios_tab.dart
    └── categorias_tab.dart
```

#### 4.3 Configuración Automática de APIs
```dart
// api_config.dart - Configuración multiplataforma
class ApiConfig {
  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2';  // IP del emulador Android
    } else {
      return 'http://localhost';
    }
  }
  
  static String get usuariosBaseUrl => '${_getBaseUrl()}:8083/api/usuarios';
  static String get productosBaseUrl => '${_getBaseUrl()}:8084/api/productos';
  static String get stockBaseUrl => '${_getBaseUrl()}:8081/api/stock';
  static String get movimientosBaseUrl => '${_getBaseUrl()}:8090/api/movimientos';
}
```

#### 4.4 Implementación de Funcionalidades Principales

##### 4.4.1 Sistema de Autenticación
- **Login con JWT**
- **Gestión de sesiones**
- **Roles de usuario (ADMIN/USER)**
- **Persistencia de tokens**

##### 4.4.2 Gestión de Productos
- **CRUD completo de productos**
- **Sistema de categorías**
- **Filtros avanzados por categoría**
- **Búsqueda en tiempo real por nombre/descripción**
- **Formularios colapsables para mejor UX**
- **Contador de resultados**

##### 4.4.3 Control de Stock
- **Visualización de inventario actual**
- **Alertas visuales para stock bajo**
- **Configuración de umbrales mínimos**
- **Búsqueda por ID o nombre de producto**
- **Edición en línea de umbrales**

##### 4.4.4 Historial de Movimientos
- **Registro de entradas y salidas**
- **Trazabilidad completa**
- **Filtros por tipo de movimiento**
- **Información de usuario responsable**

##### 4.4.5 Gestión de Usuarios
- **Listado de usuarios del sistema**
- **Control de roles y permisos**
- **Estados activos/inactivos**

### 🔧 Fase 5: Optimización y Mejoras de UX

#### 5.1 Mejoras de Interfaz de Usuario
- **Implementación de Material Design**
- **Layouts responsivos para diferentes pantallas**
- **Formularios compactos y colapsables**
- **Filtros avanzados con búsqueda en tiempo real**
- **Indicadores visuales de estado**
- **Botones de acción rápida**

#### 5.2 Optimización de Rendimiento
- **Lazy loading de datos**
- **Paginación en listados largos**
- **Caché local de datos frecuentes**
- **Optimización de consultas SQL**
- **Índices en campos de búsqueda**

#### 5.3 Testing y Debugging
- **Pruebas de APIs con Postman**
- **Testing en emulador Android**
- **Verificación en navegadores web**
- **Logs de debug para troubleshooting**
- **Manejo de errores y excepciones**

### 🚀 Fase 6: Despliegue y Configuración

#### 6.1 Configuración de Desarrollo
- **Setup de base de datos MySQL local**
- **Configuración de puertos para microservicios**
- **Variables de entorno para desarrollo**
- **Scripts de inicio automático**

#### 6.2 Testing en Múltiples Plataformas
- **Web Browser (Chrome/Edge)**
  - URL: `http://localhost:puerto`
  - Testing de funcionalidades completas
  
- **Android Emulador**
  - Configuración de red: `10.0.2.2:puerto`
  - Testing de UI móvil y responsive design
  
- **Hot Reload para desarrollo ágil**
  - Cambios en tiempo real sin perder estado
  - Debugging eficiente durante desarrollo

### 📊 Resultados y Métricas del Proyecto

#### 6.1 Funcionalidades Completadas
- ✅ **4 microservicios independientes funcionando**
- ✅ **Frontend multiplataforma (Web + Android + iOS)**
- ✅ **Sistema de autenticación JWT completo**
- ✅ **CRUD completo para todas las entidades**
- ✅ **Filtros avanzados y búsqueda en tiempo real**
- ✅ **Sistema de alertas por stock mínimo**
- ✅ **Historial completo de movimientos**
- ✅ **Configuración automática de red por plataforma**
- ✅ **Interfaz responsive y optimizada**

#### 6.2 Métricas Técnicas
- **Backend**: 4 servicios Spring Boot con 15+ endpoints
- **Frontend**: 1 aplicación Flutter con 5 módulos principales
- **Base de Datos**: 4 esquemas MySQL con 8+ tablas
- **Líneas de Código**: ~2000+ líneas Java + ~1500+ líneas Dart
- **Tiempo de Desarrollo**: Aproximadamente 40-60 horas

#### 6.3 Herramientas y Tecnologías Utilizadas
- **Backend**: Java 17, Spring Boot, Spring Security, JWT, MySQL, Maven
- **Frontend**: Flutter, Dart, Material Design, HTTP Client
- **Desarrollo**: VS Code, Android Studio, Git, MySQL Workbench
- **Testing**: Postman, Chrome DevTools, Android Emulator

### 📋 Documentación Generada
- ✅ **Requerimientos Funcionales Completos**
- ✅ **Arquitectura del Sistema y Diagramas**
- ✅ **Modelado de Base de Datos (ER)**
- ✅ **Base Conceptual para Investigación**
- ✅ **README con Desglose de Actividades**
- ✅ **Documentación de APIs y Endpoints**

---

## 🎯 Conclusión

El proyecto de Sistema de Inventario Automatizado ha sido desarrollado exitosamente siguiendo una metodología estructurada que abarcó desde el análisis de requerimientos hasta la implementación de un sistema multiplataforma completamente funcional. 

La arquitectura de microservicios permite escalabilidad y mantenimiento independiente de cada módulo, mientras que el frontend Flutter proporciona una experiencia de usuario consistente across plataformas.

**Próximos pasos sugeridos:**
- Implementación de tests automatizados
- Configuración de CI/CD pipeline
- Despliegue en ambiente de producción
- Implementación de métricas y monitoreo
- Documentación de APIs con Swagger/OpenAPI