FROM node:22-bookworm-slim AS builder

WORKDIR /app

RUN corepack enable

ARG NEXT_PUBLIC_API_URL=http://localhost:3001
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

FROM node:22-bookworm-slim AS runner

WORKDIR /app/apps/webapp

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/apps/webapp/package.json ./package.json
COPY --from=builder /app/apps/webapp/.next ./.next
COPY --from=builder /app/apps/webapp/public ./public

EXPOSE 3000

CMD ["node", "/app/node_modules/next/dist/bin/next", "start", "--hostname", "0.0.0.0", "--port", "3000"]
