# ───────────────────────────────────────────────────────────────────────────
# Build Stage: install dependencies and generate minified assets
# ───────────────────────────────────────────────────────────────────────────

# The official Node.js 22 Alpine image as a lightweight build environment
FROM node:22-alpine AS builder

# Set /app as the working directory; all subsequent commands run here
WORKDIR /app

# Copy only the package.json for the minify script into the build context
# This allows npm install to cache dependencies without copying all source files
COPY data/minify/package.json ./data/minify/

# Change into the data/minify directory and install the Node.js dependencies
# needed to run the minification/build script
RUN cd data/minify && npm install

# Copy the rest of your application (source code, data/src, index.html, roms/, etc.)
# into the container so the build script can see everything it needs
COPY . .

# Execute the build script defined in package.json
# This generates all the .min.js, .min.css, and other assets in the data/ folder
RUN cd data/minify && npm run build

# ───────────────────────────────────────────────────────────────────────────
# Production Stage: serve the ready-to-use assets via Nginx
# ───────────────────────────────────────────────────────────────────────────

# The official Nginx Alpine image for a minimal, production-ready web server
FROM nginx:1.27-alpine

# Metadata indicating who maintains this Docker image
LABEL maintainer="https://github.com/nelsonwenner"

# Remove the default Nginx static content so we can replace it with our own
RUN rm -rf /usr/share/nginx/html/*

# Copy the generated static files from the builder stage into Nginx's web root:
# index.html – entry point that initializes EmulatorJS with the correct settings
COPY --from=builder /app/index.html   /usr/share/nginx/html/

# roms/ – The directory containing the game ROM(s), e.g., topgear.sfc
COPY --from=builder /app/roms         /usr/share/nginx/html/roms

# data/ – all emulator runtime assets: 
#        - minified JS/CSS (.min.js, .min.css)
#        - loader.js, version.json, etc.
#        - cores/WASM files under data/cores/
COPY --from=builder /app/data         /usr/share/nginx/html/data

# Declare that the container listens on port 80 at runtime
EXPOSE 80

# Start Nginx in the foreground so the container doesn’t exit
CMD ["nginx", "-g", "daemon off;"]
