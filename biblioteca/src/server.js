import express from 'express';
import { testConnection } from '../database.js';
import 'dotenv/config';
import { Usuario } from './config/data/models/Usuario.js';

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({
    status: 200,
    message: 'El API está funcionando',
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/testmysql', async (req, res) => {
  try {
    const result = await testConnection();
    res.json({
      status: 200,
      message: 'Conexión a la base de datos establecida correctamente.',
      database: process.env.DB_NAME,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      status: 500,
      message: 'No se pudo conectar a la base de datos',
      error: error.message,
    });
  }
});

app.use((req, res) => {
  res.status(404).json({
    status: 404,
    message: 'La ruta definida no existe',
  });
});

app.listen(port, () => {
  console.log(`Servidor en ejecución en el puerto ${port}`);
});

app.post('/api/test-usuarios', async(req, res) => {
  try {
    const { nombre, email, password, rol } = req.body;
      const usuario = await Usuario.create({
        nombre,
        email,
        password,
        rol: "user"
      });
      res.status(201).json({
        status: 201,
        message: 'Usuario creado exitosamente',
        usuario,
      });
        } catch (error) {
          res.status(400).json({
            status: 400,
            message: 'Error al crear el usuario',
            error: error.message,
          });
        }
    });



const startServer = async () => {
  try {
    const dbConnected = await testConnection();
    if (dbConnected) {
      app.listen(port, () => {
        console.log(`Servidor en ejecución en el puerto ${port}`);
      });
    } else {
      console.error('No se pudo conectar a la base de datos. El servidor no se iniciará.');
    }
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
  }
};


