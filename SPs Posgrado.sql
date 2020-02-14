
DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_buscar_proveedores` (pCadena varchar(60), pIncluyeBajas char(1))
BEGIN
	/*Permite buscar los proveedores dada una cadena de búsqueda que contenga una parte 
    del nombre. Puede o no incluir los proveedores dados de baja según pIncluyeBajas
    (S: Si - N: No). . Para listar todos, cadena vacía. Proveedores es un json de la 
    forma: [{"IdProveedor": 1, "Proveedor": "Proveedor1", "Telefono":'111 1'}, {...},....].*/
	
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT		pr.IdProveedor, pr.Proveedor ,pe.Telefono, pe.EstadoPer
    FROM		Proveedores pr JOIN Personas pe on pr.IdProveedor=pe.IdPersona
    WHERE		pr.Proveedor LIKE CONCAT('%',pCadena,'%') AND
				(pIncluyeBajas = 'S' OR (pIncluyeBajas = 'N' AND EstadoPer = 'A'))
	GROUP BY	pr.IdProveedor
	ORDER BY	3;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

CALL `bsp_buscar_proveedores` ('Lenovo', 'N');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_autocompletar_proveedores`(pCadena varchar(60), pIncluyeBajas char(1))
BEGIN
	/*Permite listar todos los proveedores que cumplan con la condición de autocompletar 
    de la cadena de búsqueda que coincida con el nombre del proveedor. Puede o no incluir
    los proveedores dados de baja según pIncluyeBajas (S: Si - N: No).
    Busca a partir del cuarto caracter y ordena por nombre.*/

    SELECT		pr.IdProveedor, pr.Proveedor ,pe.Telefono, pe.EstadoPer
    FROM		Proveedores pr JOIN Personas pe on pr.IdProveedor=pe.IdPersona
    WHERE		pr.Proveedor LIKE CONCAT('%',pCadena,'%') AND
				(pIncluyeBajas = 'S' OR (pIncluyeBajas = 'N' AND EstadoPer = 'A')) AND
                CHAR_LENGTH(pCadena) > 3
	ORDER BY	pr.Proveedor;

END$$
DELIMITER ;

CALL `bsp_autocompletar_proveedores` ('Leno', 'N');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_alta_proveedores` ( pProveedor varchar(60),pTelefono char(10))
BEGIN
	/*Permite dar de alta un proveedor controlando que el nombre no exista ya, con estado
    A: Activo. Devuelve OK + Id o el mensaje de error en Mensaje.*/
SALIR:BEGIN
	DECLARE pIdProveedor,pIdPersona smallint;
	-- Manejo de error en la transacción
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje,
				NULL AS Id;
		ROLLBACK;
	END;
    -- Controla que el nombre sea obligatorio 
	IF pProveedor = '' OR pProveedor IS NULL THEN
		SELECT 'Debe proveer un nombre para el proveedor' AS Mensaje, NULL AS Id;
		LEAVE SALIR;
    END IF;
    -- Controla que no exista un proveedor con el mismo nombre
	IF EXISTS(SELECT Proveedor FROM Proveedores WHERE Proveedor = pProveedor) THEN
		SELECT 'Ya existe un proveedor con ese nombre' AS Mensaje, NULL AS Id;
		LEAVE SALIR;
    END IF;
	START TRANSACTION;
		SET pIdProveedor = 1 + (SELECT COALESCE(MAX(IdProveedor),0)
								FROM Proveedores);
		SET pIdPersona = 1 + (SELECT COALESCE(MAX(IdPersona),0)
								FROM Personas);
		INSERT INTO Personas VALUES(pIdPersona,pTelefono,'I');
		INSERT INTO Proveedores VALUES(pIdProveedor, pProveedor );
        SELECT 'OK' AS Mensaje, pIdProveedor AS Id;
        -- SELECT CONCAT('OK', pIdProveedor) AS Mensaje;
    COMMIT;
END;

END$$

DELIMITER ;

CALL `bsp_alta_proveedores` ('Apple','25452541');
CALL `bsp_alta_proveedores` ('Apple','25452541');
CALL `bsp_alta_proveedores` ('','25452541');

SELECT * FROM Proveedores;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_modifica_empleados` ( pIdEmpleado smallint, pNombres varchar(50),pApellidos varchar(20),pRol varchar(20),pUsuario varchar(30),pTelefono char(12))
BEGIN
	/*Permite modificar un empleado existente controlando que el mismo no exista ya. 
    Devuelve OK o el mensaje de error en Mensaje.*/
    SALIR:BEGIN
    DECLARE pIdPersona smallint;
    -- Controlo parámetros
    IF pApellidos IS NULL OR pApellidos = '' THEN
		SELECT 'El apellido es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF pNombres IS NULL OR pNombres = '' THEN
		SELECT 'El nombre es obligatorio.' AS Mensaje;
        LEAVE SALIR; 
	END IF;
    -- Controlar si el empleado existe
    IF NOT EXISTS(SELECT IdEmpleado FROM Empleados WHERE IdEmpleado = pIdEmpleado) THEN
		SELECT 'El empleado que quiere modificar no existe.' AS Mensaje;
        LEAVE SALIR; 
	END IF;
    -- Controlar usuario existente
    IF EXISTS(SELECT Usuario FROM Empleados WHERE Usuario = pUsuario 
						AND IdEmpleado != pIdEmpleado) THEN
		SELECT 'Ya existe un empleado con ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	
    SET pIdPersona = (SELECT IdEmpleado FROM Empleados WHERE IdEmpleado=pIdEmpleado);
	UPDATE Personas
    SET Telefono=pTelefono
    WHERE IdPersona=pIdPersona;
    UPDATE PersonasFisicas
    SET Apellidos = pApellidos, Nombres = pNombres
    WHERE IdPersona= pIdPersona;
	UPDATE	Empleados
	SET	Rol = pRol, Usuario = pUsuario
	WHERE	IdEmpleado = pIdEmpleado;

	SELECT 'OK' AS Mensaje;
