# API de Biblioteca - Guía de Desarrollo Paso a Paso

Este proyecto es una API REST para un sistema de biblioteca desarrollada con Node.js, Express, Sequelize y MySQL. Se desarrollará siguiendo un orden específico para facilitar el aprendizaje.

## 📋 Orden de Desarrollo

1. [Configuración Inicial](#1-configuración-inicial)
2. [Conexión a Base de Datos](#2-conexión-a-base-de-datos)
3. [Modelo Categoría (Primero - Simple)](#3-modelo-categoría)
4. [CRUD Categorías](#4-crud-categorías)
5. [Modelo Usuario (DESARROLLADO COMPLETO)](#5-modelo-usuario)
6. [Autenticación de Usuario (DESARROLLADO COMPLETO)](#6-autenticación-de-usuario)
7. [Modelo Libro](#7-modelo-libro)
8. [Modelo Préstamo](#8-modelo-préstamo)
9. [CRUD Libros con Autenticación](#9-crud-libros)
10. [Sistema de Préstamos](#10-sistema-de-préstamos)
11. [Validaciones y Seguridad](#11-validaciones-y-seguridad)
12. [Refactorización a Servicios](#12-refactorización-a-servicios)

---

## 🛠 Requisitos Previos

- Node.js >= 16.0.0
- MySQL >= 8.0
- NPM o Yarn
- Postman (para testing)

---

## 1. Configuración Inicial

### 1.1 Crear el proyecto
```bash
mkdir biblioteca-api
cd biblioteca-api
npm init -y
```

### 1.2 Instalar dependencias básicas
```bash
npm install express
npm install --save-dev nodemon
```

### 1.3 Crear estructura de carpetas
```bash
mkdir config controllers middleware models routes services
```

### 1.4 Configurar package.json
```json
{
  "name": "biblioteca-api",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}
```

### 1.5 Crear servidor básico (server.js)
```javascript
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares básicos
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Ruta de prueba
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Servidor funcionando correctamente',
    timestamp: new Date().toISOString()
  });
});

// Middleware para rutas no encontradas
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada'
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/api/health`);
});
```

### ✅ Checkpoint 1
- [ ] `npm run dev` inicia el servidor
- [ ] http://localhost:3000/api/health responde correctamente
- [ ] Estructura de carpetas creada

---

## 2. Conexión a Base de Datos

### 2.1 Instalar dependencias de base de datos
```bash
npm install sequelize mysql2 dotenv
```

### 2.2 Crear archivo .env
```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_NAME=biblioteca_db
DB_USER=biblioteca_app
DB_PASSWORD=BibliotecaApp2024!
JWT_SECRET=mi_clave_secreta_super_segura_para_jwt_2024
JWT_EXPIRE=7d
```

### 2.3 Crear config/database.js
```javascript
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    define: {
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at',
      underscored: true
    }
  }
);

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Conexión a MySQL establecida correctamente');
    await sequelize.sync({ force: false });
    console.log('✅ Modelos sincronizados con la base de datos');
  } catch (error) {
    console.error('❌ Error al conectar con la base de datos:', error);
    process.exit(1);
  }
};

module.exports = { sequelize, connectDB };
```

### 2.4 Actualizar server.js para incluir DB
```javascript
const express = require('express');
const { connectDB } = require('./config/database');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Servidor funcionando correctamente',
    timestamp: new Date().toISOString()
  });
});

app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada'
  });
});

// Inicializar servidor
const startServer = async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
      console.log(`🏥 Health check: http://localhost:${PORT}/api/health`);
    });
  } catch (error) {
    console.error('❌ Error al iniciar el servidor:', error);
    process.exit(1);
  }
};

startServer();
```

### ✅ Checkpoint 2
- [ ] Conexión a MySQL establecida
- [ ] Logs de conexión aparecen al iniciar servidor
- [ ] No hay errores de base de datos

---

## 3. Modelo Categoría

**¿Por qué empezamos con Categoría?**
- Es el modelo más simple
- No tiene relaciones complejas
- Permite practicar Sequelize básico

### 3.1 Crear models/Categoria.js
```javascript
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Categoria = sequelize.define('Categoria', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nombre: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: { msg: 'Ya existe una categoría con este nombre' },
    validate: {
      notEmpty: { msg: 'El nombre es requerido' }
    }
  },
  descripcion: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'categorias'
});

