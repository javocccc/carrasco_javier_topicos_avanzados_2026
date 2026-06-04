-- 1. Nos movemos a tu usuario
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- 2. Creamos las tablas
CREATE TABLE Clientes (
    ClienteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    FechaNacimiento DATE
);

CREATE TABLE Pedidos (
    PedidoID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaPedido DATE,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

CREATE TABLE Productos (
    ProductoID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Precio NUMBER
);

CREATE TABLE DetallesPedidos (
    DetalleID NUMBER PRIMARY KEY,
    PedidoID NUMBER,
    ProductoID NUMBER,
    Cantidad NUMBER,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- 3. Insertamos todos los datos
INSERT INTO Clientes VALUES (1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
INSERT INTO Clientes VALUES (2, 'María Gomez', 'Valparaiso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
INSERT INTO Clientes VALUES (3, 'Ana Lopez', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));

INSERT INTO Pedidos VALUES (101, 1, 600, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
INSERT INTO Pedidos VALUES (102, 1, 300, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));

INSERT INTO Productos VALUES (1, 'Laptop', 1200);
INSERT INTO Productos VALUES (2, 'Mouse', 25);

INSERT INTO DetallesPedidos VALUES (1, 101, 1, 2); 
INSERT INTO DetallesPedidos VALUES (2, 101, 2, 5); 

-- 4. Guardamos los cambios
COMMIT;
