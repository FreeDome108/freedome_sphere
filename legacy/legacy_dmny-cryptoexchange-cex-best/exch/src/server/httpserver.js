const express = require("express");
const http = require('http');

class HttpServer {
    constructor(args) {
        const PORT = global.config.api_port;
        const app = express();
        //app.use(cors());


        const httpServer = http.createServer(app);
        httpServer.listen({ port: PORT }, () => {
            console.log(`🚀  HTTP ready at:\n   http://localhost:${PORT}`);
        });
    }
}

module.exports = {
    HttpServer:HttpServer,
}