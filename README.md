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

## CI

`.github/workflows/ci.yml` runs on every pull request and push to `master`:

- **lint** -- `npm run lint` (ESLint) and `node --check bot.js`
- **test** -- `npm test`
- **docker** -- builds the image and smoke tests it

## Release pipeline

`.github/workflows/pipeline.yml` runs on every push to `master` (modeled after
[atomy/service-template](https://github.com/atomy/service-template)):

1. **Auto-tag** -- bumps the patch version and pushes the new git tag
2. **Build** -- builds the Docker image and tags it for ECR
3. **Test** -- smoke tests the built image
4. **Push** -- pushes the image to ECR
5. **Deploy** -- renders `docker-compose.yml.dist` and deploys it to the target host via SSH
6. **Notify** -- posts the release changelog to Discord

### Required repository variables

| Variable       | Description                                            |
|----------------|--------------------------------------------------------|
| `AWS_REGION`   | AWS region of the ECR registry (e.g. `eu-central-1`)   |
| `ECR_REGISTRY` | ECR registry host (`<account>.dkr.ecr.<region>.amazonaws.com`) |

### Required repository secrets

| Secret                  | Description                                        |
|-------------------------|----------------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | AWS credentials with ECR push access               |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials with ECR push access               |
| `GIT_SSH_KEY`           | Deploy key with write access to this repo (auto-tag) |
| `DEPLOY_SSH_KEY`        | SSH key for the deploy host                        |
| `DEPLOY_HOST_KEY`       | `known_hosts` entry of the deploy host             |
| `DEPLOY_HOST`           | Deploy host                                        |
| `DEPLOY_USER`           | SSH user on the deploy host                        |
| `DEPLOY_PATH`           | Target directory for `docker-compose.yml`          |
| `DISCORD_WEBHOOK_URL`   | Discord webhook for release notifications          |
| `DISCORD_API_KEY`       | Bot token (rendered into the deployed compose file)|
| `SERVER_IP`             | Rust server IP                                     |
| `SERVER_RCONPORT`       | Rust server RCON port                              |
| `SERVER_RCONPASSWORD`   | Rust server RCON password                          |