module.exports = Categoria;
```

### ✅ Checkpoint 3
- [ ] Tabla `categorias` se crea en MySQL
- [ ] Modelo puede crear registros
- [ ] Validaciones funcionan

---

## 4. CRUD Categorías

### 4.1 Crear controllers/CategoriaController.js
```javascript
// TODO: Desarrollar controlador de categorías
// Métodos a implementar:
// - obtenerCategorias (GET)
// - obtenerCategoriaPorId (GET por ID)
// - crearCategoria (POST)
// - actualizarCategoria (PUT)
// - eliminarCategoria (DELETE)
```

### 4.2 Crear routes/categorias.js
```javascript
// TODO: Crear rutas para categorías
// GET /api/categorias
// GET /api/categorias/:id
// POST /api/categorias
// PUT /api/categorias/:id
// DELETE /api/categorias/:id
```

### 4.3 Actualizar server.js
```javascript
// TODO: Agregar rutas de categorías al servidor
// app.use('/api/categorias', categoriasRoutes);
```

### ✅ Checkpoint 4
- [ ] CRUD básico de categorías implementado
- [ ] Todas las rutas responden correctamente
- [ ] Manejo de errores básico

---

## 5. Modelo Usuario (DESARROLLADO COMPLETO)

### 5.1 Instalar bcryptjs para passwords
```bash
npm install bcryptjs
```

### 5.2 Crear models/Usuario.js
```javascript
const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');
const { sequelize } = require('../config/database');

const Usuario = sequelize.define('Usuario', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nombre: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      notEmpty: { msg: 'El nombre es requerido' },
      len: { args: [2, 100], msg: 'El nombre debe tener entre 2 y 100 caracteres' }
    }
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: { msg: 'Este email ya está registrado' },
    validate: {
      isEmail: { msg: 'Debe ser un email válido' }
    }
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      len: { args: [6, 255], msg: 'La contraseña debe tener al menos 6 caracteres' }
    }
  },
  rol: {
    type: DataTypes.ENUM('admin', 'bibliotecario', 'usuario'),
    defaultValue: 'usuario'
  },
  activo: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'usuarios',
  hooks: {
    beforeCreate: async (usuario) => {
      if (usuario.password) {
        usuario.password = await bcrypt.hash(usuario.password, 12);
      }
    },
    beforeUpdate: async (usuario) => {
      if (usuario.changed('password')) {
        usuario.password = await bcrypt.hash(usuario.password, 12);
      }
    }
  }
});

// Método para comparar contraseñas
Usuario.prototype.compararPassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

module.exports = Usuario;
```

### ✅ Checkpoint 5
- [ ] Tabla `usuarios` creada
- [ ] Password se hashea automáticamente
- [ ] Método `compararPassword` funciona

---

## 6. Autenticación de Usuario (DESARROLLADO COMPLETO)

### 6.1 Instalar JWT
```bash
npm install jsonwebtoken
```

### 6.2 Crear services/AuthService.js
```javascript
const jwt = require('jsonwebtoken');
const Usuario = require('../models/Usuario');

class AuthService {
  static generarToken(id) {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRE
    });
  }

  static async registrarUsuario(datosUsuario) {
    try {
      const usuarioExistente = await Usuario.findOne({
        where: { email: datosUsuario.email }
      });

      if (usuarioExistente) {
        throw new Error('El email ya está registrado');
      }

      const usuario = await Usuario.create(datosUsuario);
      const token = this.generarToken(usuario.id);

      // No devolver la contraseña
      const { password, ...usuarioSinPassword } = usuario.toJSON();

      return {
        usuario: usuarioSinPassword,
        token
      };
    } catch (error) {
      throw error;
    }
  }

  static async loginUsuario(email, password) {
    try {
      const usuario = await Usuario.findOne({
        where: { email, activo: true }
      });

      if (!usuario || !(await usuario.compararPassword(password))) {
        throw new Error('Credenciales inválidas');
      }

      const token = this.generarToken(usuario.id);
      const { password: _, ...usuarioSinPassword } = usuario.toJSON();

      return {
        usuario: usuarioSinPassword,
        token
      };
    } catch (error) {
      throw error;
    }
  }
}