END;
END$$

DELIMITER ;

SELECT * FROM Empleados;

CALL `bsp_modifica_empleados` ( 11, 'Raul Edgardo','Juarez','Vendedor','rejuarez','4545152');
CALL `bsp_modifica_empleados` ( 12, 'Raul Edgardo','Juarez','Vendedor','rejuarez','4545152');
CALL `bsp_modifica_empleados` ( 11, '','Juarez','Vendedor','rejuarez','4545152');
CALL `bsp_modifica_empleados` ( 11, 'Raul Edgardo','','Vendedor','rejuarez','4545152');
CALL `bsp_modifica_empleados` ( 21, 'Raul Edgardo','Juarez','Vendedor','rejuez','4545152');

SELECT * FROM Empleados;
SELECT * FROM PersonasFisicas;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_borra_empleados` (pIdEmpleado smallint)
BEGIN
	/*Permite borrar un empleado . Devuelve OK o el mensaje de error en Mensaje.*/
    SALIR:BEGIN
    DECLARE pIdPersona smallint;
    -- Controla parámetros
    IF pIdEmpleado = 1 THEN
		SELECT 'No puede borrar el empleado. Es una cuenta del sistema.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlar si el empleado existe
    IF NOT EXISTS(SELECT IdEmpleado FROM Empleados WHERE IdEmpleado = pIdEmpleado) THEN
		SELECT 'El empleado que quiere borrar no existe.' AS Mensaje;
        LEAVE SALIR; 
	END IF;
    SET pIdPersona = (SELECT IdEmpleado FROM Empleados WHERE IdEmpleado=pIdEmpleado);
    DELETE FROM Personas WHERE IdPersona = pIdPersona ;
    DELETE FROM Empleados WHERE IdEmpleado = pIdEmpleado;
    
    SELECT 'OK' AS Mensaje;
END;
END$$

DELIMITER ;

CALL `bsp_borra_empleados` (10);
CALL `bsp_borra_empleados` (20);
CALL `bsp_borra_empleados` (1);

SELECT * FROM Empleados;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_darbaja_empleado` (pIdEmpleado smallint)
BEGIN
	/*Permite cambiar el estado del empleado a I: Inactiva siempre y cuando no esté inactiva 
    ya . Devuelve OK o el mensaje de error en Mensaje.*/
    SALIR:BEGIN
	DECLARE pIdPersona smallint;
    SET pIdPersona = (SELECT IdEmpleado FROM Empleados WHERE IdEmpleado=pIdEmpleado);
    -- Controlar empleado no este dado de baja
    IF EXISTS(SELECT IdPersona FROM Personas WHERE IdPersona = pIdPersona
						AND EstadoPer = 'I') THEN
		SELECT 'La persona ya está dada de baja.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF pIdEmpleado = 1 THEN
		SELECT 'No puede dar de baja el empleado. Es una cuenta del sistema.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlar si el empleado existe
    IF NOT EXISTS(SELECT IdEmpleado FROM Empleados WHERE IdEmpleado = pIdEmpleado) THEN
		SELECT 'El empleado que quiere dar de baja no existe.' AS Mensaje;
        LEAVE SALIR; 
	END IF;
	-- Da de baja
    UPDATE Personas SET EstadoPer = 'I' WHERE IdPersona = pIdPersona;
	
    SELECT 'OK' AS Mensaje;
