# Rust Player Count Bot

This bot will connect to rcon and display your player count of your server as a status message.

Example output from the bot 
https://gyazo.com/3f77e646e19b545854a20f846036fa22

## How to setup

1. Have [Node.JS](https://nodejs.org) installed.
2. Clone the repository onto your computer.
3. Open a terminal in that folder, and install the packages with `npm install`.
4. Set required envs, see vars.sh.dist, `cp vars.sh.dist vars.sh`
5. `source vars.sh && node bot.js`

## Docker support

The bot also has docker support, see scripts/ for building, running and deploying.