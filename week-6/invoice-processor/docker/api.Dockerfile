FROM node:22-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production
ENV API_PORT=3001

RUN corepack enable

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig.base.json ./
COPY apps/api/package.json apps/api/package.json
COPY apps/webapp/package.json apps/webapp/package.json
COPY packages/db/package.json packages/db/package.json
COPY packages/types/package.json packages/types/package.json

RUN pnpm install --frozen-lockfile

COPY apps apps
COPY packages packages
COPY README.md README.md

RUN mkdir -p /app/apps/api/data /app/apps/api/uploads

EXPOSE 3001

CMD ["sh", "-c", "pnpm --filter @invoice-processor/api db:migrate:docker && pnpm --filter @invoice-processor/api start:docker"]
