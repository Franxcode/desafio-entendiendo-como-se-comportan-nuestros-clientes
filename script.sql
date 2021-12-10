-- Postulacion Empresa patito.
-- USE below structure to execute, make sure to change "user" by your database user.
-- psql < script.sql -U "user"
-- USE below structure to restore or import a database. Make sure to create the database before using the command for it to work.
-- psql -U user previouslyCreatedDBName < toImportDBName.sql // example: psql -U francisco  unidad2 < unidad2.sql

-- To successfully complete the requirements, you must have auto commit disabled.
-- \set AUTOCOMMIT off

-- DROP DATABASE unidad2;

CREATE DATABASE unidad2;

-- Me conecto a la base de datos.
\c unidad2

-- 1) Cargar el respaldo de la base de datos unidad2.sql - Asegurarse de tener la base de datos unidad2 previamente creada, use below commented command for this purpose.
-- psql -U francisco  unidad2 < unidad2.sql

-- 2) El cliente usuario01 ha realizado la siguiente compra:
--  * producto: producto9.
--  * cantidad: 5.
--  * fecha: fecha del sistema.

-- Primero quiero saber las compras que ha hecho el cliente usuario01 en el producto seleccionado y ver el stock.
SELECT cliente.id, cliente.nombre, compra.id, compra.cliente_id, compra.fecha, detalle_compra.id, detalle_compra.producto_id, detalle_compra.compra_id, detalle_compra.cantidad, producto.id, producto.descripcion, producto.stock, producto.precio
FROM cliente 
INNER JOIN compra ON cliente.id=compra.cliente_id
INNER JOIN detalle_compra ON compra.id=detalle_compra.compra_id
INNER JOIN producto ON detalle_compra.producto_id=producto.id
WHERE cliente.nombre = 'usuario01' AND detalle_compra.producto_id=9 AND producto.descripcion='producto9';

-- Ahora vamos a insertar una nueva compra con las mismas caracteristicas y revisar si se descuenta del stock, hacemos una nueva compra con las caracteristicas solicitadas en el punto 2).
BEGIN TRANSACTION;
INSERT INTO compra (id, cliente_id, fecha) VALUES (33, 1, '2021-12-09')
RETURNING *;
INSERT INTO detalle_compra (id, producto_id, compra_id, cantidad) VALUES (43, 9, 33, 5)
RETURNING *;
UPDATE producto SET stock = stock - 5 WHERE producto.id = 9 AND producto.descripcion = 'producto9'
RETURNING *;
END TRANSACTION;

-- Volvemos a consultar, deberiamos tener una nueva compra del producto 9, cantidad 5, con una fecha mas reciente y una reduccion del stock en comparacion a la query anterior.
SELECT cliente.id, cliente.nombre, compra.id, compra.cliente_id, compra.fecha, detalle_compra.id, detalle_compra.producto_id, detalle_compra.compra_id, detalle_compra.cantidad, producto.id, producto.descripcion, producto.stock, producto.precio
FROM cliente 
INNER JOIN compra ON cliente.id=compra.cliente_id
INNER JOIN detalle_compra ON compra.id=detalle_compra.compra_id
INNER JOIN producto ON detalle_compra.producto_id=producto.id
WHERE cliente.nombre = 'usuario01' AND detalle_compra.producto_id=9 AND producto.descripcion='producto9';

-- 3) El cliente usuario02 ha realizado la siguiente compra:
-- * producto: producto1, producto2, producto8.
-- * cantidad: 3 de cada producto.
-- * fecha: fecha del sistema.

-- Primero quiero saber las compras que ha hecho el cliente usuario02 en los productos seleccionados y ver el stock.
SELECT cliente.id, cliente.nombre, compra.id, compra.cliente_id, compra.fecha, detalle_compra.id, detalle_compra.producto_id, detalle_compra.compra_id, detalle_compra.cantidad, producto.id, producto.descripcion, producto.stock, producto.precio
FROM cliente 
INNER JOIN compra ON cliente.id=compra.cliente_id
INNER JOIN detalle_compra ON compra.id=detalle_compra.compra_id
INNER JOIN producto ON detalle_compra.producto_id=producto.id
WHERE cliente.nombre = 'usuario02' AND detalle_compra.producto_id IN(1, 2, 8) AND producto.descripcion IN('producto1','producto2','producto8');

-- Hacemos una nueva compra con las caracteristicas solicitadas en el punto 3).
BEGIN TRANSACTION;
INSERT INTO compra (id, cliente_id, fecha) VALUES (34, 2, '2021-12-09')
RETURNING *;
INSERT INTO detalle_compra (id, producto_id, compra_id, cantidad) VALUES (44, 1, 34, 3)
RETURNING *;
UPDATE producto SET stock = stock - 3 WHERE producto.id = 1 AND producto.descripcion = 'producto1'
RETURNING *;
INSERT INTO detalle_compra (id, producto_id, compra_id, cantidad) VALUES (45, 2, 34, 3)
RETURNING *;
UPDATE producto SET stock = stock - 3 WHERE producto.id = 2 AND producto.descripcion = 'producto2'
RETURNING *;
SAVEPOINT checkpoint;
INSERT INTO detalle_compra (id, producto_id, compra_id, cantidad) VALUES (46, 8, 34, 3)
RETURNING *;
UPDATE producto SET stock = stock - 3 WHERE producto.id = 8 AND producto.descripcion = 'producto8'
RETURNING *;
ROLLBACK TO checkpoint;
END TRANSACTION;

-- Volvemos a consultar, deberiamos tener una nueva compra del producto 1, producto 2, producto 8, cantidad 5, con una fecha mas reciente y una reduccion del stock en comparacion a la query anterior.
SELECT cliente.id, cliente.nombre, compra.id, compra.cliente_id, compra.fecha, detalle_compra.id, detalle_compra.producto_id, detalle_compra.compra_id, detalle_compra.cantidad, producto.id, producto.descripcion, producto.stock, producto.precio
FROM cliente 
INNER JOIN compra ON cliente.id=compra.cliente_id
INNER JOIN detalle_compra ON compra.id=detalle_compra.compra_id
INNER JOIN producto ON detalle_compra.producto_id=producto.id
WHERE cliente.nombre = 'usuario02' AND detalle_compra.producto_id IN(1, 2, 8) AND producto.descripcion IN('producto1','producto2','producto8');


-- 4) Realizar las siguientes consultas:
-- a. Deshabilitar el AUTOCOMMIT.
-- \set AUTOCOMMIT off
-- b. Insertar un nuevo cliente. (En base al lo que piden en el punto d y e, debo agregar un cliente nuevo y luego regresar al punto anterior donde ese cliente no estaba en la tabla)
BEGIN TRANSACTION;
SAVEPOINT nuevo_cliente;
INSERT INTO cliente(id, nombre, email) VALUES (11, 'usuario011', 'usuario011@gmail.com');

-- c. Confirmar que fue agregado en la tabla cliente.
SELECT * 
FROM cliente
ORDER BY cliente.id ASC;

-- d. Realizar un ROLLBACK.
ROLLBACK TO nuevo_cliente;

-- e. Confirmar que se restauró la información, sin considerar la inserción del punto b.
SELECT * 
FROM cliente
ORDER BY cliente.id ASC;
END TRANSACTION;
-- f. Habilitar de nuevo el AUTOCOMMIT.
-- \set AUTOCOMMIT on