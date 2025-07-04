import { DataTypes } from 'sequelize';
import bcrypt from 'bcryptjs';
import { sequelize } from '../database.js';

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
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
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

// Método para obtener usuario sin contraseña
Usuario.prototype.toSafeJSON = function() {
    const { password, ...usuarioSinPassword } = this.toJSON();
    return usuarioSinPassword;
};

export default Usuario;