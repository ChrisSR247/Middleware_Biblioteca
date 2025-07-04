-- Script de Base de Datos para Sistema de Biblioteca
CREATE DATABASE IF NOT EXISTS biblioteca_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE biblioteca_db;

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol ENUM('admin', 'bibliotecario', 'usuario') DEFAULT 'usuario',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    categoria_id INT,
    ejemplares_total INT DEFAULT 1,
    ejemplares_disponibles INT DEFAULT 1,
    fecha_publicacion DATE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    INDEX idx_titulo (titulo),
    INDEX idx_autor (autor),
    INDEX idx_isbn (isbn)
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL DEFAULT (CURRENT_DATE),
    fecha_vencimiento DATE NOT NULL,
    fecha_devolucion DATE NULL,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo',
    multa DECIMAL(8,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (libro_id) REFERENCES libros(id) ON DELETE CASCADE,
    INDEX idx_usuario_estado (usuario_id, estado),
    INDEX idx_fecha_vencimiento (fecha_vencimiento)
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_reserva DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado ENUM('pendiente', 'confirmada', 'cancelada') DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (libro_id) REFERENCES libros(id) ON DELETE CASCADE,
    UNIQUE KEY unique_reserva_activa (usuario_id, libro_id, estado)
);

-- Insertar datos iniciales
INSERT INTO categorias (nombre, descripcion) VALUES
('Ficción', 'Novelas y cuentos de ficción'),
('Ciencia', 'Libros de ciencias exactas y naturales'),
('Historia', 'Libros de historia y biografías'),
('Tecnología', 'Libros de informática y tecnología'),
('Literatura', 'Clásicos de la literatura universal');

INSERT INTO usuarios (nombre, email, password, rol) VALUES
('Administrador', 'admin@biblioteca.com', '$2b$10$example_hashed_password', 'admin'),
('Juan Bibliotecario', 'bibliotecario@biblioteca.com', '$2b$10$example_hashed_password', 'bibliotecario');

INSERT INTO libros (titulo, autor, isbn, categoria_id, ejemplares_total, ejemplares_disponibles, fecha_publicacion, descripcion) VALUES
('Cien años de soledad', 'Gabriel García Márquez', '978-84-376-0494-7', 5, 3, 3, '1967-06-05', 'Obra maestra del realismo mágico'),
('El principito', 'Antoine de Saint-Exupéry', '978-84-261-0368-5', 1, 2, 2, '1943-04-06', 'Cuento filosófico para niños y adultos'),
('Sapiens', 'Yuval Noah Harari', '978-84-9992-786-1', 3, 4, 4, '2011-01-01', 'De animales a dioses: Breve historia de la humanidad');

-- Crear usuario para la aplicación con permisos limitados
CREATE USER IF NOT EXISTS 'biblioteca_app'@'%' IDENTIFIED BY 'BibliotecaApp2024!';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteca_db.* TO 'biblioteca_app'@'%';
FLUSH PRIVILEGES;