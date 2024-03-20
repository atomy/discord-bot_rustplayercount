const WebRcon = require('webrconjs')
const { Client, GatewayIntentBits, ActivityType } = require('discord.js');
const discordClient = new Client({ intents: [
        GatewayIntentBits.Guilds,
    ]
});

if (!process.env.DISCORD_API_KEY || process.env.DISCORD_API_KEY.length <= 0) {
    console.log('ERROR: Env variable DISCORD_API_KEY does not exists or is empty!');
    process.exit(1);
}

if (!process.env.SERVER_IP || process.env.SERVER_IP.length <= 0) {
    console.log('ERROR: Env variable SERVER_IP does not exists or is empty!');
    process.exit(1);
}

if (!process.env.SERVER_RCONPORT || process.env.SERVER_RCONPORT.length <= 0) {
    console.log('ERROR: Env variable SERVER_PORT does not exists or is empty!');
    process.exit(1);
}

if (!process.env.SERVER_RCONPASSWORD || process.env.SERVER_RCONPASSWORD.length <= 0) {
    console.log('ERROR: Env variable SERVER_IP does not exists or is empty!');
    process.exit(1);
}

const discordApiKey = process.env.DISCORD_API_KEY;

const serverIP = process.env.SERVER_IP;
const serverRconPort = process.env.SERVER_RCONPORT;
const serverRconPassword = process.env.SERVER_RCONPASSWORD;

server = {};
server.name = `${serverIP}:${serverRconPort}/0`
server.rcon = new WebRcon(serverIP, serverRconPort)
server.connected = false;
server.bot = discordClient;
server.bot.login(discordApiKey)

let waitingForMessage = false
let lastMessage = ''

// Login to discord
server.bot.on('ready', () => {
    console.log('Logged in as', server.bot.user.tag)
    server.bot.user.setActivity('Server Connecting...');
    reconnect()
})

server.bot.on('error', error => {
 console.error('The websocket connection encountered an error:', error);
});

process.on('unhandledRejection', error => {
console.error('Unhandled promise rejection:', error);
});

server.rcon.on('connect', function () {
    try {
        server.connected = true;
        console.log(server.name, 'CONNECTED');
        lastMessage = '';
        server.bot.user.setActivity('Server Connecting...');
    } catch {
    }
        function getData() {
            if (server.connected === true) {
            try {
                server.rcon.run('serverinfo', 0);
                setTimeout(getData, 5000);
            } catch {
            }
        }
    }
    getData();
});

server.rcon.on('message', function (msg) {
    // console.log("on message: " + JSON.stringify(msg))
    // Parse Messages
    const data = JSON.parse(msg.message)
    // Set Discord status (No idea why it returns undefined sometimes simple fix added to prevent it.)
    if (data.Players === undefined) {
        return;
    } else if (data.Queued > 0) {
        setMessage(`(${data.Players}/${data.MaxPlayers} (${data.Queued}) Queued)`);
        waitingForMessage = true
    } else if (data.Joining === 0) {
        setMessage(`(${data.Players}/${data.MaxPlayers} Online)`);
        waitingForMessage = true
    } else {
        setMessage(`(${data.Players}/${data.MaxPlayers} (${data.Joining}) Joining)`);
        waitingForMessage = true
    }
})

// Spam prevention to discord api (If message is the same it will not paste over and over!)
function setMessage(newMessage) {
    // If message is the same, ignore.
    if (waitingForMessage === true && newMessage === lastMessage) {
        return;
    } else {
        server.bot.user.setActivity(newMessage);
        console.log(server.name, newMessage);
        lastMessage = newMessage
        waitingForMessage = false;
    }
}

// Disconnect function to know when the rcon gets disconnected / server restarts
server.rcon.on('disconnect', function () {
    server.connected = false;
    server.bot.user.setActivity('Server Offline...');
    console.log(server.name, "Server Offline");
    // Reconnect if server goes offline
    if (server.connected === false) {
        try {
            console.log(server.name, "TRYING TO RECONNECT");
            setTimeout(reconnect, 5000);
        } catch {
        }
    }
})

// Connect / Reconnect function
function reconnect() {
    try {
        server.rcon.connect(serverRconPassword)
    } catch (e) {
        console("EX: " + e);
    }
}
