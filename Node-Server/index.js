//Import the Websocket server from the NPM package
import {express} from 'express'
import http from 'http'
import {WebSocketServer} from 'ws'
//Declare the arbitrary port
const PORT = 8080
const app = express()
const server = http.createServer(app)


//create a web socket server
const wss = new WebSocketServer({
    server
})

//Debug log
console.log(`Listening on port ${PORT}`)

//Called when the godot client connects
wss.on('connection',(socket) => {
    console.log('Connected!')
    socket.on('message',(data) => {
        let packet = JSON.parse(data)
        console.log(packet)

    })
    socket.on('close',() => {
        console.log('client closed')
    }) 
})