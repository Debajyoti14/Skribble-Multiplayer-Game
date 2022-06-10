const express = require('express');
var http = require('http');
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require('mongoose');

var io = require('socket.io')(server);
const mongoKey = process.env.MONGO_KEY

//middleware
app.use(express.json());

// Connect to our Database
const DB = `mongodb+srv://debajyoti14:7r4KqYSpwg4N0Tfx@cluster0.inq8lyq.mongodb.net/?retryWrites=true&w=majority`
mongoose.connect(DB).then(() => console.log('Connection Successful')).catch((e) => console.log(e))

server.listen(port, "0.0.0.0", () => {
    console.log(process.env.MONGO_KEY);

    console.log('Server started & running on port' + port);
})