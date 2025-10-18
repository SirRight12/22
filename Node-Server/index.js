//Import the Websocket server from the NPM package
import pkg from 'express'
import http from 'http'
import {WebSocketServer} from 'ws'
import {trumps} from './trumps.js'
//Declare the arbitrary port
const PORT = process.env.PORT || 4000
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
function generateUID() {
    let string = ''
    let x = 0

    while (x < randRange(4,10)) {
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
    getValue(isOwner=false) {
        if (this.hidden && !isOwner) {
            return 0
        }
        return this.value
    }
}
console.log(generate_deck())

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
            'display_name': player.display_name,
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
    socket.display_name = packet.message
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
function join_lobby(socket,message) {
    const obj = JSON.parse(message)
    const lobby_id = obj['id']
    socket.display_name = obj['display_name']
    if (!lobbies[lobby_id]) {
        server_error(socket,'Lobby does not exist')
        return
    }
    let lobby = lobbies[lobby_id]
    if (lobby.length >= 2) {
        server_error(socket,'Lobby is full')
        return
    }
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
    // Create an array of numbers 1-11, shuffle, and map to Card objects
    const numbers = Array.from({ length: 11 }, (_, i) => i + 1);
    // Fisher-Yates shuffle
    for (let i = numbers.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [numbers[i], numbers[j]] = [numbers[j], numbers[i]];
    }
    return numbers.map(num => new Card(num, false));
}
function start_lobby(socket,packet) {
    const [lobby,lobby_id] = find_player_lobby(socket)
    const gameInfo = []
    let player_num = 1
    //define player info
    if (!lobby) {
        server_error(socket,'Error: Lobby not found')
        return
    }
    for (let p_idx in lobby) {
        const player = lobby[p_idx]
        const pInfo = {}
        pInfo['id'] = player.id
        pInfo['loaded'] = false
        pInfo['hand'] = []
        pInfo['hp'] = 7
        pInfo['trumps'] = []
        pInfo['playernum'] = player_num
        pInfo['timer'] = null
        pInfo['passed'] = false
        player_num ++
        gameInfo.push(pInfo)
    }

    games[lobby_id] = {
        'turn': 3, // The turn, 1 is player 1, 2 is player 2, 3 is no turn (yes I should have done an enum)
        'players': gameInfo, // All the players in the game
        'deck': generate_deck(), // The game deck
        'target': 21, // The target score for player hands (can be modified by trumps)
        'round': 1, // The current round
        'p1table': [], // The aces on the table for player 1
        'p2table': [], // The aces on the table for player 2
        'roundTime': 60, // The max time each player has to think (in seconds)
        'ante': 1, // The ante is the amount of hp players will gain and lose each round
        'ante-up': 1, // The ante will increase by this amount each round (can be modified by trumps)
    }

    console.log(games)
    send_all(lobby,'start_success','')
}

function join_game(socket,packet) {
    const [lobby,lobby_id] = find_player_lobby(socket)
    const game = games[lobby_id]
    const playerData = find_in_game(socket,game)
    playerData['loaded'] = true
    const plr_count = game['players'].length
    let loaded = 0
    for (let x in game.players) {
        const plr = game['players'][x]
        if (plr.loaded) {
            loaded += 1
        }
    }
    if (loaded >= plr_count) {
        start_round(game)
        console.log('all loaded')
    }
}
function get_hidden_count(hand) {
    let hidden = 0
    for (let card_idx in hand) {
        let card = hand[card_idx]
        if (card.hidden) {
            hidden += 1
        }
    }
    return hidden
}
// Function to send a card to the player and if the card is hidden, it will not pass the value to the wrong client
function send_card(player, card, expected, init = false, trump = false) {
    // Only send the real value if the player is the owner or the card is not hidden
    let owner = player.playernum == expected;
    const socket = players[player.id];
    if (!socket) {
        console.error('Socket not found for player', player.id);
        return;
    }
    let val = card.hidden && !owner ? 0 : card.value;
    let newCard = new Card(val, card.hidden);
    const obj = {
        'card': JSON.stringify(newCard),
        'yours': owner,
    };
    if (init) obj['init'] = true;
    if (trump) obj['trump'] = true;
    const packet = new Packet(`p${expected}-draw`, JSON.stringify(obj));
    
    socket.send(packet.toString());
}
function value_packet(given_player_num,expected_player_num, game) {
    const valObj = {
        'value': get_value(game.players[expected_player_num - 1].hand, expected_player_num, given_player_num),
        'target': game.target,
        'hcount': get_hidden_count(game.players[expected_player_num - 1].hand),
        'yours': expected_player_num == given_player_num,
    }
    const packet = new Packet(`p${expected_player_num}-val`, JSON.stringify(valObj));
    return packet;
}
function send_round_info(game) {
    game.players.forEach(player => {
        const socket = players[player.id];
        const packet = new Packet('update-clock', JSON.stringify({
            round: game.round,
            playernum: player.playernum,
            time: game.roundTime,
            ante: game.ante,
            hp: player.hp,
        }));
        if (!socket) {
            console.error('Socket disconnected for player', player.id);
            return
        }
        socket.send(packet.toString());
    });
}
function start_round(game) {
    send_round_info(game)
    let card1 = game['deck'][0]
    game['deck'].splice(0,1)
    card1.hidden = true
    let card2 = game['deck'][0]
    game['deck'].splice(0,1)
    card2.hidden = true
    let card3 = game['deck'][0]
    game['deck'].splice(0,1)
    let card4 = game['deck'][0]
    game['deck'].splice(0,1)
    let p1,p2
    game.players.forEach(player => {
        if (player.playernum == 1) {
            p1 = player
        } else if (player.playernum == 2) {
            p2 = player
        }
    })
    p1.hand.push(card1,card3)
    p2.hand.push(card2,card4)
    const trumpPackets = roundTrumps(game)
    game.players.forEach(player => {
        const socket = players[player.id]
        const packet = new Packet('init-cameras',JSON.stringify(player))
        socket.send(packet.toString())
        
        let isP1 = player.playernum == 1
        let isP2 = player.playernum == 2
        const valObj1 = {
            'value': p1.hand[0].getValue(isP1),
            'target': game.target,
            'hcount': get_hidden_count([p1.hand[0]]),
            'yours': player.playernum == 1,
        }
        const valObj2 = {
            'value': p2.hand[0].getValue(isP2),
            'target': game.target,
            'hcount': get_hidden_count([p2.hand[0]]),
            'yours': player.playernum == 2,
        }
        const valObj3 = {
            'value': p1.hand[0].getValue(isP1) + p1.hand[1].getValue(isP1),
            'target': game.target,
            'hcount': get_hidden_count(p1.hand),
            'yours': player.playernum == 1,
        }
        const valObj4 = {
            'value': p2.hand[0].getValue(isP2) + p2.hand[1].getValue(isP2),
            'target': game.target,
            'hcount': get_hidden_count(p1.hand),
            'yours': player.playernum == 2,
        }
        console.log('valObj',valObj1)
        const p1Update = new Packet('p1-val',JSON.stringify(valObj1))
        const p2Update = new Packet('p2-val',JSON.stringify(valObj2))
        const p1Update2 = new Packet('p1-val',JSON.stringify(valObj3))
        const p2Update2 = new Packet('p2-val',JSON.stringify(valObj4))

        //send a card to the player expecting the playernum to be 1


        send_card(player,card1,1,true)
        socket.send(p1Update.toString())
        setTimeout(() => {
            send_card(player,card2,2,true)
            socket.send(p2Update.toString())
        },1000)
        setTimeout(() => {
            send_card(player,card3,1,true)
            socket.send(p1Update2.toString())
            setTimeout(async () => {
                send_card(player,card4,2,true)
                socket.send(p2Update2.toString())
                await sendTrumps(socket,player, trumpPackets)
                console.log('sent trumps')
                const turnPacket = new Packet('p1-turn',player.playernum == 1)
                game.turn = 1
                socket.send(turnPacket.toString())
                if (player.playernum == 1) {
                    player.timer = setTimeout(() => {
                        //handle case where player has left before timer expires
                        if (!player) return
                        player.hand.push(new Card(99,false)) // Give the player a card that WILL make them bust
                        give_up_turn(game,player)
                        console.log('timer over')
                        change_turn(game,player.playernum == 1 ? 2 : 1)
                    },game.roundTime * 1000)
                }
            },1000)

        },2000)
    })
}
function give_up_turn(game,player) {
    player.passed = true
    const sendCard = new Card(99,false)
    game.players.forEach(p => {
        const socket = players[p.id]
        const packet = new Packet(`p${player.playernum}-draw`,JSON.stringify({
            'card': JSON.stringify(sendCard),
            'yours': p.playernum == player.playernum,
            'trump': false, //ignore the voicelines on the client and plays a trump sfx
        }))
        if (!socket) {
            console.error('Socket not found for player', player.id);
            return;
        }
        socket.send(packet.toString())
        const valObj = {
            'value': get_value(player.hand, p.playernum, player.playernum),
            'target': game.target,
            'hcount': get_hidden_count(player.hand),
            'yours': p.playernum == player.playernum,
        }
        const packetVal = new Packet(`p${player.playernum}-val`, JSON.stringify(valObj))
        socket.send(packetVal.toString())
    })
}
async function change_turn(game,playernum) {
    game.turn = 3
    game.players.forEach(async player => {
        console.log('changing turn for player', player.playernum)
        const socket = players[player.id]
        if (!socket) {
            console.log('Socket not found for player', player.id,' must have disconnected');
            return
        }
        socket.send(new Packet('no-turn','').toString())
        await new Promise(resolve => setTimeout(resolve, 1000))
        console.log('after await for player', player.playernum)
        if (player.playernum == playernum) {
            player.timer = setTimeout(() => {
                //handle case where player has left before timer expires
                if (!player) return
                player.hand.push(new Card(99,false)) // Give the player a card that WILL make them bust
                game.turn = playernum == 1 ? 1 : 2
                console.log('timer over')
                change_turn(game,player.playernum == 1 ? 2 : 1)
            },game.roundTime * 1000)
        }
        const packet = new Packet(`p${playernum}-turn`, player.playernum == playernum)
        socket.send(packet.toString())
    })
    //keep in line with the loop
    await new Promise(resolve => setTimeout(resolve, 1000))
    console.log('turn changed to',playernum)
    game.turn = playernum
}
function sendTrumps(socket, player, trumpPackets) {
    return new Promise((resolve) => {
        if (!trumpPackets || !trumpPackets[player.playernum - 1]) {
            return;
        }
        console.log(trumpPackets[player.playernum - 1])
        trumpPackets[player.playernum - 1].forEach(async packet => {
            socket.send(packet.toString())
            await new Promise(resolve => setTimeout(resolve, 1000)) // Wait for 1 second before sending the next packet
        })
        resolve(); // Resolve the promise after all packets are sent
    })
}
function drawRandomTrump() {
    let totalWeight = 0;
    for (const trump of trumps) {
        totalWeight += trump.weight;
    }
    let random = Math.random() * totalWeight;
    for (const trump of trumps) {
        if (random < trump.weight) {
            return trump;
        }
        random -= trump.weight;
    }
}
function roundTrumps(game) {
    let p1 = game.players[0]
    let p2 = game.players[1]
    const packets = []
    let p1Packets = [] // an array of packets for player 1, p2's trump names will not be sent
    let p2Packets = [] // an array of packets for player 2, p1's trump names will not be sent to keep client integrity
    for (let x = 0; x < 4; x ++) {
        if (x % 2 == 0) {
            const trump = drawRandomTrump()
            p1.trumps.push(trump.name)
            p1Packets.push(new Packet(`p1-draw-trump`, trump.name))
            p2Packets.push(new Packet(`p1-draw-trump`, '')) // send a false trump to player 2 so they know player 1 has a trump, but not what it is
        } else {
            const trump = drawRandomTrump()
            p2.trumps.push(trump.name)
            p2Packets.push(new Packet(`p2-draw-trump`, trump.name))
            p1Packets.push(new Packet(`p2-draw-trump`, '')) // send a false trump to player 1 so they know player 2 has a trump, but not what it is       
        }
    }
    packets.push(p1Packets,p2Packets)
    return packets
}
function get_value(hand,pNum,expectedPNum) {
    let val = 0
    for (let card_idx in hand) {
        const card = hand[card_idx]
        val += card.getValue(pNum == expectedPNum)
    }
    return val
}
function player_draw_card(socket) {
    const [lobby,lobby_id] = find_player_lobby(socket)
    const game = games[lobby_id]
    let p = find_in_game(socket,game)
    if (!p) {
        console.error('Player not found in game')
        return
    }
    if (game.turn != p.playernum) {
        return // If it's not the player's turn, do nothing
    }
    function send_to_players(drawingPlayer,card) {
        let event = 'p1-draw'
        let event2 = 'p1-val'
        if (drawingPlayer.playernum == 2) {
            event = 'p2-draw'
            event2 = 'p2-val'
        }
        game.players.forEach(player => {
            player.passed = false
            const yours = player.playernum == drawingPlayer.playernum
            const newSocket = players[player.id]
            const packet = new Packet(event,JSON.stringify({
                'card': JSON.stringify(card),
                'yours': yours,
            }))
            const valObj = {
                'value': get_value(drawingPlayer.hand,player.playernum,drawingPlayer.playernum),
                'target': game.target,
                'hcount': get_hidden_count(drawingPlayer.hand),
                'yours': yours,
            }
            const packetUpd = new Packet(event2,JSON.stringify(valObj))
            newSocket.send(packet.toString())
            newSocket.send(packetUpd.toString())
            console.log('done!')
        })
    }
    function send_turn() {
        game.players.forEach(player => {
            const sock = players[player.id]
            let event = 'p1-turn'
            if (game.turn == 2) {
                event = 'p2-turn'
            }
            if (game.turn == player.playernum) {
                player.timer = setTimeout(() => {
                    //handle case where player has left before timer expires
                    if (!player) return
                    player.hand.push(new Card(99,false)) // Give the player a card that WILL make them bust
                    console.log('timer over')
                    change_turn(game,player.playernum == 1 ? 2 : 1)
                },game.roundTime * 1000)
            }
            const packet = new Packet(event,player.playernum == game.turn)
            sock.send(packet.toString())
        })
    }
    game.players.forEach(player => {
        //if its not the player, try again
        if (player.id != socket.id) return
        console.log('found player!')
        //stop trying to draw if its not the player's turn
        console.log('turn',game.turn)
        if (player.playernum != game.turn) return

        player.hand.push(game.deck[0])
        send_to_players(player,game.deck[0])
        game.deck.splice(0,1)
        let turn = -1
        if (game.turn == 1) {
            turn = 2
        } else if (game.turn == 2) {
            turn = 1
        }
        game.turn = 3
        game.players.forEach(player => {
            const sock = players[player.id]
            const packet = new Packet('no-turn','')
            clearTimeout(player.timer)
            sock.send(packet.toString())
        })
        setTimeout(() => {
            game.turn = turn
            send_turn()
        },2000)
    })
}
function undo_trumps(table,game) {
    table.forEach(trump => {
        for (let x in trumps) {
            let t = trumps[x]
            if (t.name == trump) {
                t.inverseUse(null, null, game)
            }
        }
    })
}
function player_pass_turn(socket) {
    const [lobby, lobby_id] = find_player_lobby(socket)
    const game = games[lobby_id]
    function send_turn() {
        game.players.forEach(player => {
            const sock = players[player.id]
            
            let event = 'p1-turn'
            if (game.turn == 2) {
                event = 'p2-turn'
            }
            if (game.turn == player.playernum) {
                player.timer = setTimeout(() => {
                    //handle case where player has left before timer expires
                    if (!player) return
                    player.hand.push(new Card(99,false)) // Give the player a card that WILL make them bust
                    console.log('timer over')
                    change_turn(game,player.playernum == 1 ? 2 : 1)
                },game.roundTime * 1000)
            }
            const packet = new Packet(event,player.playernum == game.turn)
            sock.send(packet.toString())
        })
    }
    let turn = -1
    if (game.turn == 1) {
        turn  = 2
    } else if (game.turn == 2) {
        turn = 1
    }
    game.turn = 3

    let p = find_in_game(socket,game)
    p.passed = true
    let e = p.playernum == 1 ? 'p1-pass' : 'p2-pass'
    game.players.forEach(player => {
        
        const sock = players[player.id]
        const packet = new Packet('no-turn','')
        clearTimeout(player.timer)
        const passPacket = new Packet(e,JSON.stringify({'yours': player.playernum == p.playernum,}))
        sock.send(packet.toString())
        sock.send(passPacket.toString())
    })
    console.log('game',game)
    let evaluate = eval_passed(game)
    console.log('eval',evaluate)
    if (evaluate) {
        setTimeout(() => {

            // get the winner of the game
            let result = evaluate_game(game)
            let p
            let p1,p2;
            game.players.forEach(player => {
                if (player.playernum == 1) {
                    p1 = player
                } else if (player.playernum == 2) {
                    p2 = player
                }
                player.hand.forEach(card => {
                    card.hidden = false
                })
            })
            let p1val = get_value(p1.hand,1,1)
            let p2val = get_value(p2.hand,1,1)
            switch(result) {
                case 1:
                    //p1 wins
                    p1.hp += game.ante
                    p2.hp -= game.ante
                    game.ante += 1
                    game.players.forEach(player => {
                        const socket = players[player.id]
                        p = new Packet('winner',[1,player.playernum,p1.hand,p2.hand,p1val,p2val])
                        console.log(p.message)
                        socket.send(p.toString())
                    })
                    break;
                case 2:
                        //p2 wins
                        p1.hp -= game.ante
                        p2.hp += game.ante
                        game.ante += 1
                        game.players.forEach(player => {
                            const socket = players[player.id]
                            p = new Packet('winner',[2,player.playernum,p1.hand,p2.hand,p1val,p2val])
                            console.log(p.message)
                            socket.send(p.toString())
                        })
                        break;
                case 3:
                   //draw
                   game.ante += 1
                   game.players.forEach(player => {
                        const socket = players[player.id]
                        p = new Packet('winner',[3,player.playernum,p1.hand,p2.hand,p1val,p2val])
                        socket.send(p.toString())
                    })
                    break;
            }
            undo_trumps(game.p1table,game)
            undo_trumps(game.p2table,game)
            console.log('tables undone',game.p1table,game.p2table)
            game.p1table = []
            game.p2table = []
            console.log(result,p1.hp,p2.hp,game.ante)
            if (result == 1 && p2.hp <= 0) {
                setTimeout(() => {
                    game.players.forEach(player => {
                        const socket = players[player.id]
                        if (player.playernum == 1) {
                            socket.send(new Packet('game-win','').toString())
                        } else {
                            socket.send(new Packet('game-lose','').toString())
                        }
                    })
                },8000)
            } else if (result == 2 && p1.hp <= 0) {
                setTimeout(() => {
                    game.players.forEach(player => {
                        const socket = players[player.id]
                        if (player.playernum == 2) {
                            socket.send(new Packet('game-win','').toString())
                        } else {
                            socket.send(new Packet('game-lose','').toString())
                        }
                    })
                },8000)
            } else {
                setTimeout(() => {
                    game.players.forEach(player => {
                        const socket = players[player.id]
                        let p = new Packet('new-round',player.playernum)
                        if (!socket) {
                            return
                        }
                        socket.send(p.toString())
                        game.deck = generate_deck()
                        player.hand = []
                        player['passed'] = false      
                    })
                    //increment round
                    game.round += 1
                    start_round(game)
                    game.turn = 1
                },8000)
            }
        },2000)
        return
    }
    setTimeout(() => {
        game.turn = turn
        send_turn()
    },2000)
}
function use_trump(socket,packet) {
    const [lobby,lobby_id] = find_player_lobby(socket)
    const game = games[lobby_id]
    const player = find_in_game(socket,game)
    if (!player) {
        console.error('Player not found in game')
        return
    }
    if (player.playernum != game.turn) return
    const trumpName = packet.message
    let trump = null
    let playerHas = false
    for (let x = 0; x < trumps.length; x ++) {
        const t = trumps[x]
        if (t.name == trumpName) {
            trump = t
            console.log(player.trumps)
            // Remove the trump from the player's hand
            let idx = player.trumps.findIndex(tn => tn === trumpName)
            const removed = player.trumps.splice(idx,1)
            console.log('removed',removed)
            if (removed.length > 0) {
                playerHas = true
            }
            break
        }
    }
    if (!playerHas) {
        // A little jab at the presumable cheater
        server_error(socket,"Nice try, bozo, but you can't use what you don't have")

        console.error('Player does not have the trump card',trumpName)
        return
    }
    if (!trump) {
        //error handling
        console.error('Trump does not exist')
        return
    }
    const other = game.players.find(p => p.playernum != player.playernum)
    console.log(player.trumps)
    switch (trump.name) {
        case 'Draw 2':
        case 'Draw 3':
        case 'Draw 4':
        case 'Draw 5':
        case 'Draw 6':
        case 'Draw 7':
        case 'Perfect Draw':
            useDrawSpecificCard(trump,player,game)
            break;
        case 'Hush':
            useHush(trump,player,game)
            break;
        case 'Yoink!':
            useYoink(trump,player, other, game)
            break;
        case 'Refresh':
            useRefresh(trump,player,game)
            break;
        case 'Ante-Up':
            useAnteUp(trump,player,game)
            add_table_trump(trump.name, player.playernum, game)
            break;
        case 'Ante-Up Plus':
            useAnteUpPlus(trump,player,game)
            add_table_trump(trump.name, player.playernum, game)
            break;
        case 'Remove':
            useRemove(trump,player,other,game)
            break;
        default:
            console.error('Oops, forgot to implement that one clown',trump.name)
            break;
    }
    //Trump has been used and the game state has changed so, "unready" the players from evaluation
    game.players.forEach(p => {
        p.passed = false
    })
    
    //send the updated trump data to the player
    const trumpPacket = new Packet('update-client-trumps',JSON.stringify(player.trumps))
    socket.send(trumpPacket.toString())
}
function add_table_trump(trumpName, playernum, game) {
    if (playernum == 1) {
        game.p1table.push(trumpName)
    } else if (playernum == 2) {
        game.p2table.push(trumpName)
    }
    console.log('table trumps',game.p1table,game.p2table)
}
function give_players_trump(num_used /* Player who used the trump */, trump_name, game) {
    game.players.forEach(player => {
        const socket = players[player.id]
        let event = `p${num_used}-table-trump`
        socket.send(new Packet(event, trump_name).toString())
    })
}
//general function when using a trump that draws a specific card from the deck
function useDrawSpecificCard(trump,player,game) {
    const card = trump.onUse(player, null, game)
    if (!card) {
        console.error('Perfect Draw failed, no card to draw')
        return
    }
    player.hand.push(card)
    // Send the card to the players
    game.players.forEach(p => {

        const socket = players[p.id]
        const packetDraw = new Packet(`p${player.playernum}-draw`,JSON.stringify({
            'card': JSON.stringify(card),
            'yours': p.playernum == player.playernum,
            'trump': true, //ignore the voicelines on the client and plays a trump sfx
        }))
        // Update the player's hand value
        const valObj = {
            'value': get_value(player.hand, p.playernum, player.playernum),
            'target': game.target,
            'hcount': get_hidden_count(player.hand),
            'yours': p.playernum == player.playernum,
        }
        const packetVal = new Packet(`p${player.playernum}-val`, JSON.stringify(valObj))
        // send the card to the client
        socket.send(packetDraw.toString())
        socket.send(packetVal.toString())
    })
}
function useRemove(trump,player,other,game) {
    //Remove the top trump card from the other player's table
    trump.onUse(player, other, game)

    // Send the packet to remove the top trump card, this is only visual so, hopefully this isn't insecure
    game.players.forEach(p => {
        const socket = players[p.id]
        let event = `p${other.playernum}-remove-top-trump`
        socket.send(new Packet(event,'').toString())
        const packet = new Packet('update-clock', JSON.stringify({
            'round': game.round,
            'hp': game.players[p.playernum - 1].hp,
            'ante': game.ante,
        }))
        socket.send(packet.toString())
    })
}
function useRefresh(trump,player,game) {
    const cards = trump.onUse(player, null, game)
    if (!cards || cards.length != 2) {
        //Theoretically impossible because you put your original two cards back in but hey, safety first
        console.error('Refresh failed, no cards to draw')
        return
    }
    game.players.forEach(p => {
        const socket = players[p.id]
        // Send both cards
        setTimeout(() => {
            //Remove all old cards
            socket.send(new Packet(`p${player.playernum}-remove-all`,'').toString())
            socket.send(value_packet(p.playernum,player.playernum,game).toString())
        },100)
        setTimeout(() => {
            send_card(p,cards[0],player.playernum,false,true)
            socket.send(value_packet(player.playernum,player.playernum,game).toString())
        },500)
        setTimeout(() => {
            send_card(p,cards[1],player.playernum,false,true)
            socket.send(value_packet(p.playernum,player.playernum,game).toString())
        },900)
    })
}
function useYoink(trump,player,other,game) {
    const otherCard = trump.onUse(player, other, game)
    if (!otherCard) {
        console.error('Yoink! failed, no card to draw')
        return
    }
    //Remove card from other player's hand
    game.players.forEach(p => {
        const socket = players[p.id]
        socket.send(new Packet(`p${other.playernum}-remove-last`,'').toString())
    })
    //Add to your own hand
    setTimeout(() => {
        player.hand.push(otherCard)
        game.players.forEach(p => {
            const socket = players[p.id]
            send_card(p,otherCard,player.playernum,false,true)
            const valObj = {
                'value': get_value(player.hand, p.playernum, player.playernum),
                'target': game.target,
                'hcount': get_hidden_count(player.hand),
                'yours': p.playernum == player.playernum,
            }
            const packetVal = new Packet(`p${player.playernum}-val`, JSON.stringify(valObj))
            const valObjOther = {
                'value': get_value(other.hand, p.playernum, other.playernum),
                'target': game.target,
                'hcount': get_hidden_count(other.hand),
                'yours': p.playernum == other.playernum,
            }
            const packetValOther = new Packet(`p${other.playernum}-val`, JSON.stringify(valObjOther))
            socket.send(packetValOther.toString())
            socket.send(packetVal.toString())
        })
    }, 500)
}
function useAnteUp(trump,player,game) {
    trump.onUse(player, null, game)
    // Send the updated ante to all players
    game.players.forEach(p => {
        const socket = players[p.id]
        const packet = new Packet('update-clock', JSON.stringify({
            'round': game.round,
            'hp': game.players[p.playernum - 1].hp,
            'ante': game.ante,
        }))
        socket.send(packet.toString())
    })
    give_players_trump(player.playernum, trump.name, game)
}
function useAnteUpPlus(trump,player,game) {
    trump.onUse(player, null, game)
    // Send the updated ante to all players
    game.players.forEach(p => {
        const socket = players[p.id]
        const packet = new Packet('update-clock', JSON.stringify({
            'round': game.round,
            'hp': game.players[p.playernum - 1].hp,
            'ante': game.ante,
        }))
        socket.send(packet.toString())
    })
    give_players_trump(player.playernum, trump.name, game)
}
function useHush(trump,player,game) {
    const card = trump.onUse(player, null, game)
    if (!card) {
        console.error('Hush failed, no card to draw')
        return
    }
    // Send the card to the players
    game.players.forEach(p => {
        const sock = players[p.id]
        const packetDraw = new Packet(`p${player.playernum}-draw`,JSON.stringify({
            'card': JSON.stringify( new Card(card.getValue(p.playernum == player.playernum),true) ),
            'yours': p.playernum == player.playernum,
            'trump': true, //ignore the voicelines on the client and plays a trump sfx
        }))
        // send the card to the client
        sock.send(packetDraw.toString())
    })
    player.hand.push(card)
    const playerSocket = players[player.id]
    const valuePacket = new Packet(`p${player.playernum}-val`, JSON.stringify({
        'value': get_value(player.hand, 1, 1),
        'target': game.target,
        'hcount': get_hidden_count(player.hand),
        'yours': true,
    }))
    playerSocket.send(valuePacket.toString())
}

function evaluate_game(game) {
    
    let p1,p2
    game.players.forEach(player => {
        if (player.playernum == 1) {
            p1 = player
        } else if (player.playernum == 2) {
            p2 = player
        }
    })
    let p1val = get_value(p1.hand,1,1)
    let p2val = get_value(p2.hand,1,1)
    if (p1val == p2val) {
        //draw
        return 3
    } else if (p1val > p2val) {
        //p2 wins bc p1 is over the target MORE than p2
        if (p1val > game.target) return 2
        //p1 wins bc any other case results in a p1 win
        return 1
    } else if (p2val > p1val) {
        //p1 wins bc p2 is over the target MORE than p1
        if (p2val > game.target) return 1
        //p2 wins bc any other case results in a p2 win
        return 2
    }
}
function eval_passed(game) {
    let passedNum = 0
    game.players.forEach(player => {
        if (player.passed) {
            passedNum += 1
        }
    })
    return passedNum == game.players.length
}

function find_in_game(socket,game) {
    const id = socket.id
    
    for (let x = 0; x < game.players.length; x ++) {
        const player = game.players[x]
        if (player.id == id) {
            return player
        }
    }
    return false
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
        console.log(data)
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
                join_game(socket,packet)
                break;
            case 'draw':
                player_draw_card(socket)
                break;
            case 'pass':
                player_pass_turn(socket)
                break;
            case 'use-trump':
                use_trump(socket,packet)
                break;
        }
    })
    socket.on('close',() => {
        console.log('client closed')
        //remove player from player list, freeing id
        let [lobby,lobby_id] = find_player_lobby(socket)
        console.log(lobby,lobby_id)
        let removed = false
        for (let id in lobby) {
            const sock = lobby[id]
            console.log(sock)
            if (sock.id == socket.id) {
                lobby.splice(id,0)
                removed = true
                break
            }
        }
        delete players[socket.id]
        if (!removed) return
        console.log('removed')
        // remove the lobby if there are no players or if there is a game instance running
        if (lobby.length <= 0 || games[lobby_id]) {
            delete lobbies[lobby_id]
        }
        const game = games[lobby_id]
        if (!game) return
        console.log('game found')
        let testP = find_in_game(socket,game)
        if (testP) {
            console.log('player is in game')
            let i = 0
            console.log('before',game.players)
            game.players.forEach(player => {
                if (player.id == socket.id) {
                    console.log('player id found')
                    game.players.splice(i,1)
                }
                i ++
            })
            game.players.forEach(player => {
                const sock = players[player.id]
                console.log('player')
                sock.send(new Packet('disband','').toString())
            })
            delete games[lobby_id]
            console.log(games,lobbies)
        }

    })
})
server.listen(PORT,() => {
    console.log(`Server listening on port ${PORT}`)
})
