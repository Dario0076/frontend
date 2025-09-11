-- Script de inicialización para crear las bases de datos
CREATE DATABASE IF NOT EXISTS usuariosdb;
CREATE DATABASE IF NOT EXISTS productosdb;
CREATE DATABASE IF NOT EXISTS stockdb;
CREATE DATABASE IF NOT EXISTS movimientosdb;

-- Crear usuario con permisos
CREATE USER IF NOT EXISTS 'inventario'@'%' IDENTIFIED BY 'inventario123';
GRANT ALL PRIVILEGES ON usuariosdb.* TO 'inventario'@'%';
GRANT ALL PRIVILEGES ON productosdb.* TO 'inventario'@'%';
GRANT ALL PRIVILEGES ON stockdb.* TO 'inventario'@'%';
GRANT ALL PRIVILEGES ON movimientosdb.* TO 'inventario'@'%';
FLUSH PRIVILEGES;
