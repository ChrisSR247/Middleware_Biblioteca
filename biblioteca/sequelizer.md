# Guía Básica de Sequelize con MySQL2 - Sistema de Biblioteca

## 1. Instalación y Configuración

### Instalar dependencias
```bash
npm install sequelize mysql2
# o
yarn add sequelize mysql2
```

### Configuración de la conexión
```javascript
// config/database.js
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('biblioteca_db', 'biblioteca_app', 'BibliotecaApp2024!', {
  host: 'localhost',
  dialect: 'mysql',
  logging: false, // Desactivar logs SQL en producción
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
});

// Probar la conexión
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('Conexión a la base de datos establecida correctamente.');
  } catch (error) {
    console.error('No se pudo conectar a la base de datos:', error);
  }
}

module.exports = { sequelize, testConnection };
```

## 2. Definición de Modelos

### Usuario
```javascript
// models/Usuario.js
const { DataTypes } = require('sequelize');
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
      notEmpty: true,
      len: [2, 100]
    }
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      len: [6, 255]
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
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = Usuario;
```

### Categoría
```javascript
// models/Categoria.js
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
    unique: true
  },
  descripcion: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'categorias',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = Categoria;
```

### Libro
```javascript
// models/Libro.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Libro = sequelize.define('Libro', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  titulo: {
    type: DataTypes.STRING(200),
    allowNull: false,
    validate: {
      notEmpty: true
    }
  },
  autor: {
    type: DataTypes.STRING(150),
    allowNull: false,
    validate: {
      notEmpty: true
    }
  },
  isbn: {
    type: DataTypes.STRING(20),
    unique: true,
    validate: {
      isISBN: function(value) {
        if (value && !/^978-\d{2}-\d{3,7}-\d{1,7}-\d{1}$/.test(value)) {
          throw new Error('Formato de ISBN inválido');
        }
      }
    }
  },
  categoria_id: {
    type: DataTypes.INTEGER,
    references: {
      model: 'categorias',
      key: 'id'
    }
  },
  ejemplares_total: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: 1
    }
  },
  ejemplares_disponibles: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: 0
    }
  },
  fecha_publicacion: {
    type: DataTypes.DATEONLY
  },
  descripcion: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'libros',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = Libro;
```

### Préstamo
```javascript
// models/Prestamo.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Prestamo = sequelize.define('Prestamo', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  usuario_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'usuarios',
      key: 'id'
    }
  },
  libro_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'libros',
      key: 'id'
    }
  },
  fecha_prestamo: {
    type: DataTypes.DATEONLY,
    defaultValue: DataTypes.NOW
  },
  fecha_vencimiento: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  fecha_devolucion: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  estado: {
    type: DataTypes.ENUM('activo', 'devuelto', 'vencido'),
    defaultValue: 'activo'
  },
  multa: {
    type: DataTypes.DECIMAL(8, 2),
    defaultValue: 0.00
  }
}, {
  tableName: 'prestamos',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = Prestamo;
```

### Reserva
```javascript
// models/Reserva.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Reserva = sequelize.define('Reserva', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  usuario_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'usuarios',
      key: 'id'
    }
  },
  libro_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'libros',
      key: 'id'
    }
  },
  fecha_reserva: {
    type: DataTypes.DATEONLY,
    defaultValue: DataTypes.NOW
  },
  estado: {
    type: DataTypes.ENUM('pendiente', 'confirmada', 'cancelada'),
    defaultValue: 'pendiente'
  }
}, {
  tableName: 'reservas',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = Reserva;
```

## 3. Definir Asociaciones

