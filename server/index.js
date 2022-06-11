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
                socket.join(room);
                io.to(name).emit('updateRoom', room);


            } catch (error) {
            }
        })
    })



server.listen(port, "0.0.0.0", () => {
    console.log(process.env.MONGO_KEY);

    console.log('Server started & running on port' + port);
})