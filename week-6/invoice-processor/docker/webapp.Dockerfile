FROM node:22-bookworm-slim

WORKDIR /app

RUN corepack enable

ARG NEXT_PUBLIC_API_URL=http://localhost:3001
ENV NODE_ENV=production
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig.base.json ./
COPY apps/api/package.json apps/api/package.json
COPY apps/webapp/package.json apps/webapp/package.json
COPY packages/db/package.json packages/db/package.json
COPY packages/types/package.json packages/types/package.json

RUN pnpm install --frozen-lockfile

COPY apps apps
COPY packages packages
COPY README.md README.md

RUN pnpm --filter @invoice-processor/types build
RUN pnpm --filter @invoice-processor/webapp build

EXPOSE 3000

CMD ["pnpm", "--filter", "@invoice-processor/webapp", "start"]
