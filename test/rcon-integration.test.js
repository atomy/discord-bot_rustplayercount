const test = require('node:test');
const assert = require('node:assert');
const { WebSocketServer } = require('ws');
const WebRcon = require('webrconjs');

// Exercises the same webrconjs surface bot.js uses (connect, run, message,
// disconnect) against a mock Rust RCON server, so the ws override in
// package.json is covered by a real client/server round trip.
test('webrconjs talks to a Rust-style RCON server over the overridden ws', async () => {
    const RCON_PASSWORD = 'testpassword';
    const serverinfoPayload = {
        Message: JSON.stringify({ Players: 42, MaxPlayers: 100, Queued: 0, Joining: 0 }),
        Type: 3,
        Stacktrace: null,
        Identifier: 0
    };

    const wss = new WebSocketServer({ host: '127.0.0.1', port: 0 });
    await new Promise(resolve => wss.on('listening', resolve));
    const port = wss.address().port;

    const seenPaths = [];
    wss.on('connection', (socket, request) => {
        seenPaths.push(request.url);
        socket.on('message', raw => {
            const command = JSON.parse(raw.toString());
            if (command.Message === 'serverinfo') {
                socket.send(JSON.stringify(serverinfoPayload));
            }
        });
    });

    const rcon = new WebRcon('127.0.0.1', port);
    try {
        const connected = new Promise((resolve, reject) => {
            rcon.on('connect', resolve);
            rcon.on('error', reject);
        });
        const messaged = new Promise(resolve => rcon.on('message', resolve));

        rcon.connect(RCON_PASSWORD);
        await connected;
        assert.strictEqual(rcon.connected, true);
        assert.strictEqual(seenPaths[0], '/' + RCON_PASSWORD);

        rcon.run('serverinfo', 0);
        const msg = await messaged;

        // bot.js JSON.parses msg.message and reads these fields
        const data = JSON.parse(msg.message);
        assert.strictEqual(data.Players, 42);
        assert.strictEqual(data.MaxPlayers, 100);
        assert.strictEqual(data.Queued, 0);
        assert.strictEqual(data.Joining, 0);
        assert.strictEqual(msg.identity, 0);

        const disconnected = new Promise(resolve => rcon.on('disconnect', resolve));
        for (const client of wss.clients) client.close();
        await disconnected;
        assert.strictEqual(rcon.connected, false);
    } finally {
        rcon.removeAllListeners();
        if (rcon.socket) rcon.socket.close();
        await new Promise(resolve => wss.close(resolve));
    }
});
