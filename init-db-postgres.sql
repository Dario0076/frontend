-- Inicialización de bases de datos PostgreSQL para desarrollo local
-- Este script crea las 4 bases de datos necesarias para los microservicios

-- Crear base de datos para UsuariosService
CREATE DATABASE usuariosdb;

-- Crear base de datos para ProductosService  
CREATE DATABASE productosdb;

-- Crear base de datos para StockService
CREATE DATABASE stockdb;

-- Crear base de datos para MovimientoService
CREATE DATABASE movimientosdb;

-- Configurar permisos para el usuario postgres
GRANT ALL PRIVILEGES ON DATABASE usuariosdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE productosdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE stockdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE movimientosdb TO postgres;
