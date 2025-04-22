# EmulatorJS Docker Container – TopGear

This repository demonstrates how to package [EmulatorJS](https://github.com/EmulatorJS/EmulatorJS) into a Docker image and serve it via Nginx. By default, the project ships with the **TopGear** (SNES) ROM to showcase a working example, but you can easily customize it to run any supported game.

## Links

- EmulatorJS website: [https://www.emulatorjs.com/](https://www.emulatorjs.com/)
- EmulatorJS GitHub: [https://github.com/EmulatorJS/EmulatorJS](https://github.com/EmulatorJS/EmulatorJS)

## Project Structure

```
emulatorjs/
├── data/           # Minified EmulatorJS assets and WASM cores (built via Node)
├── roms/           # Game ROM files (default: topgear.smc)
├── index.html      # HTML entry point configured for TopGear by default
├── loader.js       # EmulatorJS loader script
├── Dockerfile      # Multi-stage Dockerfile (build & production stages)
└── README.md       # This documentation
```

## Default Game: TopGear (SNES)

- File: `roms/topgear.sfc`
- Emulator core: `snes`

You can replace `topgear.sfc` in the `roms/` folder with any other ROM, and update `index.html` accordingly.

## Prerequisites

- [Docker](https://www.docker.com/) installed on your machine

## Build the Docker Image

From the root of this project (where the `Dockerfile` lives), run:

```bash
$ docker build . -t emulatorjs-topgear:latest
```

This multi-stage build does the following:

1. **Builder stage** (Node 22‑alpine)
   - Installs dependencies for asset generation
   - Runs `npm run build` in `data/minify` to produce all minified JS, CSS, and WASM cores
2. **Production stage** (Nginx 1.27‑alpine)
   - Cleans Nginx’s default content
   - Copies the built `data/`, `index.html`, and `roms/` into Nginx’s web root
   - Exposes port 80 and starts Nginx in the foreground

## Run the Docker Container

```bash
$ docker run -d -p 8080:80 emulatorjs-topgear:latest
```

- Access the emulator at: `http://localhost:8080`

## Usage and Customization

1. **Default setup**: TopGear will load automatically.
2. **Custom ROM**: Replace `roms/topgear.sfc` with your own ROM (e.g., `mario.sfc`).
3. **Update HTML**: In `index.html`, change:
   ```html
   <script>
     EJS_player   = '#game';
     EJS_gameUrl  = './roms/yourgame.smc';
     EJS_core     = '<appropriate_core>';  // e.g., 'snes', 'segaMD', 'nes'
     EJS_mouse    = false;
     EJS_multitap = false;
   </script>
   <script src="loader.js"></script>
   ```
4. **Rebuild**: If you swap ROMs or cores, rebuild the Docker image and restart the container.

---

Enjoy emulating TopGear or your favorite retro title entirely offline, served from a lightweight Docker container!