```javascript
// models/index.js
const Usuario = require('./Usuario');
const Categoria = require('./Categoria');
const Libro = require('./Libro');
const Prestamo = require('./Prestamo');
const Reserva = require('./Reserva');

// Definir asociaciones
// Un libro pertenece a una categoría
Libro.belongsTo(Categoria, { 
  foreignKey: 'categoria_id', 
  as: 'categoria' 
});

// Una categoría tiene muchos libros
Categoria.hasMany(Libro, { 
  foreignKey: 'categoria_id', 
  as: 'libros' 
});

// Un préstamo pertenece a un usuario y un libro
Prestamo.belongsTo(Usuario, { 
  foreignKey: 'usuario_id', 
  as: 'usuario' 
});

Prestamo.belongsTo(Libro, { 
  foreignKey: 'libro_id', 
  as: 'libro' 
});

// Un usuario puede tener muchos préstamos
Usuario.hasMany(Prestamo, { 
  foreignKey: 'usuario_id', 
  as: 'prestamos' 
});

// Un libro puede tener muchos préstamos
Libro.hasMany(Prestamo, { 
  foreignKey: 'libro_id', 
  as: 'prestamos' 
});

// Asociaciones para reservas
Reserva.belongsTo(Usuario, { 
  foreignKey: 'usuario_id', 
  as: 'usuario' 
});

Reserva.belongsTo(Libro, { 
  foreignKey: 'libro_id', 
  as: 'libro' 
});

Usuario.hasMany(Reserva, { 
  foreignKey: 'usuario_id', 
  as: 'reservas' 
});

Libro.hasMany(Reserva, { 
  foreignKey: 'libro_id', 
  as: 'reservas' 
});

module.exports = {
  Usuario,
  Categoria,
  Libro,
  Prestamo,
  Reserva
};
```

## 4. Operaciones CRUD Básicas

### Crear registros
```javascript
// Crear un usuario
const nuevoUsuario = await Usuario.create({
  nombre: 'María García',
  email: 'maria@email.com',
  password: 'contraseña123',
  rol: 'usuario'
});

// Crear una categoría
const nuevaCategoria = await Categoria.create({
  nombre: 'Ciencia Ficción',
  descripcion: 'Libros de ciencia ficción y fantasía'
});

// Crear un libro
const nuevoLibro = await Libro.create({
  titulo: 'Dune',
  autor: 'Frank Herbert',
  isbn: '978-84-123-4567-8',
  categoria_id: 1,
  ejemplares_total: 2,
  ejemplares_disponibles: 2,
  fecha_publicacion: '1965-08-01',
  descripcion: 'Novela épica de ciencia ficción'
});
```

### Leer registros
```javascript
// Buscar todos los libros
const todosLosLibros = await Libro.findAll();

// Buscar libro por ID con categoría
const libro = await Libro.findByPk(1, {
  include: [{
    model: Categoria,
    as: 'categoria'
  }]
});

// Buscar libros por autor
const librosPorAutor = await Libro.findAll({
  where: {
    autor: 'Gabriel García Márquez'
  }
});

// Buscar con condiciones múltiples
const librosDisponibles = await Libro.findAll({
  where: {
    ejemplares_disponibles: {
      [Op.gt]: 0 // Mayor que 0
    }
  }
});

// Buscar usuarios con sus préstamos activos
const usuariosConPrestamos = await Usuario.findAll({
  include: [{
    model: Prestamo,
    as: 'prestamos',
    where: {
      estado: 'activo'
    },
    required: false // LEFT JOIN
  }]
});
```

### Actualizar registros
```javascript
// Actualizar un libro específico
await Libro.update(
  { ejemplares_disponibles: 1 },
  { where: { id: 1 } }
);

// Actualizar con validación de instancia
const libro = await Libro.findByPk(1);
if (libro) {
  libro.ejemplares_disponibles = 1;
  await libro.save();
}
```

### Eliminar registros
```javascript
// Eliminar por ID
await Usuario.destroy({
  where: { id: 5 }
});

// Eliminación suave (si se configura paranoid: true)
const usuario = await Usuario.findByPk(1);
await usuario.destroy(); // Solo marca como eliminado
```

## 5. Consultas Avanzadas

### Préstamos con información completa
```javascript
const prestamosCompletos = await Prestamo.findAll({
  include: [
    {
      model: Usuario,
      as: 'usuario',
      attributes: ['nombre', 'email']
    },
    {
      model: Libro,
      as: 'libro',
      attributes: ['titulo', 'autor'],
      include: [{
        model: Categoria,
        as: 'categoria',
        attributes: ['nombre']
      }]
    }
  ],
  where: {
    estado: 'activo'
  },
  order: [['fecha_vencimiento', 'ASC']]
});
```

