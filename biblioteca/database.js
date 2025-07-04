// config/database.js
//const { Sequelize } = require('sequelize');
import { Sequelize } from 'sequelize';
import dotenv from 'dotenv/config';
export const sequelize = new Sequelize(
    process.env.DB_NAME ?? 'biblioteca_db',//database name
    process.env.DB_USER, //database user
    process.env.DB_PASSWORD,//database password 
    { 
  host: process.env.HOST, //database host
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
export async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('Conexión a la base de datos establecida correctamente.');
  } catch (error) {
    console.error('No se pudo conectar a la base de datos:', error);
  }
}