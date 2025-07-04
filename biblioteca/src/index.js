import express from 'express'
import { testConnection } from '../database.js'
import 'dotenv/config'

const app = express()
const port = process.env.PORT || 3000

//Middleware para establecer el lenguaje en el que vamos a hablar entre el fronted y el backend
app.use(express.json())

app.get('/api/healt', (req, res) => {
    res.json({
        status: 200,
        message: 'El api esta funcionando',
        timestap: new Date().getUTCDate()

    })
})

app.get('/api/testmysql', async (req, res) => {
    try{
        const result = await testConnection()
        res.json({
            status: 200,
            message: 'Conexión a la base de datos establecida correctamente.',
            database: process.env.DB_NAME,
            timestap: new Date().toDateString()
        })
    }
    catch(error){
        res.json({
            status: 400,
            message: 'No se pudo conectar a la base de datos',
            error: error
        })
    }
})

// 👇 Este middleware debe ir al final
app.use((req, res) => {
    res.json({
        status: 301,
        message: 'La ruta definida no existe'
    })
})

app.listen(port, () => {
    console.log('Servidor en ejecución')
})