END;

END$$

DELIMITER ;

CALL `bsp_darbaja_empleado` (9);
CALL `bsp_darbaja_empleado` (14);
CALL `bsp_darbaja_empleado` (1);
CALL `bsp_darbaja_empleado` (15);

SELECT * FROM Empleados;

SELECT * FROM Personas;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_activar_persona` (pIdPersona smallint)
BEGIN
	/*Permite cambiar el estado de la persona a A: Activo siempre y cuando no esté activo
    ya. Devuelve OK o el mensaje de error en Mensaje.*/
    SALIR:BEGIN
	-- Controlar autor no activo ya
    IF EXISTS(SELECT IdPersona FROM Personas WHERE IdPersona = pIdPersona
						AND EstadoPer = 'A') THEN
		SELECT 'La persona ya está activa.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Activa
    UPDATE Personas SET EstadoPer = 'A' WHERE IdPersona = pIdPersona;
	
    SELECT 'OK' AS Mensaje;
END;

END$$

DELIMITER ;

CALL `bsp_activar_persona` (5);
CALL `bsp_activar_persona` (10);

SELECT * FROM Personas;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_listar_clientes_ventas` (pFechaInicio date, pFechaFin date , pIncluyeBajas char(1))
BEGIN
	/*Permite listar las ventas  ordenadas por clientes entre un rango de fechas. 
    Puede mostrar o no las dadas de baja (pIncluyeBajas: S: Si - N: No)*/
	SELECT		v.IdVenta,v.FechaVenta,v.Descuento,pf.Nombres,pf.Apellidos
    FROM		Ventas v LEFT JOIN Clientes c ON v.IdCliente=c.IdCliente LEFT JOIN PersonasFisicas pf ON c.IdCliente=pf.IdPersona
				LEFT JOIN Personas p ON	pf.IdPersona=p.IdPersona
    WHERE		v.FechaVenta BETWEEN pFechaInicio AND pFechaFin AND
				(pIncluyeBajas = 'S' OR (pIncluyeBajas = 'N' AND EstadoPer = 'A'))
	ORDER BY	v.IdCliente;
    
END$$

DELIMITER ;

CALL `bsp_listar_clientes_ventas` ('2011/01/02', '2011/12/31' , 'S')

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_buscar_clientes` (pCadena varchar(100), pIncluyeBajas char(1),pOffset int, pRowCount int)
BEGIN
	/*Permite buscar los clientes que contengan una parte del apellido, nombre o email .
    Ordena por apellidos, luego por nombres. Puede incluir o no los dados de baja
    (pIncluyeBajas: S: SI - N: No). Para todos, cadena vacía. Incluye paginado.
    */
   
     DECLARE pTotalRows int;
	 SHOW ERRORS;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_clientes;
    CREATE TEMPORARY TABLE tmp_clientes  ENGINE = MEMORY AS -- Ejemplo de índice en TT
    SELECT		c.*
    FROM		Clientes c LEFT JOIN PersonasFisicas pf ON c.IdCliente=pf.IdPersona 
				LEFT JOIN Personas p ON pf.IdPersona=p.IdPersona 
    WHERE		(Apellidos LIKE CONCAT(pCadena,'%') OR
				Nombres LIKE CONCAT(pCadena,'%') OR
                Email LIKE CONCAT(pCadena,'%')) AND
                (pIncluyeBajas = 'S' OR EstadoPer = 'A')
	ORDER BY	Apellidos, Nombres;
    -- Averigua total de filas para botones de navegación de paginado
    SET pTotalRows = (SELECT COUNT(*) FROM tmp_clientes);
    -- CONSULTA FINAL
    SELECT *, pTotalRows TotalRows FROM tmp_clientes LIMIT pOffset, pRowCount;
	
    DROP TEMPORARY TABLE IF EXISTS tmp_clientes;
    
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

CALL `bsp_buscar_clientes` ('Ariel','S',1, 1);-- no me muestra resultados
CALL `bsp_buscar_clientes` ('','S',null, null); 
	

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_autocompletar_clientes` (pCadena varchar(100), pIncluyeBajas char(1))
BEGIN
	/*Permite listar todos los clientes que cumplan con la condición de autocompletar de
    la cadena de búsqueda que coincida con el nombre del cliente o apellido . Puede 
    incluir o no los dados de baja (pIncluyeBajas: S: SI - N: No). Busca a partir del 
    cuarto caracter y ordena por apellidos, luego por nombres. Limita a 20.*/
     SELECT		IdCliente,
				CONCAT(Apellidos,', ',Nombres,' (',
                Email,')') Cliente
    FROM		Clientes c LEFT JOIN PersonasFisicas pf ON c.IdCliente=pf.IdPersona 
				LEFT JOIN Personas p ON pf.IdPersona=p.IdPersona 
    WHERE		(Apellidos LIKE CONCAT(pCadena,'%') OR
				Nombres LIKE CONCAT(pCadena,'%') OR
                Email LIKE CONCAT(pCadena,'%'))
                AND CHAR_LENGTH(pCadena) > 3 AND
                (pIncluyeBajas = 'S' OR EstadoPer = 'A')
	ORDER BY	Apellidos, Nombres
    LIMIT		20;
