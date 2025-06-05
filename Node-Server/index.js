//Import the Websocket server from the NPM package
import pkg from 'express'
import http from 'http'
import {WebSocketServer} from 'ws'
//Declare the arbitrary port
const PORT = 8080
const express = pkg
const app = express()
const server = http.createServer(app)


//create a web socket server
const wss = new WebSocketServer({
    server
})

function randRange(min, max) {
  const minCeiled = Math.ceil(min);
  const maxFloored = Math.floor(max);
  return Math.floor(Math.random() * (maxFloored - minCeiled + 1) + minCeiled);
}
const nameLength = 10
function generateUID() {
    let string = ''
    let x = 0

    while (x < randRange(5,10)) {
        string += randRange(0,9).toString()
        x ++
    }
    return string
}
class Packet {
    constructor (event,message) {
        this.event = event
        this.message = message
    }
    toString() {
        return JSON.stringify(this)
    }
}
class Card {
    constructor (value,hidden) {
        this.value = value
        this.hidden = hidden
    }
    getValue() {
        if (this.hidden) {
            return 0
        }
        return this.value
    }
}

function init_ws(socket,packet) {
    console.log('init')
   
    const response = new Packet('init',socket.id)
    socket.send(response.toString())
}
function lobby_to_client(lobby=[]) {
    let nLobby = {}
    for (let x = 0; x < lobby.length; x++) {
        let player = lobby[x]
        nLobby[x] = JSON.stringify({
            'id': player.id,
            'isHost': player.isHost,
        })
    }
    return nLobby
}
function host_lobby(socket,packet) {
    let l_uid = generateUID()
    while (lobbies[l_uid]) {
        l_uid = generateUID()
    }
    lobbies[l_uid] = [socket]
    let args = {
        'id': l_uid,
        'client_lobby': JSON.stringify(lobby_to_client(lobbies[l_uid])),
    }
    socket.isHost = true
    console.log(args)
    let response = new Packet('host_success',JSON.stringify(args))
    socket.send(response.toString())
}
function server_error(socket,message) {
    var packet = new Packet('server_error',message)
    socket.send(packet.toString())
}
function join_lobby(socket,lobby_id) {
    if (!lobbies[lobby_id]) {
        server_error(socket,'Lobby does not exist')
        return
    }
    let lobby = lobbies[lobby_id]
    let packet = new Packet('join_success',lobby_id)
    socket.send(packet.toString())
    lobby.push(socket)
    send_all(lobby,'update_player_list',JSON.stringify(lobby_to_client(lobby)))
}

function leave_lobby(socket,packet) {
    let id = socket.id
    for (let lobby_id in lobbies) {
        const lobby = lobbies[lobby_id]
        for (let pidx = 0; pidx < lobby.length; pidx ++) {
            const player = lobby[pidx]
            if (player.id == id) {
                //remove player from the lobby
                if (!player.isHost) {
                    lobby.splice(pidx,1)
                    send_all(lobby,'update_player_list',JSON.stringify(lobby_to_client(lobby)))
                } else {
                    socket.isHost = false
                    send_all(lobby,'leave_success','')
                    console.log('lobby disbanded')
                    delete lobbies[lobby_id]
                }
                console.log('player found!')
                socket.send(new Packet('leave_success','').toString())
                return
            }
        } 
    }

    server_error(socket,'Error while leaving, idk lol try again maybe?')

}
function generate_deck() {
    let deck = Array(11)
    let x = 0
    const used = {}
    while (x < 11) {
        let card = randRange(1,11)
        while (used[card]) {
            card = randRange(1,11)
        }
        used[card] = true
        deck[x] = new Card(card,false)
        x ++
    }
    return deck
}
function start_lobby(socket,packet) {
    const [lobby,lobby_id] = find_player_lobby(socket)
    const gameInfo = []
    let player_num = 1
    for (let p_idx in lobby) {
        const player = lobby[p_idx]
        const pInfo = {}
        pInfo['id'] = player.id
        pInfo['loaded'] = false
        pInfo['hand'] = []
        pInfo['hp'] = 10
        pInfo['playernum'] = player_num
        player_num ++
        gameInfo.push(pInfo)
    }

    games[lobby_id] = {
        'turn': 0,
        'players': gameInfo,
        'deck': generate_deck(),
    }
    
    console.log(games)
    send_all(lobby,'start_success','')
}
function find_player_lobby(socket) {
    let id = socket.id
    for (let lobby_id in lobbies) {
        const lobby = lobbies[lobby_id]
        for (let x = 0; x < lobby.length; x ++) {
            const player = lobby[x]
            if (player.id == id) {
                console.log('player found in lobby')
                return [lobby,lobby_id]
            }
        }
    }
    return []
}

function send_all(list,event,message) {
    let packet = new Packet(event,message)
    for (let idx in list) {
        let client = list[idx] 
        client.send(packet.toString())
    }
}

const lobbies = {}
const games = {}
const players = {}
//Called when the godot client connects
wss.on('connection',(socket) => {  
    let uid = generateUID()
    while (players[uid]) {
        uid = generateUID()
    }
    socket.isHost = false
    socket.id = uid
    players[uid] = socket
    console.log('Connected!',socket.id)

    //Handle client packets
    socket.on('message',(data) => {
        let packet = JSON.parse(data)
        console.log(packet)
        switch (packet.event) {
            case 'init':
                init_ws(socket,packet)
                break;
            case 'host':
                host_lobby(socket,packet)
                break;
            case 'join':
                join_lobby(socket,packet.message)
                break;
            case 'leave':
            case 'disband':
                leave_lobby(socket,packet)
                break;
            case 'start':
                if (!socket.isHost) {
                    console.error('The player is not a host, so they cant start')
                    return
                }
                start_lobby(socket,packet)
                break;
            case "init-game":
                
                break;
        }
    })
    socket.on('close',() => {
        console.log('client closed')
        //remove player from player list, freeing id
        delete players[socket.id]

    })
})
server.listen(PORT,() => {
    console.log(`Server listening on port ${PORT}`)
})