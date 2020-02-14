--
-- ER/Studio 8.0 SQL Code Generation
-- Company :      Cristian
-- Project :      Posgrado.DM1
-- Author :       Cristian
--
-- Date Created : Thursday, February 06, 2020 22:17:36
-- Target DBMS : MySQL 5.x
--
DROP DATABASE IF EXISTS Posgrado;
CREATE DATABASE IF NOT EXISTS Posgrado;
USE Posgrado;
-- 
-- TABLE: Clientes 
--

CREATE TABLE Clientes(
    IdCliente    INT    NOT NULL,
    PRIMARY KEY (IdCliente)
)ENGINE=MYISAM
;



-- 
-- TABLE: Compras 
--

CREATE TABLE Compras(
    IdCompra       BIGINT    AUTO_INCREMENT,
    FechaCompra    DATE      NOT NULL,
    IdProveedor    INT       NOT NULL,
    IdEmpleado     INT       NOT NULL,
    PRIMARY KEY (IdCompra)
)ENGINE=MYISAM
;



-- 
-- TABLE: Empleados 
--

CREATE TABLE Empleados(
    IdEmpleado      INT            NOT NULL,
    Rol             VARCHAR(30)    NOT NULL,
    Usuario         VARCHAR(30)    NOT NULL,
    Password        CHAR(32)       NOT NULL,
    FechaIngreso    DATE           NOT NULL,
    PRIMARY KEY (IdEmpleado)
)ENGINE=MYISAM
;



-- 
-- TABLE: LineasCompras 
--

CREATE TABLE LineasCompras(
    IdCompra          BIGINT         NOT NULL,
    IdProducto        BIGINT         NOT NULL,
    IdRubro           BIGINT         NOT NULL,
    CantidadCompra    INT            NOT NULL,
    PrecioCompra      FLOAT(8, 0)    NOT NULL,
    PRIMARY KEY (IdCompra, IdProducto, IdRubro)
)ENGINE=MYISAM
;



-- 
-- TABLE: LineasVentas 
--

CREATE TABLE LineasVentas(
    IdVenta          BIGINT         NOT NULL,
    IdProducto       BIGINT         NOT NULL,
    IdRubro          BIGINT         NOT NULL,
    CantidadVenta    INT            NOT NULL,
    PrecioVenta      FLOAT(8, 0)    NOT NULL,
    PRIMARY KEY (IdVenta, IdProducto, IdRubro)
)ENGINE=MYISAM
;



-- 
-- TABLE: Personas 
--

CREATE TABLE Personas(
    IdPersona    INT            NOT NULL,
    Telefono     VARCHAR(12),
    EstadoPer    CHAR(1)        DEFAULT 'I' NOT NULL,
    PRIMARY KEY (IdPersona)
)ENGINE=MYISAM
;



-- 
-- TABLE: PersonasFisicas 
--

CREATE TABLE PersonasFisicas(
    IdPersona    INT             NOT NULL,
    Apellidos    VARCHAR(40)     NOT NULL,
    Nombres      VARCHAR(50)     NOT NULL,
    Email        VARCHAR(120),
    PRIMARY KEY (IdPersona)
)ENGINE=MYISAM
;



-- 
-- TABLE: Productos 
--

CREATE TABLE Productos(
    IdProducto    BIGINT         AUTO_INCREMENT,
    IdRubro       BIGINT         NOT NULL,
    Producto      VARCHAR(30)    NOT NULL,
    EstadoProd    CHAR(1)        DEFAULT 'I' NOT NULL,
    PRIMARY KEY (IdProducto, IdRubro)
)ENGINE=MYISAM
;



-- 
-- TABLE: Proveedores 
--

CREATE TABLE Proveedores(
    IdProveedor    INT            NOT NULL,
    Proveedor      VARCHAR(50)    NOT NULL,
    PRIMARY KEY (IdProveedor)
)ENGINE=MYISAM
;



-- 
-- TABLE: Rubros 
--

CREATE TABLE Rubros(
    IdRubro      BIGINT         AUTO_INCREMENT,
    Rubro        VARCHAR(30)    NOT NULL,
    EstadoRub    CHAR(1)        DEFAULT 'I' NOT NULL,
    PRIMARY KEY (IdRubro)
)ENGINE=MYISAM
;



-- 
-- TABLE: Ventas 
--

CREATE TABLE Ventas(
    IdVenta       BIGINT         AUTO_INCREMENT,
    FechaVenta    DATE           NOT NULL,
    Descuento     FLOAT(8, 0),
    IdCliente     INT            NOT NULL,
    IdEmpleado    INT            NOT NULL,
    PRIMARY KEY (IdVenta)
)ENGINE=MYISAM
;



-- 
-- INDEX: Ref29 
--

CREATE INDEX Ref29 ON Clientes(IdCliente)
;
-- 
-- INDEX: IX_FechaCompra 
--

CREATE INDEX IX_FechaCompra ON Compras(FechaCompra)
;
-- 
-- INDEX: Ref313 
--

CREATE INDEX Ref313 ON Compras(IdProveedor)
;
-- 
-- INDEX: Ref515 
--

CREATE INDEX Ref515 ON Compras(IdEmpleado)
;
-- 
-- INDEX: UI_Usuario 
--

