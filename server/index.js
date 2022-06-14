const express = require('express');
var http = require('http');
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require('mongoose');

var io = require('socket.io')(server);
const Room = require('./models/Room')
const getWord = require('./api/getWord')
const mongoKey = process.env.MONGO_KEY

//middleware
app.use(express.json());

// Connect to our Database
const DB = `mongodb+srv://debajyoti14:7r4KqYSpwg4N0Tfx@cluster0.inq8lyq.mongodb.net/?retryWrites=true&w=majority`
mongoose.connect(DB).then(() => console.log('Connection Successful')).catch((e) => console.log(e)),


    io.on('connection', (socket) => {
        console.log('Connected');
        //CREATE GAME CALLBACK
        socket.on("create-game", async ({ nickname, name, occupancy, maxRounds }) => {
            try {
                const existingRoom = await Room.findOne({ name });
                if (existingRoom) {
                    socket.emit('notCorrectGame', 'Room with that name already exists')
                    return
                }
                let room = new Room();
                const word = getWord();
                room.word = word;
                room.name = name;
                room.occupancy = occupancy;
                room.maxRounds = maxRounds;

                let player = {
                    socketId: socket.id,
                    nickname,
                    isPartyLeader: true,
                }
                room.players.push(player);
                room = await room.save();
                socket.join(name);
                io.to(name).emit('updateRoom', room);


            } catch (error) {
                console.log(error);
            }
        })

        //JOIN GAME CALLBACK
        socket.on('join-game', async ({ nickname, name }) => {
            try {
                let room = await Room.findOne({ name })
                if (!room) {
                    socket.emit('notCorrectGame', 'Please enter a valid room name')
                    return

                }

                if (room.isJoin) {
                    let player = {
                        socketId: socket.id,
                        nickname
                    }
                    room.players.push(player);
                    socket.join(name);

                    if (room.players.length === room.occupancy) {
                        room.isJoin = false;
                    }
                    room.turn = room.players[room.turnIndex];
                    room = await room.save();
                    io.to(name).emit('updateRoom', room);

                } else {
                    socket.emit('notCorrectGame', 'Match is in Progress, Please connect later!')

                }

            } catch (error) {
                console.log(error);
            }
        })

        // WhiteBoard Sockets
        socket.on('paint', ({ details, roomName }) => {
            io.to(roomName).emit('points', { details: details, })
        })


    })



server.listen(port, "0.0.0.0", () => {
    console.log(process.env.MONGO_KEY);

    console.log('Server started & running on port' + port);
})