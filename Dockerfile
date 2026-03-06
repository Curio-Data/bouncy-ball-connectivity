# Stage 1: Build
FROM oven/bun:latest AS builder

WORKDIR /app

COPY package.json bun.lock* ./
RUN bun install

COPY . .
RUN bun run build

# Stage 2: Runtime
FROM oven/bun:slim

WORKDIR /app

COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./

EXPOSE 3000

CMD ["bun", "./build/index.js"]