CREATE UNIQUE INDEX UI_Usuario ON Empleados(Usuario)
;
-- 
-- INDEX: UI_UsuarioRol 
--

CREATE UNIQUE INDEX UI_UsuarioRol ON Empleados(Usuario, Rol)
;
-- 
-- INDEX: IX_FechaIngreso 
--

CREATE INDEX IX_FechaIngreso ON Empleados(FechaIngreso)
;
-- 
-- INDEX: Ref210 
--

CREATE INDEX Ref210 ON Empleados(IdEmpleado)
;
-- 
-- INDEX: Ref719 
--

CREATE INDEX Ref719 ON LineasCompras(IdCompra)
;
-- 
-- INDEX: Ref1120 
--

CREATE INDEX Ref1120 ON LineasCompras(IdRubro, IdProducto)
;
-- 
-- INDEX: Ref817 
--

CREATE INDEX Ref817 ON LineasVentas(IdVenta)
;
-- 
-- INDEX: Ref1118 
--

CREATE INDEX Ref1118 ON LineasVentas(IdProducto, IdRubro)
;
-- 
-- INDEX: UI_Email 
--

CREATE UNIQUE INDEX UI_Email ON PersonasFisicas(Email)
;
-- 
-- INDEX: Ref11 
--

CREATE INDEX Ref11 ON PersonasFisicas(IdPersona)
;
-- 
-- INDEX: Ref916 
--

CREATE INDEX Ref916 ON Productos(IdRubro)
;
-- 
-- INDEX: UI_Proveedor 
--

CREATE UNIQUE INDEX UI_Proveedor ON Proveedores(Proveedor)
;
-- 
-- INDEX: Ref12 
--

CREATE INDEX Ref12 ON Proveedores(IdProveedor)
;
-- 
-- INDEX: UI_Rubro 
--

CREATE UNIQUE INDEX UI_Rubro ON Rubros(Rubro)
;
-- 
-- INDEX: IX_FechaVenta 
--

CREATE INDEX IX_FechaVenta ON Ventas(FechaVenta)
;
-- 
-- INDEX: Ref411 
--

CREATE INDEX Ref411 ON Ventas(IdCliente)
;
-- 
-- INDEX: Ref512 
--

CREATE INDEX Ref512 ON Ventas(IdEmpleado)
;
-- 
-- TABLE: Clientes 
--

ALTER TABLE Clientes ADD CONSTRAINT RefPersonasFisicas9 
    FOREIGN KEY (IdCliente)
    REFERENCES PersonasFisicas(IdPersona)
;


-- 
-- TABLE: Compras 
--

ALTER TABLE Compras ADD CONSTRAINT RefProveedores13 
    FOREIGN KEY (IdProveedor)
    REFERENCES Proveedores(IdProveedor)
;

ALTER TABLE Compras ADD CONSTRAINT RefEmpleados15 
    FOREIGN KEY (IdEmpleado)
    REFERENCES Empleados(IdEmpleado)
;


-- 
-- TABLE: Empleados 
--

ALTER TABLE Empleados ADD CONSTRAINT RefPersonasFisicas10 
    FOREIGN KEY (IdEmpleado)
    REFERENCES PersonasFisicas(IdPersona)
;


-- 
-- TABLE: LineasCompras 
--

ALTER TABLE LineasCompras ADD CONSTRAINT RefCompras19 
    FOREIGN KEY (IdCompra)
    REFERENCES Compras(IdCompra)
;

ALTER TABLE LineasCompras ADD CONSTRAINT RefProductos20 
    FOREIGN KEY (IdProducto, IdRubro)
    REFERENCES Productos(IdProducto, IdRubro)
;


-- 
-- TABLE: LineasVentas 
--

ALTER TABLE LineasVentas ADD CONSTRAINT RefVentas17 
    FOREIGN KEY (IdVenta)
    REFERENCES Ventas(IdVenta)
;

ALTER TABLE LineasVentas ADD CONSTRAINT RefProductos18 
    FOREIGN KEY (IdProducto, IdRubro)
    REFERENCES Productos(IdProducto, IdRubro)
;


-- 
-- TABLE: PersonasFisicas 
--

ALTER TABLE PersonasFisicas ADD CONSTRAINT RefPersonas1 
    FOREIGN KEY (IdPersona)
    REFERENCES Personas(IdPersona)
;


-- 
-- TABLE: Productos 
--

ALTER TABLE Productos ADD CONSTRAINT RefRubros16 
    FOREIGN KEY (IdRubro)
    REFERENCES Rubros(IdRubro)
;


-- 
-- TABLE: Proveedores 
--

ALTER TABLE Proveedores ADD CONSTRAINT RefPersonas2 
    FOREIGN KEY (IdProveedor)
    REFERENCES Personas(IdPersona)
;


-- 
-- TABLE: Ventas 
--

ALTER TABLE Ventas ADD CONSTRAINT RefClientes11 
    FOREIGN KEY (IdCliente)
    REFERENCES Clientes(IdCliente)
;

ALTER TABLE Ventas ADD CONSTRAINT RefEmpleados12 
    FOREIGN KEY (IdEmpleado)
    REFERENCES Empleados(IdEmpleado)
;

