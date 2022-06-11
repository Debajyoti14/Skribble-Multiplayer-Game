const mongoose = require('mongoose');

const playerSchema = new mongoose.Schema({
    nickname: {
        type: String,
        trim: true,
    },
    socketId: {
        type: String,

    },
    isPartyLeader: {
        type: Boolean,
        default: false,
    },
    points: {
        type: Number,
        default: 0,
    }
})

const playerModel = mongoose.model('Player', playerSchema)
module.exports = { playerModel, playerSchema }