module.exports = AuthService;
```

### 6.3 Crear middleware/auth.js
```javascript
const jwt = require('jsonwebtoken');
const Usuario = require('../models/Usuario');

const verificarToken = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Acceso denegado. Token no proporcionado'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const usuario = await Usuario.findByPk(decoded.id);
    
    if (!usuario || !usuario.activo) {
      return res.status(401).json({
        success: false,
        message: 'Usuario no válido o inactivo'
      });
    }

    req.usuario = usuario;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Token no válido'
    });
  }
};

const verificarRol = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.usuario.rol)) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para realizar esta acción'
      });
    }
    next();
  };
};

module.exports = { verificarToken, verificarRol };
```

### 6.4 Crear controllers/AuthController.js
```javascript
const AuthService = require('../services/AuthService');

class AuthController {
  static async registro(req, res) {
    try {
      const { nombre, email, password, rol } = req.body;
      
      const resultado = await AuthService.registrarUsuario({
        nombre, email, password, rol
      });

      res.status(201).json({
        success: true,
        message: 'Usuario registrado exitosamente',
        data: resultado
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message || 'Error al registrar usuario'
      });
    }
  }

  static async login(req, res) {
    try {
      const { email, password } = req.body;
      
      const resultado = await AuthService.loginUsuario(email, password);

      res.json({
        success: true,
        message: 'Login exitoso',
        data: resultado
      });
    } catch (error) {
      res.status(401).json({
        success: false,
        message: error.message || 'Error en el login'
      });
    }
  }

  static async perfil(req, res) {
    try {
      const { password, ...usuario } = req.usuario.toJSON();
      res.json({
        success: true,
        data: { usuario }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al obtener perfil'
      });
    }
  }

  static async obtenerUsuarios(req, res) {
    try {
      const { page = 1, limit = 10, rol } = req.query;
      const offset = (page - 1) * limit;
      
      const whereClause = {};
      if (rol) whereClause.rol = rol;

      const { count, rows } = await Usuario.findAndCountAll({
        where: whereClause,
        attributes: { exclude: ['password'] },
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['nombre', 'ASC']]
      });

      res.json({
        success: true,
        data: {
          usuarios: rows,
          pagination: {
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit),
            totalItems: count,
            itemsPerPage: parseInt(limit)
          }
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al obtener usuarios'
      });
    }
  }

  static async obtenerUsuarioPorId(req, res) {
    try {
      const { id } = req.params;
      const usuario = await Usuario.findByPk(id, {
        attributes: { exclude: ['password'] }
      });

      if (!usuario) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      res.json({
        success: true,
        data: { usuario }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al obtener usuario'
      });
    }
  }

  static async actualizarUsuario(req, res) {
    try {
      const { id } = req.params;
      const usuario = await Usuario.findByPk(id);

      if (!usuario) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      // No permitir actualizar email si ya existe
      if (req.body.email && req.body.email !== usuario.email) {
        const emailExistente = await Usuario.findOne({
          where: { email: req.body.email }
        });
        
        if (emailExistente) {
          return res.status(400).json({
            success: false,
            message: 'El email ya está registrado'
          });
        }
      }

      await usuario.update(req.body);
      
      const { password, ...usuarioActualizado } = usuario.toJSON();

      res.json({
        success: true,
        message: 'Usuario actualizado exitosamente',
        data: { usuario: usuarioActualizado }
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message || 'Error al actualizar usuario'
      });
    }
  }

  static async desactivarUsuario(req, res) {
    try {
      const { id } = req.params;
      const usuario = await Usuario.findByPk(id);

      if (!usuario) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      await usuario.update({ activo: false });

      res.json({
        success: true,
        message: 'Usuario desactivado exitosamente'
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al desactivar usuario'
      });
    }
  }
}

module.exports = AuthController;
```

### 6.5 Crear routes/auth.js
```javascript
const express = require('express');
const AuthController = require('../controllers/AuthController');
const { verificarToken, verificarRol } = require('../middleware/auth');

const router = express.Router();

// Rutas públicas
router.post('/registro', AuthController.registro);
router.post('/login', AuthController.login);

// Rutas protegidas - Perfil del usuario
router.get('/perfil', verificarToken, AuthController.perfil);

// Rutas protegidas - Solo admin puede gestionar usuarios
router.get('/usuarios', 
  verificarToken, 
  verificarRol('admin'), 
  AuthController.obtenerUsuarios
);

