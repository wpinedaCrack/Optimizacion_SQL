/*1.Creacion de la BD BDEvaluacion Sql Server 2008,2012,2014,2016,2017,2019*/
USE master
GO
/*>=2016
   DROP DATABASE IF EXISTS BDEVALUACION
*/
IF EXISTS(SELECT * FROM SYS.DATABASES WHERE NAME='BDEVALUACION')
BEGIN
     ALTER DATABASE BDEVALUACION SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	 DROP DATABASE BDEVALUACION
END
GO
CREATE DATABASE BDEVALUACION ON PRIMARY
(NAME='BDEVALUACION',FILENAME='C:\DATA\BDEVALUACION.mdf',SIZE=1000MB,FILEGROWTH=0)
LOG ON
(NAME='BDEVALUACION_log',FILENAME='C:\DATA\BDEVALUACION_log.ldf',SIZE=10MB,
 MAXSIZE=2048GB,FILEGROWTH=50MB)
 GO
--ALTER DATABASE BDEVALUACION MODIFY FILE (NAME='BDEVALUACION',SIZE=1500MB)
--GO
--ALTER DATABASE BDEVALUACION MODIFY FILE (NAME='BDEVALUACION_log',SIZE=100MB)
--GO
USE BDEVALUACION
GO
CREATE TABLE tblDepartamento(IdDepartamento tinyint identity(1,1) ,
                             Departamento varchar(60) NOT NULL UNIQUE   ,
							 CONSTRAINT [PK_tblDepartamento_IdDepartamento] 
							 PRIMARY KEY NONCLUSTERED(IdDepartamento))
go
/*Agregar la siguiente tablas tblCargo,tblPeriodo y tblCompetencia,tblEvaluador */
CREATE TABLE tblCargo(IdCargo tinyint identity(1,1) ,
                      Cargo varchar(60) NOT NULL UNIQUE   ,
					  CONSTRAINT [PK_tblCargo_IdCargo] 
					  PRIMARY KEY NONCLUSTERED(IdCargo))

GO
CREATE TABLE tblPeriodo(IdPeriodo tinyint identity(1,1) ,
                        Periodo varchar(60) NOT NULL UNIQUE   ,
						CONSTRAINT [PK_tblPeriodo_IdPeriodo] 
						PRIMARY KEY NONCLUSTERED(IdPeriodo))
GO

CREATE TABLE tblCompetencia(IdCompetencia tinyint identity(1,1) ,
                            Competencia varchar(60) NOT NULL UNIQUE   ,
						    CONSTRAINT [PK_tblCompetencia_IdCompetencia] 
							PRIMARY KEY NONCLUSTERED(IdCompetencia))
GO
CREATE TABLE tblEvaluador(IdEvaluador tinyint identity(1,1) ,
                          Evaluador varchar(60) NOT NULL UNIQUE   ,
						  CONSTRAINT [PK_tblEvaluador_IdEvaluador] 
						  PRIMARY KEY NONCLUSTERED(IdEvaluador))

GO

CREATE TABLE tblEmpleado(IdEmpleado smallint identity(1,1),
                         Empleado  varchar(80) NOT NULL,
						 Sexo char(1) NOT NULL CHECK(SEXO IN ('M','F')),
						 IdDepartamento tinyint NOT  NULL,
						 IdCargo tinyint NOT NULL,
						 Nseguro char(9) not null unique 
						                 check(Nseguro like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
						CONSTRAINT [PK_tblEmpleado_IdEmpleado] PRIMARY KEY NONCLUSTERED (IdEmpleado),
						CONSTRAINT [FK_tblEmpleado_IdDepartamento] FOREIGN KEY (IdDepartamento) REFERENCES tblDepartamento (IdDepartamento),
						CONSTRAINT [FK_tblEmpleado_IdCargo] FOREIGN KEY (IdCargo) REFERENCES tblCargo (IdCargo)
						)

GO
CREATE TABLE tblSubCompetencia(IdSubCompetencia tinyint identity(1,1),
                               SubCompetencia  varchar(150) NOT NULL,
							   IdCompetencia tinyint NOT null,
							   CONSTRAINT [PK_tblSubCompetencia_IdSubCompetencia] PRIMARY KEY NONCLUSTERED (IdSubCompetencia),
							   CONSTRAINT [FK_tblSubCompetencia_IdCompetencia] FOREIGN KEY (IdCompetencia) REFERENCES tblCompetencia (IdCompetencia),
							   )
GO

CREATE TABLE tblEvaluacion (IdEvaluacion int identity(1,1),
                            Fecha date NOT NULL, 
							IdPeriodo tinyint NOT NULL,
							IdEmpleado smallint NOT NULL, 
							IdEvaluador tinyint NOT NULL,
							Fortalezas varchar(250),
							Oportunidades varchar(250),
							Recomendaciones varchar (250)
							CONSTRAINT [PK_tblEvaluacion_IdEvaluacion]  PRIMARY KEY NONCLUSTERED (IdEvaluacion),
							CONSTRAINT [FK_tblEvaluacion_IdPeriodo]     FOREIGN KEY(IdPeriodo)  REFERENCES  [tblPeriodo]   (IdPeriodo),
							CONSTRAINT [FK_tblEvaluacion_IdEmpleado]    FOREIGN KEY(IdEmpleado) REFERENCES  [tblEmpleado]  (IdEmpleado),
							CONSTRAINT [FK_tblEvaluacion_IdEvaluado]    FOREIGN KEY(IdEmpleado) REFERENCES  [tblEmpleado]  (IdEmpleado)
							
							 )
GO

CREATE TABLE tblEvaluacion_Detalle (IdEvaluacionD int identity(1,1) , 
                                    IdEvaluacion INT , 
									IdSubCompetencia tinyint, 
									Nota tinyint NOT NULL CHECK (Nota>=0 AND Nota<=100),
									CONSTRAINT [PK_tblEvaluacion_Detalle_IdEvaluacionD]    PRIMARY KEY NONCLUSTERED (IdEvaluacionD),
									CONSTRAINT [FK_tblEvaluacion_Detalle_IdEvaluacion]      FOREIGN KEY(IdEvaluacion)      REFERENCES  [tblEvaluacion]      (IdEvaluacion),
						            CONSTRAINT [FK_tblEvaluacion_Detalle_IdSubCompetencia]  FOREIGN KEY(IdSubCompetencia)  REFERENCES  [tblSubCompetencia]  (IdSubCompetencia)
									)

go
ALTER TABLE tblEvaluacion ADD CONSTRAINT [FK_tblEvaluacion_IdEvaluador]  
FOREIGN KEY(IdEvaluador)  REFERENCES  [tblEvaluador]  (IdEvaluador)