### Libros más prestados
```javascript
const { Op, fn, col } = require('sequelize');

const librosMasPrestados = await Libro.findAll({
  attributes: [
    'id',
    'titulo',
    'autor',
    [fn('COUNT', col('prestamos.id')), 'total_prestamos']
  ],
  include: [{
    model: Prestamo,
    as: 'prestamos',
    attributes: []
  }],
  group: ['Libro.id'],
  order: [[fn('COUNT', col('prestamos.id')), 'DESC']],
  limit: 10
});
```

### Usuarios con préstamos vencidos
```javascript
const usuariosConVencidos = await Usuario.findAll({
  include: [{
    model: Prestamo,
    as: 'prestamos',
    where: {
      estado: 'activo',
      fecha_vencimiento: {
        [Op.lt]: new Date()
      }
    }
  }]
});
```

## 6. Transacciones

```javascript
const { sequelize } = require('../config/database');

// Realizar un préstamo (transacción)
async function realizarPrestamo(usuarioId, libroId) {
  const transaction = await sequelize.transaction();
  
  try {
    // Verificar disponibilidad del libro
    const libro = await Libro.findByPk(libroId, { transaction });
    
    if (libro.ejemplares_disponibles <= 0) {
      throw new Error('No hay ejemplares disponibles');
    }
    
    // Crear el préstamo
    const fechaVencimiento = new Date();
    fechaVencimiento.setDate(fechaVencimiento.getDate() + 15); // 15 días
    
    const prestamo = await Prestamo.create({
      usuario_id: usuarioId,
      libro_id: libroId,
      fecha_vencimiento: fechaVencimiento
    }, { transaction });
    
    // Actualizar ejemplares disponibles
    await Libro.update(
      { ejemplares_disponibles: libro.ejemplares_disponibles - 1 },
      { where: { id: libroId }, transaction }
    );
    
    await transaction.commit();
    return prestamo;
    
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}
```

## 7. Hooks y Validaciones

```javascript
// En el modelo Usuario
Usuario.addHook('beforeCreate', async (usuario) => {
  const bcrypt = require('bcrypt');
  usuario.password = await bcrypt.hash(usuario.password, 10);
});

// Validación personalizada en Libro
Libro.addHook('beforeUpdate', (libro) => {
  if (libro.ejemplares_disponibles > libro.ejemplares_total) {
    throw new Error('Los ejemplares disponibles no pueden ser mayores al total');
  }
});
```

## 8. Archivo de Inicialización

```javascript
// app.js
const { sequelize, testConnection } = require('./config/database');
require('./models'); // Cargar todos los modelos

async function initApp() {
  try {
    await testConnection();
    
    // Sincronizar modelos (solo en desarrollo)
    if (process.env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
    }
    
    console.log('Base de datos inicializada correctamente');
    
  } catch (error) {
    console.error('Error al inicializar la aplicación:', error);
  }
}

initApp();
```

## 9. Operadores Útiles

```javascript
const { Op } = require('sequelize');

// Búsqueda de texto
const libros = await Libro.findAll({
  where: {
    titulo: {
      [Op.like]: '%ciencia%' // Contiene 'ciencia'
    }
  }
});

// Rangos de fechas
const prestamosRecientes = await Prestamo.findAll({
  where: {
    fecha_prestamo: {
      [Op.between]: ['2024-01-01', '2024-12-31']
    }
  }
});

// Múltiples condiciones
const librosDisponibles = await Libro.findAll({
  where: {
    [Op.and]: [
      { ejemplares_disponibles: { [Op.gt]: 0 } },
      { categoria_id: { [Op.in]: [1, 2, 3] } }
    ]
  }
});
```

## 10. Tips y Mejores Prácticas

1. **Usar índices**: Los campos que se consultan frecuentemente deben tener índices
2. **Validaciones**: Implementar validaciones tanto en Sequelize como en la base de datos
3. **Transacciones**: Usar transacciones para operaciones críticas
4. **Paginación**: Implementar limit y offset para consultas grandes
5. **Lazy Loading**: Usar include solo cuando sea necesario
6. **Variables de entorno**: Almacenar credenciales en variables de entorno

```javascript
// Ejemplo de paginación
const page = 1;
const limit = 10;
const offset = (page - 1) * limit;

const libros = await Libro.findAndCountAll({
  limit,
  offset,
  order: [['titulo', 'ASC']]
});
```

Esta guía te proporciona una base sólida para trabajar con Sequelize y MySQL2 en tu sistema de biblioteca.