router.get('/usuarios/:id', 
  verificarToken, 
  verificarRol('admin'), 
  AuthController.obtenerUsuarioPorId
);

router.put('/usuarios/:id', 
  verificarToken, 
  verificarRol('admin'), 
  AuthController.actualizarUsuario
);

router.patch('/usuarios/:id/desactivar', 
  verificarToken, 
  verificarRol('admin'), 
  AuthController.desactivarUsuario
);

module.exports = router;
```

### 6.6 Actualizar server.js
```javascript
// Agregar después de los middlewares básicos
const authRoutes = require('./routes/auth');

// Rutas
app.use('/api/auth', authRoutes);
```

### ✅ Checkpoint 6
Probar en Postman:
- [ ] POST /api/auth/registro (registrar usuario)
- [ ] POST /api/auth/login (iniciar sesión)
- [ ] GET /api/auth/perfil (con token)
- [ ] GET /api/auth/usuarios (solo admin)
- [ ] GET /api/auth/usuarios/:id (solo admin)
- [ ] PUT /api/auth/usuarios/:id (solo admin)
- [ ] PATCH /api/auth/usuarios/:id/desactivar (solo admin)

---

## 7. Modelo Libro

### 7.1 Crear models/Libro.js
```javascript
// TODO: Desarrollar modelo Libro
// Campos requeridos:
// - id (PK, autoincrement)
// - titulo (string, required)
// - autor (string, required)
// - isbn (string, unique, optional)
// - categoria_id (FK a Categoria)
// - ejemplares_total (integer, min: 1)
// - ejemplares_disponibles (integer, min: 0)
// - fecha_publicacion (date, optional)
// - descripcion (text, optional)
//
// Validaciones:
// - ejemplares_disponibles <= ejemplares_total
//
// Relaciones:
// - belongsTo Categoria
```

### ✅ Checkpoint 7
- [ ] Tabla `libros` creada
- [ ] Relación con categorías funciona
- [ ] Validaciones de ejemplares funcionan

---

## 8. Modelo Préstamo

### 8.1 Crear models/Prestamo.js
```javascript
// TODO: Desarrollar modelo Préstamo
// Campos requeridos:
// - id (PK, autoincrement)
// - usuario_id (FK a Usuario)
// - libro_id (FK a Libro)
// - fecha_prestamo (date, default: now)
// - fecha_vencimiento (date, required)
// - fecha_devolucion (date, optional)
// - estado (enum: 'activo', 'devuelto', 'vencido')
// - multa (decimal, default: 0.00)
//
// Relaciones:
// - belongsTo Usuario
// - belongsTo Libro
```

### 8.2 Crear models/index.js para relaciones
```javascript
// TODO: Definir todas las relaciones entre modelos
// - Categoria hasMany Libro
// - Libro belongsTo Categoria
// - Usuario hasMany Prestamo
// - Libro hasMany Prestamo
// - Prestamo belongsTo Usuario y Libro
```

### ✅ Checkpoint 8
- [ ] Tabla `prestamos` creada
- [ ] Todas las relaciones funcionan
- [ ] Consultas con include funcionan

---

## 9. CRUD Libros

### 9.1 Crear services/LibroService.js
```javascript
// TODO: Desarrollar servicio de libros
// Métodos a implementar:
// - obtenerLibros(filtros) - con paginación y filtros
// - crearLibro(datosLibro)
// - actualizarDisponibilidad(libroId, operacion)
```

### 9.2 Crear controllers/LibroController.js
```javascript
// TODO: Desarrollar controlador de libros
// Métodos a implementar:
// - obtenerLibros (público, con filtros y paginación)
// - obtenerLibroPorId (público)
// - crearLibro (admin/bibliotecario)
// - actualizarLibro (admin/bibliotecario)
// - eliminarLibro (solo admin)
//
// Filtros a implementar:
// - Por título
// - Por autor
// - Por categoría
// - Paginación
```

### 9.3 Crear routes/libros.js
```javascript
// TODO: Crear rutas de libros con protección
// GET /api/libros (público)
// GET /api/libros/:id (público)
// POST /api/libros (protegida: admin/bibliotecario)
// PUT /api/libros/:id (protegida: admin/bibliotecario)
// DELETE /api/libros/:id (protegida: solo admin)
```

### ✅ Checkpoint 9
- [ ] CRUD completo de libros
- [ ] Filtros y paginación funcionan
- [ ] Protección por roles implementada
- [ ] Include de categoría funciona

---

## 10. Sistema de Préstamos

### 10.1 Crear controllers/PrestamoController.js
```javascript
// TODO: Desarrollar controlador de préstamos
// Métodos a implementar:
// - crearPrestamo (verificar disponibilidad, actualizar inventario)
// - devolverLibro (calcular multas, actualizar estados)
// - obtenerPrestamos (filtros por estado, usuario, vencidos)
// - obtenerPrestamosPorUsuario (mis préstamos)
//
// Lógica de negocio:
// - Verificar disponibilidad del libro
// - Verificar que usuario no tenga préstamos vencidos
// - Calcular fecha de vencimiento
// - Actualizar ejemplares disponibles
// - Calcular multas por días vencidos
```

### 10.2 Crear routes/prestamos.js
```javascript
// TODO: Crear rutas de préstamos
// POST /api/prestamos (admin/bibliotecario)
// PUT /api/prestamos/:id/devolver (admin/bibliotecario)
// GET /api/prestamos (admin/bibliotecario)
// GET /api/prestamos/mis-prestamos (usuario autenticado)
```

### ✅ Checkpoint 10
- [ ] Lógica de préstamos completa
- [ ] Actualización de inventario automática
- [ ] Cálculo de multas funciona
- [ ] Usuarios pueden ver sus préstamos

---

## 11. Validaciones y Seguridad

### 11.1 Instalar dependencias de validación
```bash
npm install express-validator cors helmet express-rate-limit
```

### 11.2 Crear middleware/validation.js
```javascript
// TODO: Desarrollar middleware de validaciones
// Validaciones a implementar:
// - validacionUsuario (nombre, email, password)
// - validacionLibro (titulo, autor, ejemplares)
// - validacionPrestamo (libro_id, usuario_id, dias_prestamo)
// - validarCampos (middleware genérico)
```

### 11.3 Agregar seguridad al server.js
```javascript
// TODO: Agregar middlewares de seguridad
// - helmet() para headers de seguridad
// - cors() configurado apropiadamente
// - express-rate-limit para limitar requests
// - Middleware de manejo de errores global
```

### ✅ Checkpoint 11
- [ ] Validaciones funcionan en todos los endpoints
- [ ] Rate limiting implementado
- [ ] CORS configurado
- [ ] Headers de seguridad activos

---

## 12. Refactorización a Servicios

### 12.1 Refactorizar AuthService
```javascript
// TODO: Mejorar AuthService existente
// - Agregar más validaciones
// - Mejorar manejo de errores
// - Optimizar consultas
```

### 12.2 Crear otros servicios
```javascript
// TODO: Crear servicios adicionales
// - LibroService (ya mencionado en paso 9)
// - PrestamoService
// - CategoriaService
```

### 12.3 Refactorizar controladores
```javascript
// TODO: Actualizar controladores para usar servicios
// - Controladores más delgados
// - Lógica de negocio en servicios
// - Separación clara de responsabilidades
```

### ✅ Checkpoint 12
- [ ] Lógica de negocio en servicios
- [ ] Controladores más limpios
- [ ] Código más mantenible

---

## 🧪 Testing con Postman

### Colección de Usuario (DESARROLLADA)

#### Registro de Usuario
```http
POST /api/auth/registro
Content-Type: application/json

