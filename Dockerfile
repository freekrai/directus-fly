# base node image
FROM node:16-bullseye-slim as base

# set for base and all layer that inherit from it
ENV NODE_ENV production

# Install openssl for Prisma
RUN apt-get update && apt-get install -y openssl sqlite3

# Install all node_modules, including dev dependencies
FROM base as deps

WORKDIR /myapp

ADD package.json package-lock.json ./
RUN yarn install --production=false

# Setup production node_modules
FROM base as production-deps

WORKDIR /myapp

COPY --from=deps /myapp/node_modules /myapp/node_modules
ADD package.json package-lock.json ./
#RUN npm prune --production

# Finally, build the production image with minimal footprint
FROM base

ENV DATABASE_URL=file:/data/database/sqlite.db
ENV PORT="6055"
ENV NODE_ENV="production"

# add shortcut for connecting to database CLI
RUN echo "#!/bin/sh\nset -x\nsqlite3 \$DATABASE_URL" > /usr/local/bin/database-cli && chmod +x /usr/local/bin/database-cli

WORKDIR /myapp

COPY --from=production-deps /myapp/node_modules /myapp/node_modules
#COPY --from=base /myapp/node_modules/.prisma /myapp/node_modules/.prisma

#COPY --from=base /myapp /myapp
#COPY --from=base /myapp/public /myapp/public
ADD . .

#CMD ["npm", "start"]
CMD ["bash", "start.sh"]