END$$

DELIMITER ;

CALL  `bsp_autocompletar_clientes` ('Vare', 'S');
CALL  `bsp_autocompletar_clientes` ('Var', 'S');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_alta_clientes`(pNombres varchar(30), pApellidos varchar(20), 
										pTelefono char(10), pEmail varchar(100))
SALIR:BEGIN
	/*Permite dar de alta un cliente controlando que el correo electrónico no exista ya,
    y apellidos y nombres no pueden ser vacíos ni nulos. Lo da de alta en estado I: Inactivo.
    Devuelve OK + Id o el mensaje de error en Mensaje.*/
    DECLARE pIdCliente , pIdPersona bigint;
    -- Manejo de error de la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador' Mensaje, NULL AS Id;
        ROLLBACK;
    END;
    -- Control de parámetros
    IF pApellidos IS NULL OR pApellidos = '' THEN
		SELECT 'El apellido es obligatorio.' AS Mensaje, NULL AS Id;
        LEAVE SALIR;
    END IF;
    IF pNombres IS NULL OR pNombres = '' THEN
		SELECT 'El nombre es obligatorio.' AS Mensaje, NULL AS Id;
        LEAVE SALIR;
    END IF;
    IF EXISTS(SELECT Email FROM PersonasFisicas 
				WHERE Email = pEmail) THEN
		SELECT 'El correo electrónico ya existe.' AS Mensaje, NULL AS Id;
        LEAVE SALIR;
    END IF;
    
    START TRANSACTION;
		SET pIdCliente = 1 +  (SELECT COALESCE(MAX(IdCliente),0)
								FROM Clientes);
        SET pIdPersona = 1 + (SELECT COALESCE(MAX(IdPersona),0)
								FROM PersonasFisicas);
		
        -- Inserta
        INSERT INTO Clientes VALUES(pIdCliente);
        INSERT INTO PersonasFisicas VALUES(pIdPersona,pApellidos, pNombres, pEmail);
        INSERT INTO Personas VALUES(pIdPersona,pTelefono,'I');
        
        
        -- Devuelve último insertado
        -- SET pIdCliente = LAST_INSERT_ID();
        
		SELECT 'OK' Mensaje, pIdCliente AS Id;
    COMMIT;
    
END$$

DELIMITER ;

CALL `bsp_alta_clientes`('','Vega','245458','luisvega@gmail.com');
CALL `bsp_alta_clientes`('Luis','','245458','luisvega@gmail.com');
CALL `bsp_alta_clientes`('Luis','Vega','245458','ariel@gmail.com');
CALL `bsp_alta_clientes`('Luis','Vega','245458','luisvega@gmail.com');

SELECT * FROM Clientes;

SELECT * FROM Personas;

SELECT * FROM PersonasFisicas;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_modifica_clientes` (pIdCliente bigint, pApellidos varchar(30), pNombres varchar(20), pTelefono char(10), pEmail varchar(100))
SALIR:BEGIN
	/*Permite modificar un cliente existente controlando que el email no exista ya, y que
    apellidos y nombres no puedan ser vacíos ni nulos. Devuelve OK o el mensaje de error
    en Mensaje.*/
    -- Controlo parámetros
    SHOW ERRORS;
    IF pApellidos IS NULL OR pApellidos = '' THEN
		SELECT 'El apellido es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF pNombres IS NULL OR pNombres = '' THEN
		SELECT 'El nombre es obligatorio.' AS Mensaje;
        LEAVE SALIR; 
	END IF;
    -- Controlar si el cliente existe
    IF NOT EXISTS(SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
		SELECT 'El cliente que quiere modificar no existe.' AS Mensaje;
        LEAVE SALIR; 
	END IF;
    -- Controlar correo existente
    IF EXISTS(SELECT Email FROM PersonasFisicas WHERE 
				Email = pEmail AND IdPersona != pIdCliente) THEN
		SELECT 'Ya existe un cliente con ese correo electrónico.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	UPDATE	PersonasFisicas
	SET		Apellidos = pApellidos, Nombres = pNombres, Email = pEmail
	WHERE	IdPersona = pIdCliente;
	UPDATE Personas 
    SET Telefono = pTelefono 
    WHERE IdPersona = pIdCliente;
	SELECT 'OK' AS Mensaje;


END$$

DELIMITER ;

CALL `bsp_modifica_clientes` (21,'','Roberto','456525','roberto@gmail.com');
CALL `bsp_modifica_clientes` (11,'Juarez','Roberto','456525','luisvega@gmail.com');
CALL `bsp_modifica_clientes` (22,'Juarez','','456525','roberto@gmail.com');
CALL `bsp_modifica_clientes` (21,'Juarez','sdgfsgf','456525','luisvega@gmail.com');
CALL `bsp_modifica_clientes` (21,'Juarez','sdgfsgf','456525','udfgfgrhh@gmail.com');

SELECT * FROM PersonasFisicas;

DELIMITER $$
USE `posgrado`$$
CREATE  PROCEDURE `bsp_alta_ventas`(pFechaVenta DATE,pDescuento FLOAT,pIdCliente INT 
									,pIdEmpleado INT)
SALIR:BEGIN
	/*Permite dar de alta una venta */
    DECLARE pIdVenta smallint;
	-- Manejo de error en la transacción
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje,
				NULL AS Id;
		ROLLBACK;
	END;
    -- Controla que la fecha de venta sea obligatoria 
	IF pFechaVenta IS NULL THEN
		SELECT 'Debe proveer un una fecha valida' AS Mensaje, NULL AS Id;
		LEAVE SALIR;
    END IF;
	START TRANSACTION;
		SET pIdVenta = 1 + (SELECT COALESCE(MAX(IdVenta),0)
								FROM Ventas);
		INSERT INTO Ventas VALUES(pIdVenta, pFechaVenta, pDescuento, pIdCliente, pIdEmpleado);
        SELECT 'OK' AS Mensaje, pIdVenta AS Id;
    COMMIT;
END$$

DELIMITER ;

CALL `bsp_alta_ventas`('2020-01-01',null,1,5);
CALL `bsp_alta_ventas`(null,null,1,5);

SELECT * FROM Ventas;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_alta_compras` (pFechaCompra date, pIdProveedor int  ,pIdEmpleado int)
SALIR:BEGIN
	/*Procedimiento que sirve para dar de alta una compra.*/
     DECLARE pIdCompra smallint;
	-- Manejo de error en la transacción
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje,
				NULL AS Id;
		ROLLBACK;
	END;
    -- Controla que la fecha de venta sea obligatoria 
	IF pFechaCompra IS NULL THEN
		SELECT 'Debe proveer un una fecha valida' AS Mensaje, NULL AS Id;
		LEAVE SALIR;
    END IF;
	START TRANSACTION;
		SET pIdCompra = 1 + (SELECT COALESCE(MAX(IdCompra),0)
								FROM Compras);
		INSERT INTO Compras VALUES(pIdCompra, pFechaCompra, pIdProveedor, pIdEmpleado);
        SELECT 'OK' AS Mensaje, pIdCompra AS Id;
    COMMIT;
END$$

DELIMITER ;

CALL `bsp_alta_compras` ('2020-01-30',5,6);
CALL `bsp_alta_compras` (NULL,5,6);

SELECT * FROM Compras;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_buscar_avanzado_compras` (pFechaInicio date, pFechaFin date ,pIncluyeBajas char(1))
BEGIN
	/*Lista todas las compras entre un rango de fechas ordenadas por fecha y luego
    por proveedor*/
	SELECT		c.IdCompra,c.FechaCompra,p.Proveedor
    FROM		Compras c JOIN Proveedores p ON c.IdProveedor=p.IdProveedor JOIN Personas pe ON
				p.IdProveedor=pe.IdPersona
    WHERE		c.FechaCompra BETWEEN pFechaInicio AND pFechaFin AND
				(pIncluyeBajas = 'S' OR (pIncluyeBajas = 'N' AND EstadoPer = 'A'))
	ORDER BY	c.FechaCompra, p.IdProveedor;
END$$

DELIMITER ;

CALL `bsp_buscar_avanzado_compras` ('2019-01-01', '2020-01-30','S');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_buscar_productos` (pCadena varchar(100), pIncluyeBajas char(1),
											pOffset int, pRowCount int)
BEGIN
	/*Permite buscar los productos que contengan una parte del  nombre . Ordena por 
    nombre. Puede incluir o no los dados de baja (pIncluyeBajas: S: SI - N: No). 
    Para todos, cadena vacía. Incluye paginado.*/
    DECLARE pTotalRows int;
	-- SHOW ERRORS;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_productos;
    CREATE TEMPORARY TABLE tmp_productos  ENGINE = MEMORY AS -- Ejemplo de índice en TT
    SELECT		p.*
    FROM		Productos p  
    WHERE		(Producto LIKE CONCAT(pCadena,'%') ) AND
                (pIncluyeBajas = 'S' OR EstadoProd = 'A')
	ORDER BY	Producto;
    -- Averigua total de filas para botones de navegación de paginado
    SET pTotalRows = (SELECT COUNT(*) FROM tmp_productos);
    -- CONSULTA FINAL
    SELECT *, pTotalRows TotalRows FROM tmp_productos LIMIT pOffset, pRowCount;
	
    DROP TEMPORARY TABLE IF EXISTS tmp_productos;
    
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

CALL `bsp_buscar_productos` ('Notebook','S',1, 1);-- nomuestra registros


DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_listar_productos_rubros` (pIncluyeBajas char(1))
BEGIN
	/*Permite listar los productos ordenados por rubros y luego por productos*/
    SELECT		p.*, r.Rubro, r.EstadoRub
    FROM		Productos p JOIN Rubros r on p.IdRubro=r.IdRubro
    WHERE		(pIncluyeBajas = 'S' OR (pIncluyeBajas = 'N' AND EstadoProd = 'A'))
	ORDER BY	r.Rubro, p.Producto;
END$$

DELIMITER ;

CALL `bsp_listar_productos_rubros` ('N');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_buscar_avanzado_ventas` (pFechaInicio date, pFechaFin date ,pIncluyeBajas char(1))
BEGIN
	/*Permite buscar las ventas entre dos fechas.Ordenado por fecha y luego por cliente. 
    Puede mostrar o no los clientes dados de baja (pIncluyeBajas: S: Si - N: No)*/
	SELECT		v.IdVenta,v.FechaVenta,pf.Nombres, pf.Apellidos
    FROM		Ventas v JOIN Clientes c ON v.IdCliente=c.IdCliente JOIN PersonasFisicas pf ON
				c.IdCliente=pf.IdPersona JOIN Personas pe ON pf.IdPersona=pe.IdPersona
    WHERE		v.FechaVenta BETWEEN pFechaInicio AND pFechaFin AND
				(pIncluyeBajas = 'S' OR (pIncluyeBajas = 'N' AND EstadoPer = 'A'))
	ORDER BY	v.FechaVenta, pf.Apellidos, pf.Nombres;
END$$

DELIMITER ;

CALL `bsp_buscar_avanzado_ventas` ('2010-01-01','2012-01-30' ,'S');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_listar_empleados_ventas` (pIdEmpleado int, pFechaInicio date , pFechaFin date)
BEGIN
	/*Permite Listar todas las ventas de un empleado entre un rango de fechas */
	SELECT		v.IdVenta,v.FechaVenta,pf.Nombres, pf.Apellidos
    FROM		Ventas v LEFT JOIN Empleados e ON v.IdEmpleado=e.IdEmpleado LEFT JOIN PersonasFisicas pf ON 
				e.IdEmpleado=pf.IdPersona
    WHERE		e.IdEmpleado = pIdEmpleado AND v.FechaVenta BETWEEN pFechaInicio AND pFechaFin 
	ORDER BY	v.FechaVenta, pf.Apellidos, pf.Nombres;
END$$

DELIMITER ;

CALL `bsp_listar_empleados_ventas` (12, '2010-01-01' , '2012-05-05');

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_alta_rubro` ( pRubro varchar(30), pEstadoRub char(1))
SALIR:BEGIN
	/*Permite dar de alta un rubro verificando que el rubro no este ya dado de alta . 
    Devuelve OK o el mensaje de error en Mensaje.*/
    DECLARE pIdRubro smallint;
	-- Manejo de error en la transacción
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje,
				NULL AS Id;
		ROLLBACK;
	END;
    -- Controla que el rubro sea obligatorio 
	IF pRubro = '' OR pRubro IS NULL THEN
		SELECT 'Debe proveer un nombre para el rubro' AS Mensaje, NULL AS Id;
		LEAVE SALIR;
    END IF;
    -- Controla que no exista un rubro con el mismo nombre
	IF EXISTS(SELECT Rubro FROM Rubros WHERE Rubro = pRubro) THEN
		SELECT 'Ya existe un rubro con ese nombre' AS Mensaje, NULL AS Id;
		LEAVE SALIR;
    END IF;
	START TRANSACTION;
		SET pIdRubro = 1 + (SELECT COALESCE(MAX(IdRubro),0)
								FROM Rubros);
		INSERT INTO Rubros VALUES(pIdRubro, pRubro, pEstadoRub);
        SELECT 'OK' AS Mensaje, pIdRubro AS Id;
    COMMIT;
END$$

DELIMITER ;

CALL `bsp_alta_rubro` ( '', 'A');
CALL `bsp_alta_rubro` ( 'PC', 'A');
CALL `bsp_alta_rubro` ( 'Celulares', 'A');

SELECT * FROM Rubros;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_borra_rubro` (pIdRubro bigint)
SALIR:BEGIN
	/*Permite borrar el rubro.  Devuelve OK o el mensaje de error en Mensaje.*/
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
		ROLLBACK;
	END;
    -- Controla que el rubro no tenga productos
	IF EXISTS(SELECT IdRubro FROM Productos WHERE IdRubro = pIdRubro) THEN
		SELECT 'No puede borrar el rubro. Existen productos asociados.' AS Mensaje;
		LEAVE SALIR;
    END IF;
	START TRANSACTION;
        -- Borra categorías
        DELETE FROM Rubros WHERE IdRubro = pIdRubro;
		
        SELECT 'OK' AS Mensaje;
	COMMIT;
END$$

DELIMITER ;

CALL `bsp_borra_rubro` (11);
CALL `bsp_borra_rubro` (6);

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_darbaja_rubro` (pIdRubro bigint)
SALIR:BEGIN
	/*Permite cambiar el estado del rubro a I: Baja siempre y cuando no esté dada de baja
    ya . Devuelve OK o el mensaje de error en Mensaje.*/
     -- Manejo de error de la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador' Mensaje;
    END;
    -- Control de parámetros
    IF NOT EXISTS(SELECT IdRubro FROM Rubros WHERE 
				IdRubro = pIdRubro) THEN
		SELECT 'No existe el rubro que quiere desactivar.' AS Mensaje;
        LEAVE SALIR;
    END IF;
    
    IF NOT EXISTS(SELECT IdRubro FROM Rubros WHERE 
				IdRubro = pIdRubro AND EstadoRub = 'I') THEN
		SELECT 'El rubro ya está inactivo.' AS Mensaje;
        LEAVE SALIR;
    END IF;
    
    IF EXISTS(SELECT IdRubro FROM Productos WHERE 
				IdRubro = pIdRubro AND EstadoProd = 'A') THEN
		SELECT 'No puede inactivar el rubro. Existen productos activos.' 
				AS Mensaje;
        LEAVE SALIR;
    END IF;
    
	-- Da de baja
	UPDATE Rubros SET EstadoRub = 'I'
	WHERE IdRubro = pIdRubro;
	
	SELECT 'OK' Mensaje;
END$$

DELIMITER ;

CALL `bsp_darbaja_rubro` (14);
CALL `bsp_darbaja_rubro` (9);
CALL `bsp_darbaja_rubro` (1);

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_modifica_producto` ( pIdProducto bigint, pProducto varchar(30))
SALIR:BEGIN
	/*Permite modificar un producto existente controlando que el  rubro exista y esté 
    activo y que tenga nombre. Devuelve OK o el mensaje de error en Mensaje.*/
    -- Manejo de error en la transacción
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
		ROLLBACK;
	END;
    -- controla si es un producto existente
    IF NOT EXISTS(SELECT IdProducto FROM Productos WHERE  IdProducto = pIdProducto) THEN
		SELECT 'Por Favor ingrese un producto existente' AS Mensaje;
		LEAVE SALIR;
    END IF;
    -- Controla que la producto sea obligatorio 
	IF pProducto = '' OR pProducto IS NULL THEN
		SELECT 'Debe proveer un nombre para el producto' AS Mensaje;
		LEAVE SALIR;
    END IF;
    -- Controla que exista el producto en un rubro activo
	IF NOT EXISTS(SELECT p.IdRubro FROM Productos p JOIN Rubros r ON p.IdRubro=r.IdRubro 
		WHERE  IdProducto = pIdProducto AND r.EstadoRub='A') THEN
		SELECT 'Ingrese un producto para un rubro activo' AS Mensaje;
		LEAVE SALIR;
    END IF;
    
	UPDATE Productos SET Producto = pProducto WHERE IdProducto = pIdProducto;
	SELECT 'OK' AS Mensaje;
END$$

DELIMITER ;

CALL `bsp_modifica_producto` ( 15,'Parlantes');
CALL `bsp_modifica_producto` ( 10,'');
CALL `bsp_modifica_producto` ( 10,'Parlantes');
CALL `bsp_modifica_producto` ( 7,'Impresora Laser');

SELECT * FROM Productos;

DELIMITER $$
USE `posgrado`$$
CREATE PROCEDURE `bsp_darbaja_producto` (pIdProducto smallint)
SALIR:BEGIN
	/*Permite cambiar el estado del producto a I: Inactivo siempre y cuando no esté inactivo
    ya . Devuelve OK o el mensaje de error en Mensaje.*/
	-- Manejo de error de la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador' Mensaje;
    END;
    -- Control de parámetros
    IF NOT EXISTS(SELECT IdProducto FROM Productos WHERE 
				IdProducto = pIdProducto) THEN
		SELECT 'No existe el producto que quiere inactivar.' AS Mensaje;
        LEAVE SALIR;
    END IF;
    
    IF NOT EXISTS(SELECT IdProducto FROM Productos WHERE 
				IdProducto = pIdProducto AND EstadoProd = 'A') THEN
		SELECT 'El producto ya está inactivo.' AS Mensaje;
        LEAVE SALIR;
    END IF;
        
	-- Da de baja
	UPDATE Productos SET EstadoProd = 'I'
	WHERE IdProducto = pIdProducto;
	
	SELECT 'OK' Mensaje;
END$$

DELIMITER ;

CALL `bsp_darbaja_producto` (15);
CALL `bsp_darbaja_producto` (12);
CALL `bsp_darbaja_producto` (11);

SELECT * FROM Productos;


DELIMITER $$
USE `posgrado`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `bsp_ver_stock`(pIdProducto bigint)
SALIR:BEGIN
	/*Permite ver el stock de un producto determinado.*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
		ROLLBACK;
	END;
	-- Controla que la producto sea obligatorio 
	IF pIdProducto = '' OR pIdProducto IS NULL THEN
		SELECT 'Debe proveer un codigo de producto' AS Mensaje;
		LEAVE SALIR;
    END IF;
    -- controla si es un producto existente
    IF NOT EXISTS(SELECT IdProducto FROM Productos WHERE  IdProducto = pIdProducto) THEN
		SELECT 'Por Favor ingrese un producto existente' AS Mensaje;
		LEAVE SALIR;
    END IF;
   
    
    SELECT (SUM(CantidadCompra)-SUM(CantidadVenta)) as Cantidad
    FROM LineasCompras lc JOIN Productos p ON lc.IdProducto = p.IdProducto
    JOIN LineasVentas lv ON p.IdProducto = lv.IdProducto
    WHERE p.IdProducto = pIdProducto;
	-- SELECT 'OK' AS Mensaje;
END$$

DELIMITER ;

CALL `bsp_ver_stock`(null);
CALL `bsp_ver_stock`(15);
CALL `bsp_ver_stock`(1);
CALL `bsp_ver_stock`(5);

