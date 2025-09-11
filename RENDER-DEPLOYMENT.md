# 🚀 Despliegue en Render - Sistema de Inventario

## 📋 Instrucciones para Render

### 1️⃣ **Preparación de repositorios**

Cada microservicio debe estar en su propio repositorio de GitHub:

```bash
# Subir cada servicio por separado
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/tuusuario/usuarios-service.git
git push -u origin main
```

### 2️⃣ **Configuración de Base de Datos**

En Render, ya tienes creadas 4 bases de datos **PostgreSQL** separadas:

1. Ve a Dashboard → Databases
2. Para cada BD, copia su **Internal Database URL**
3. Ejemplo StockService: `postgresql://stockdb_pdqv_user:5Wc7hdgsxZqFD1AvzvYSO82ToOf0joZj@dpg-d31377fdiees73afo4i0-a/stockdb_pdqv`

### 3️⃣ **Variables de Entorno para cada servicio**

#### **UsuariosService:**
```env
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=postgresql://usuariosdb_l24y_user:ZL8D6JKpZ6sM7J9vVVHrY0ivYUQ0di2D@dpg-d3136jumcj7s7380beng-a/usuariosdb_l24y
PORT=8083
```

#### **ProductosService:**
```env
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=postgresql://productosdb_aiv9_user:yNL9gzHySMsNx4gp4MmVdafbwflS9TmF@dpg-d3135ivdiees73afmjag-a/productosdb_aiv9
STOCK_SERVICE_URL=https://stock-service.onrender.com
PORT=8084
```

#### **StockService:**
```env
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=postgresql://stockdb_pdqv_user:5Wc7hdgsxZqFD1AvzvYSO82ToOf0joZj@dpg-d31377fdiees73afo4i0-a/stockdb_pdqv
PRODUCTOS_SERVICE_URL=https://productos-service.onrender.com
PORT=8081
```

#### **MovimientoService:**
```env
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=postgresql://movimientodb_user:RMOLSFc9KrxqbdWF1NAp61DubkGIDmpH@dpg-d3133vumcj7s73808pt0-a/movimientodb
USUARIOS_SERVICE_URL=https://usuarios-service.onrender.com
PRODUCTOS_SERVICE_URL=https://productos-service.onrender.com
STOCK_SERVICE_URL=https://stock-service.onrender.com
PORT=8090
```
USUARIOS_SERVICE_URL=https://usuarios-service.onrender.com
PRODUCTOS_SERVICE_URL=https://productos-service.onrender.com
STOCK_SERVICE_URL=https://stock-service.onrender.com
PORT=8090
```

### 4️⃣ **Crear Web Services en Render**

Para cada microservicio:

1. **New Web Service**
2. **Connect GitHub repository**
3. **Configuración:**
   - **Build Command:** `./mvnw clean package -DskipTests`
   - **Start Command:** `java -Dserver.port=$PORT -jar target/[SERVICE-NAME]-0.0.1-SNAPSHOT.jar`
   - **Instance Type:** Free
   - **Environment:** Production

### 5️⃣ **URLs de los servicios desplegados**

Una vez desplegados, tendrás URLs como:
- UsuariosService: `https://usuarios-service.onrender.com`
- ProductosService: `https://productos-service.onrender.com`
- StockService: `https://stock-service.onrender.com`
- MovimientoService: `https://movimiento-service.onrender.com`

### 6️⃣ **Actualizar Frontend para producción**

En `api_config.dart`, crear un modo de producción:

```dart
static String _getBaseUrl() {
  if (kIsWeb) {
    return 'https://usuarios-service.onrender.com'; // URL de producción
  } else if (Platform.isAndroid) {
    return _isEmulator() ? 'http://10.0.2.2' : 'http://192.168.1.6';
  } else {
    return 'http://localhost';
  }
}
```

### 7️⃣ **Health Checks**

Render usará las rutas `/actuator/health` para verificar que los servicios estén funcionando.

### 8️⃣ **Limitaciones del plan gratuito**

- ⚠️ Los servicios gratuitos se "duermen" después de 15 minutos de inactividad
- ⚠️ Primer arranque después del "sueño" puede tardar 30-60 segundos
- ⚠️ Base de datos PostgreSQL gratuita tiene límites de conexiones

## 🐳 **Para desarrollo local con Docker**

```bash
# Ejecutar todo el stack localmente
docker-compose up --build

# Parar todos los servicios
docker-compose down

# Ver logs de un servicio específico
docker-compose logs usuarios-service
```

## 🔧 **Comandos útiles**

```bash
# Construir imagen individual
docker build -t usuarios-service ./UsuariosService

# Ejecutar contenedor individual
docker run -p 8083:8083 usuarios-service

# Limpiar imágenes
docker system prune -a
```
