# Dockerfile: From Basics to Mastery

A complete guide so you can write production-ready Dockerfiles on your own.

---

## Table of Contents
1. [What is a Dockerfile?](#1-what-is-a-dockerfile)
2. [Anatomy of a Dockerfile](#2-anatomy-of-a-dockerfile)
3. [Every Instruction Explained](#3-every-instruction-explained)
4. [Environment & Arguments](#4-environment--arguments)
5. [Multi-Stage Builds](#5-multi-stage-builds)
6. [Best Practices](#6-best-practices)
7. [Common Patterns by Language](#7-common-patterns-by-language)
8. [Debugging & Optimization](#8-debugging--optimization)
9. [Practice Exercises](#9-practice-exercises)

---

## 1. What is a Dockerfile?

A **Dockerfile** is a text file containing instructions that Docker uses to build an **image**. An image is a read-only template; when you run it, you get a **container**.

- **Dockerfile** → build → **Image** → run → **Container**
- Think of the Dockerfile as the "recipe" and the image as the "baked cake."

### Why use a Dockerfile?
- **Reproducibility**: Same file → same image on any machine
- **Version control**: Dockerfile lives in Git with your app
- **Automation**: CI/CD can build and push images from the Dockerfile

---

## 2. Anatomy of a Dockerfile

A minimal Dockerfile has two things:

```dockerfile
# 1. Base image (what your image starts from)
FROM ubuntu:22.04

# 2. What to run when the container starts (optional but common)
CMD ["echo", "Hello, World!"]
```

Build and run:
```bash
docker build -t myimage .
docker run myimage
# Output: Hello, World!
```

### Line-by-line rules
- **One instruction per line** (usually). Instructions are in UPPERCASE by convention.
- **Lines are executed in order** during build. Later lines can use results of earlier lines.
- **Comments** start with `#`.
- **`\` at end of line** continues the instruction to the next line.

---

## 3. Every Instruction Explained

### 3.1 `FROM` — Base image (required)

Sets the starting image. Every valid Dockerfile must start with `FROM` (except `ARG` before the first `FROM`).

```dockerfile
FROM <image>[:<tag>] [AS <name>]
```

**Examples:**
```dockerfile
FROM ubuntu:22.04
FROM node:20-alpine
FROM python:3.11-slim
FROM golang:1.21-alpine AS builder
```

- Use **specific tags** (`22.04`, `20-alpine`), not `latest`.
- **Alpine** = smaller images; **slim** = smaller Debian-based; **full** = larger, more tools.

---

### 3.2 `RUN` — Run commands during build

Runs commands **inside the image** while building. Each `RUN` adds a new layer.

**Shell form** (runs in `/bin/sh -c`):
```dockerfile
RUN apt-get update && apt-get install -y curl
RUN pip install -r requirements.txt
```

**Exec form** (no shell, direct exec):
```dockerfile
RUN ["apt-get", "update"]
RUN ["pip", "install", "-r", "requirements.txt"]
```

**Best practice:** Chain commands in one `RUN` to reduce layers and keep image smaller:
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
```

---

### 3.3 `COPY` — Copy files from host into image

Copies files/directories from the **build context** (usually the directory where you run `docker build`) into the image.

```dockerfile
COPY <src>... <dest>
COPY ["<src>", "<dest>"]   # For paths with spaces
```

**Examples:**
```dockerfile
COPY package.json .
COPY src/ ./src/
COPY . /app
```

- `<dest>` can be absolute or relative to `WORKDIR`.
- If `<dest>` ends with `/`, it’s treated as a directory.
- **`.dockerignore`** is important so you don’t copy huge or sensitive files (e.g. `node_modules`, `.git`).

---

### 3.4 `ADD` — Copy + extract or download (use sparingly)

Like `COPY`, but can:
- **Extract** tar archives (e.g. `ADD app.tar.gz /app`)
- **Download** from URLs (e.g. `ADD https://example.com/file.tar.gz /tmp/`)

**Prefer `COPY`** unless you need extraction or URL download. `COPY` is more predictable and doesn’t do hidden magic.

```dockerfile
ADD https://example.com/file.tar.gz /tmp/   # Downloads and does NOT extract .tar.gz
ADD app.tar.gz /app/                         # Copies and extracts
```

---

### 3.5 `WORKDIR` — Set working directory

Sets the current directory for all following instructions (like `cd`). Creates the directory if it doesn’t exist.

```dockerfile
WORKDIR /app
RUN pwd   # /app
COPY . .  # copies into /app
```

Use `WORKDIR` instead of `RUN cd ...` so each instruction runs in a clear, consistent path.

---

### 3.6 `ENV` — Set environment variables

Sets environment variables **in the image** (build and runtime).

```dockerfile
ENV KEY=value
ENV KEY1=value1 KEY2=value2
ENV NODE_ENV=production
ENV PATH="/app/bin:${PATH}"
```

These are visible in the running container and to any `RUN`, `CMD`, or `ENTRYPOINT`.

---

### 3.7 `ARG` — Build-time only variable

Defines a variable available **only during build**, not in the final image (unless you also set it with `ENV`).

```dockerfile
ARG VERSION=1.0
RUN echo $VERSION
```

Pass from CLI:
```bash
docker build --build-arg VERSION=2.0 -t myapp .
```

**Scope:** An `ARG` is only visible in the Dockerfile after its definition until the next `FROM`. To use an `ARG` in a `FROM` tag, you declare it before the first `FROM`:
```dockerfile
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine
```

---

### 3.8 `EXPOSE` — Document the port (documentation only)

Documents which port the container **intends** to listen on. It does **not** publish the port.

```dockerfile
EXPOSE 8080
```

Publishing is done at runtime: `docker run -p 8080:8080 myimage`.

---

### 3.9 `CMD` — Default command when container runs

Provides the **default** command (and arguments) when the container starts. Only one `CMD` is used; if multiple are present, the last one wins.

**Exec form (preferred):**
```dockerfile
CMD ["executable", "arg1", "arg2"]
CMD ["python", "app.py"]
```

**Shell form:**
```dockerfile
CMD python app.py
CMD echo "Hello"
```

- Anything passed to `docker run` after the image name **replaces** `CMD` (in exec form, it replaces the whole list).
- Use **exec form** so the process gets PID 1 and signals (e.g. SIGTERM) work correctly.

---

### 3.10 `ENTRYPOINT` — Fixed executable, `CMD` as default args

`ENTRYPOINTINT` is the **fixed** executable; `CMD` (if present) is the **default argument list** to that executable.

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
# docker run myimage        → python app.py
# docker run myimage test.py → python test.py
```

**When to use:**
- **ENTRYPOINT**: You want the image to always run one binary (e.g. `python`, `java`). Users can override args.
- **CMD**: You want a default command that users can override completely with `docker run ... <command>`.

**Combination:** `ENTRYPOINT` + `CMD` = default: `ENTRYPOINT CMD`; override: `docker run image <new args>` only replaces `CMD`.

---

### 3.11 `VOLUME` — Declare mount points

Declares one or more directories as mount points (for external volumes).

```dockerfile
VOLUME ["/data", "/logs"]
```

Creates anonymous volumes at those paths. At runtime you can replace them with named volumes or bind mounts: `docker run -v mydata:/data ...`.

---

### 3.12 `USER` — Run as non-root

Switches to the given user/group for subsequent instructions and at runtime.

```dockerfile
RUN adduser --disabled-password appuser
USER appuser
COPY --chown=appuser:appuser . /app
```

Improves security by not running as root.

---

### 3.13 `LABEL` — Metadata

Adds key-value metadata to the image.

```dockerfile
LABEL maintainer="you@example.com"
LABEL version="1.0" description="My app"
```

Use for version, maintainer, description, etc. Inspect with `docker inspect`.

---

### 3.14 `HEALTHCHECK` — Container health

Tells Docker how to test if the container is healthy.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

Use in production so orchestrators (e.g. Kubernetes) can restart unhealthy containers.

---

### 3.15 `ONBUILD` — Run instruction in child builds

Runs the given instruction when **another image** is built **using this image as base**.

```dockerfile
ONBUILD COPY . /app
ONBUILD RUN pip install -r requirements.txt
```

Use in base images that others will `FROM`; avoid overusing, as it can be surprising.

---

### 3.16 `.dockerignore`

Not an instruction; it’s a file in the build context. Lists files/directories to **exclude** from the context (like `.gitignore`).

**Example `.dockerignore`:**
```
.git
.gitignore
node_modules
__pycache__
*.pyc
.env
Dockerfile
*.md
```

This speeds up builds and keeps secrets and junk out of the image.

---

## 4. Environment & Arguments

| Item   | When set      | Where visible   | Use case                    |
|--------|----------------|-----------------|-----------------------------|
| `ENV`  | Build + runtime| Image & container | App config (e.g. NODE_ENV) |
| `ARG`  | Build only     | Dockerfile      | Versions, build-time options |
| `RUN export` | Build only | That `RUN` layer | Temporary in one step   |

**Example:**
```dockerfile
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
# Now NODE_ENV is in the image and can be overridden at run: docker run -e NODE_ENV=development ...
```

---

## 5. Multi-Stage Builds

Use **multiple `FROM`** in one Dockerfile. Only the last stage’s files end up in the final image. Earlier stages are for building only.

**Why:** Keeps the final image small and free of build tools and source.

**Example: Go app**
```dockerfile
# Stage 1: build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /myapp .

# Stage 2: run
FROM alpine:3.19
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /myapp .
USER nobody
EXPOSE 8080
CMD ["./myapp"]
```

**Example: Node.js**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

Copy from a stage by name: `COPY --from=builder /path /path`.

---

## 6. Best Practices

1. **Use a small, specific base:** `alpine` or `-slim`, with a fixed tag.
2. **Minimize layers:** Combine `RUN` commands and clean up in the same layer (e.g. `apt-get clean`, `rm -rf /var/lib/apt/lists/*`).
3. **Order for cache:** Put less-changing instructions first (e.g. dependency install), then copy source and build.
4. **Use `.dockerignore`** to keep context small and avoid copying secrets.
5. **Prefer `COPY` over `ADD`** unless you need URL download or archive extraction.
6. **One process per container**; use one main `CMD` or `ENTRYPOINT`.
7. **Run as non-root:** Create a user and use `USER`.
8. **Use exec form for `CMD`/`ENTRYPOINT`:** `["executable", "arg"]` so PID 1 and signals work.
9. **Multi-stage** for compiled languages and frontend builds to keep final image small.
10. **Pin versions** in base image and in install commands (e.g. `pip install package==1.2.3`).

---

## 7. Common Patterns by Language

### Python (Flask/FastAPI)
```dockerfile
FROM python:3.11-slim
WORKDIR /app
RUN useradd -m appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js (Express)
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

### Java (Spring Boot JAR)
```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN adduser -D appuser
COPY --chown=appuser:appuser target/*.jar app.jar
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Static site (nginx)
```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY dist/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 8. Debugging & Optimization

### Build
```bash
docker build -t myimage .
docker build --no-cache -t myimage .   # Ignore cache
docker build --progress=plain -t myimage .  # Verbose output
docker build -f Dockerfile.dev -t myimage . # Different file
```

### Inspect
```bash
docker history myimage          # Layers and sizes
docker inspect myimage          # Full metadata
docker run --entrypoint /bin/sh myimage -c "ls -la"  # Override entrypoint to debug
```

### Size
- Prefer multi-stage builds.
- Use `alpine` or `slim` bases.
- Remove package manager caches in the same `RUN` (e.g. `apt-get clean`, `rm -rf /var/lib/apt/lists/*`).
- Use `docker image prune` and multi-stage to drop build layers.

---

## 9. Practice Exercises

Do these in order; each builds on the previous.

1. **Minimal:** Dockerfile that prints "Hello from Docker" using `FROM alpine` and `CMD`.
2. **Static file server:** Dockerfile that serves a single `index.html` with `nginx:alpine`.
3. **Python script:** Dockerfile for a single `.py` file that uses `requests`; install deps and run the script.
4. **Multi-stage Node:** Stage 1: `npm run build`. Stage 2: copy `dist` and `node_modules`, run with `node`.
5. **Non-root + HEALTHCHECK:** Add a user, run app as that user, and add a `HEALTHCHECK` that hits `/health`.

---

## Quick Reference Card

| Instruction | Purpose |
|-------------|---------|
| `FROM` | Base image (required) |
| `RUN` | Run command during build |
| `COPY` | Copy from host to image |
| `ADD` | Copy + extract/URL (use sparingly) |
| `WORKDIR` | Set current directory |
| `ENV` | Set env var (build + runtime) |
| `ARG` | Build-time variable only |
| `EXPOSE` | Document port (no publish) |
| `CMD` | Default run command |
| `ENTRYPOINT` | Fixed executable |
| `USER` | Switch user |
| `VOLUME` | Declare mount point |
| `HEALTHCHECK` | Health check command |
| `ONBUILD` | Run when used as base |

---

By the end of this guide you have:
- Understood what a Dockerfile is and how it relates to images and containers.
- Learned every main instruction and when to use it.
- Used multi-stage builds, env/args, and security (USER, exec form).
- Applied best practices and language-specific patterns.
- Practiced with concrete exercises.

Use this doc as a reference while you write Dockerfiles; with a few real projects you’ll internalize it and be able to write and review Dockerfiles on your own.
