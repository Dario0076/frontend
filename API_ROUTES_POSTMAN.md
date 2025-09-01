# Sistema de Inventario - Rutas API para Testing con Postman

## 🚀 MovimientoService (Puerto: 8090)

### 1. Health Check
```
GET http://localhost:8090/movimientos/health
```

### 2. Obtener todos los movimientos
```
GET http://localhost:8090/movimientos
```

### 3. Obtener movimiento por ID
```
GET http://localhost:8090/movimientos/{id}
Ejemplo: GET http://localhost:8090/movimientos/1
```

### 4. Crear movimiento (Ruta principal usada por frontend)
```
POST http://localhost:8090/movimientos/simple
Content-Type: application/json

{
  "tipoMovimiento": "ENTRADA",
  "cantidad": 10,
  "descripcion": "Entrada de inventario",
  "productoId": 1,
  "usuarioNombre": "Admin",
  "usuarioEmail": "admin@admin.com"
}
```

---

## 📦 ProductosService (Puerto: 8084)

### 1. Health Check
```
GET http://localhost:8084/productos/health
```

### 2. Obtener todos los productos
```
GET http://localhost:8084/productos
```

### 3. Obtener producto por ID
```
GET http://localhost:8084/productos/{id}
Ejemplo: GET http://localhost:8084/productos/1
```

### 4. Crear producto
```
POST http://localhost:8084/productos
Content-Type: application/json

{
  "nombre": "Producto Test",
  "descripcion": "Descripción del producto",
  "precio": 999.99,
  "categoria": {
    "id": 1,
    "nombre": "Laptops"
  }
}
```

---

## 📊 StockService (Puerto: 8081)

### 1. Health Check
```
GET http://localhost:8081/stock/health
```

### 2. Obtener todo el stock
```
GET http://localhost:8081/stock
```

### 3. Obtener stock por ID
```
GET http://localhost:8081/stock/{id}
Ejemplo: GET http://localhost:8081/stock/1
```

### 4. Obtener stock por producto ID
```
GET http://localhost:8081/stock/producto/{productoId}
Ejemplo: GET http://localhost:8081/stock/producto/1
```

### 5. Crear stock
```
POST http://localhost:8081/stock
Content-Type: application/json

{
  "productoId": 1,
  "cantidadActual": 100,
  "umbralMinimo": 10
}
```

### 6. Actualizar stock
```
PUT http://localhost:8081/stock/{id}
Content-Type: application/json

{
  "productoId": 1,
  "cantidadActual": 50,
  "umbralMinimo": 5
}
```

---

## 👥 UsuariosService (Puerto: 8083)

### 1. Health Check
```
GET http://localhost:8083/usuarios/health
```

### 2. Obtener todos los usuarios
```
GET http://localhost:8083/usuarios
```

### 3. Login
```
POST http://localhost:8083/usuarios/login
Content-Type: application/json

{
  "correo": "admin@admin.com",
  "contrasena": "admin12345"
}
```

### 4. Crear usuario
```
POST http://localhost:8083/usuarios
Content-Type: application/json

{
  "nombre": "Usuario Test",
  "correo": "test@test.com",
  "contrasena": "password123",
  "rol": "USER"
}
```

---

## 🗂️ CategoriasService (Puerto: 8084)

### 1. Obtener todas las categorías
```
GET http://localhost:8084/categorias
```

### 2. Crear categoría
```
POST http://localhost:8084/categorias
Content-Type: application/json

{
  "nombre": "Nueva Categoría",
  "descripcion": "Descripción de la categoría"
}
```

---

## 📝 Notas Importantes

1. **Autenticación**: El sistema no usa JWT, pero requiere información del usuario en los movimientos.

2. **CORS**: Todos los servicios tienen CORS habilitado para desarrollo.

3. **Actualizaciones automáticas**: 
   - Crear un producto → crea stock automáticamente
   - Crear un movimiento → actualiza stock automáticamente

4. **Validaciones**:
   - Movimientos de SALIDA validan stock suficiente
   - No se permite stock negativo

5. **Base de datos**:
   - ProductosService: MySQL (persistente)
   - Otros servicios: H2 (en memoria, se pierde al reiniciar)

## 🔧 Testing Flow Recomendado

1. Verificar health checks de todos los servicios
2. Crear categorías
3. Crear productos (esto crea stock automáticamente)
4. Hacer login
5. Crear movimientos (esto actualiza stock automáticamente)
6. Verificar que el stock se actualizó correctamente