{
  "nombre": "Juan Pérez",
  "email": "juan@email.com",
  "password": "123456",
  "rol": "usuario"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "juan@email.com",
  "password": "123456"
}
```

#### Obtener Perfil (requiere token)
```http
GET /api/auth/perfil
Authorization: Bearer <token_aqui>
```

#### Listar Usuarios (solo admin)
```http
GET /api/auth/usuarios?page=1&limit=10&rol=usuario
Authorization: Bearer <token_admin>
```

#### Actualizar Usuario (solo admin)
```http
PUT /api/auth/usuarios/1
Authorization: Bearer <token_admin>
Content-Type: application/json

{
  "nombre": "Juan Pérez Actualizado",
  "rol": "bibliotecario"
}
```

#### Desactivar Usuario (solo admin)
```http
PATCH /api/auth/usuarios/1/desactivar
Authorization: Bearer <token_admin>
```

### Base de Datos de Prueba

```sql
-- Crear usuario admin de prueba
INSERT INTO usuarios (nombre, email, password, rol, created_at, updated_at) VALUES 
('Administrador', 'admin@biblioteca.com', '$2b$12$hash_del_password', 'admin', NOW(), NOW());

-- Crear categorías de prueba  
INSERT INTO categorias (nombre, descripcion, created_at, updated_at) VALUES 
('Ficción', 'Novelas y cuentos', NOW(), NOW()),
('Técnico', 'Libros de programación y tecnología', NOW(), NOW());
```

---

## 📝 Notas para el Instructor

### Conceptos Clave por Fase

#### **Fases 1-2: Fundamentos**
- **Express.js**: Servidor web, middlewares, rutas
- **Sequelize**: ORM, conexión a base de datos
- **Estructura de proyecto**: Separación de responsabilidades

#### **Fases 3-4: CRUD Básico**
- **Modelos Sequelize**: Definición, validaciones
- **Controladores**: Lógica de negocio básica
- **Rutas Express**: Organización de endpoints
- **Manejo de errores**: Try-catch, códigos de estado HTTP

#### **Fases 5-6: Autenticación (DESARROLLADO)**
- **Hashing de passwords**: bcrypt, seguridad
- **JWT**: Tokens, autenticación stateless
- **Middleware de autenticación**: Protección de rutas
- **Roles y permisos**: Autorización basada en roles
- **Servicios**: Separación de lógica de negocio

#### **Fases 7-8: Modelos Complejos**
- **Relaciones Sequelize**: hasMany, belongsTo
- **Foreign Keys**: Referencias entre tablas
- **Validaciones custom**: Lógica de negocio en modelos

#### **Fases 9-10: Lógica de Negocio**
- **Filtros y paginación**: Consultas dinámicas
- **Transacciones**: Operaciones atómicas
- **Estados de entidad**: Máquinas de estado simples

#### **Fases 11-12: Calidad y Arquitectura**
- **Validaciones de entrada**: express-validator
- **Seguridad**: helmet, CORS, rate limiting
- **Arquitectura en capas**: Servicios, controladores, rutas

### Tiempo Estimado por Fase

| Fase | Descripción | Tiempo Principiantes | Tiempo Intermedios |
|------|-------------|---------------------|-------------------|
| 1-2 | Configuración inicial | 3 horas | 1.5 horas |
| 3-4 | CRUD básico categorías | 2 horas | 1 hora |
| 5-6 | **Usuario y autenticación** | **4 horas** | **2.5 horas** |
| 7-8 | Modelos libro y préstamo | 2 horas | 1 hora |
| 9 | CRUD libros | 2 horas | 1.5 horas |
| 10 | Sistema préstamos | 3 horas | 2 horas |
| 11 | Validaciones y seguridad | 2 horas | 1 hora |
| 12 | Refactorización | 1 hora | 0.5 horas |
| **Total** | | **19 horas** | **11 horas** |

### Metodología de Enseñanza por Fase

#### **Para Usuario (Fase 5-6) - DESARROLLADO:**

**Sesión 1: Modelo Usuario (1.5-2 horas)**
1. **Teoría (20 min)**: bcrypt, hashing, seguridad de passwords
2. **Demostración (30 min)**: Crear modelo con hooks
3. **Práctica (45 min)**: Estudiantes implementan modelo
4. **Testing (15 min)**: Probar creación y hash de passwords

**Sesión 2: JWT y Middleware (1.5-2 horas)**
1. **Teoría (20 min)**: JWT, tokens, autenticación stateless
2. **Demostración (40 min)**: AuthService y middleware
3. **Práctica (50 min)**: Implementar autenticación
4. **Testing (10 min)**: Probar login y protección de rutas

#### **Para otras fases:**
- **Explicación conceptual** (15-20 min)
- **Demostración en vivo** (20-30 min)
- **Práctica guiada** (30-45 min)
- **Ejercicio independiente** (10-15 min)

### Puntos de Control Críticos

#### **Checkpoint Usuario (Fase 6) - CRÍTICO:**
- [ ] Registro funciona sin errores
- [ ] Password se hashea correctamente
- [ ] Login genera JWT válido
- [ ] Middleware protege rutas correctamente
- [ ] Roles funcionan (admin vs usuario)
- [ ] CRUD de usuarios completo

#### **Otros Checkpoints:**
- **Fase 2**: Conexión DB establecida
- **Fase 4**: CRUD básico funcionando
- **Fase 8**: Relaciones entre modelos
- **Fase 10**: Lógica de préstamos completa
- **Fase 12**: Arquitectura limpia

### Errores Comunes Anticipados

#### **En Fase Usuario (5-6):**
1. **Olvidar await** en bcrypt.hash/compare
2. **JWT_SECRET no definido** en .env
3. **Middleware en orden incorrecto**
4. **No verificar usuario activo** en middleware
5. **Circular dependency** en requires
6. **No excluir password** en respuestas
7. **Verificación de roles incorrecta**

#### **Otros errores comunes:**
- Sequelize sync sin await
- Validaciones mal definidas
- Manejo de errores inconsistente
- CORS mal configurado

### Recursos de Apoyo

#### **Documentación Esencial:**
- [Sequelize Docs](https://sequelize.org/docs/v6/)
- [Express.js Guide](https://expressjs.com/en/guide/)
- [JWT.io](https://jwt.io/) para debuggear tokens
- [bcrypt npm](https://www.npmjs.com/package/bcryptjs)

#### **Herramientas de Debugging:**
- **Postman**: Testing de APIs
- **MySQL Workbench**: Visualizar base de datos
- **VS Code REST Client**: Testing dentro del editor
- **Node.js debugger**: Para debugging profundo

### Extensiones Opcionales

#### **Para Estudiantes Avanzados:**
1. **Testing Unitario** con Jest
2. **Documentación** con Swagger
3. **Logging** con Winston
4. **Caching** con Redis
5. **Upload de archivos** con Multer
6. **Email notifications** con Nodemailer

#### **Mejoras de Arquitectura:**
1. **Repository Pattern**
2. **Dependency Injection**
3. **Event-driven architecture**
4. **Microservicios básicos**

### Evaluación Sugerida

#### **Evaluación Formativa (durante desarrollo):**
- **Checkpoints cumplidos**: 40%
- **Calidad del código**: 30% 
- **Manejo de errores**: 20%
- **Testing manual**: 10%

#### **Proyecto Final:**
- **Funcionalidad completa**: 50%
- **Seguridad implementada**: 25%
- **Arquitectura y organización**: 15%
- **Documentación**: 10%

### Adaptaciones por Nivel

#### **Principiantes (sin experiencia previa):**
- Más tiempo en configuración inicial
- Explicaciones detalladas de cada concepto
- Ejercicios adicionales de JavaScript/Node.js
- Revisar conceptos de HTTP y REST

#### **Intermedios (conocen Node.js básico):**
- Enfoque en patrones de diseño
- Discusión de alternativas tecnológicas
- Comparación con otros frameworks/ORMs
- Optimizaciones de performance

#### **Avanzados:**
- Implementación de patrones avanzados
- Discusión de trade-offs arquitecturales
- Extensiones con otras tecnologías
- Code review y refactoring

---

## 🚀 Siguientes Pasos

### Después de Completar el Desarrollo:

1. **Deploy**: Configurar producción
2. **Testing**: Implementar pruebas automatizadas  
3. **Monitoring**: Logs y métricas
4. **Performance**: Optimizaciones y caching
5. **Documentación**: API docs con Swagger

### Tecnologías Complementarias:

- **Frontend**: React, Vue.js para interfaz
- **Base de datos**: PostgreSQL como alternativa
- **Caching**: Redis para performance
- **Testing**: Jest, Supertest
- **Deploy**: Docker, PM2, AWS/Heroku

---

## 📚 Recursos Adicionales

### Documentación Oficial:
- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Guide](https://expressjs.com/)
- [Sequelize Documentation](https://sequelize.org/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

### Tutoriales Complementarios:
- REST API Best Practices
- JWT Security Best Practices  
- Node.js Security Checklist
- Database Design Principles

### Herramientas Recomendadas:
- **Postman**: Testing de APIs
- **VS Code**: Editor con extensiones Node.js
- **MySQL Workbench**: Gestión de base de datos
- **Git**: Control de versiones

---

