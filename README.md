# Directus on Fly.io

Install Directus on [Fly.io](https://fly.io)

## Important 🚧

Fly requires a globally unique name for all the apps, and we've used the directory name and random hash as the app name. Of course, you can change this anytime you want BEFORE launching the app with Fly CLI. But it's not a big deal since you can reassign the internal Fly URL to any custom domain by adding a [`CNAME`][cname] record to your custom domain pointing to the Fly internal URL. We'll see that later when deploying the app to production.


## Fly Setup 🛠

1. [Install Fly](https://fly.io/docs/getting-started/installing-flyctl/)

2. Sign up and log in to Fly

```bash
flyctl auth signup
```

## Deployment 🚀

### Initial setup 👀

Before proceeding to deploy our app, we have some steps to take care of:

- Create a GitHub account [GitHub](https://repo.new)
- Create a new app on Fly

```bash
flyctl launch --name [YOUR-APP-NAME] --copy-config --no-deploy
```

> ⚠️ **Note:** Make sure this name matches the `app` set in your `fly.toml` file. Otherwise, you will not be able to deploy.

> ⚠️ Remember not to deploy since we have some setup steps left to complete!

### Environment variables and Secrets 🤫

This template comes with GitHub actions workflows to automatically deploy the app to Fly.io. First, we need to set up our GitHub actions and the Fly app with some secrets. Let's do that now.

To push the build image to the remote Fly registry from GitHub action, we need an access token from Fly. We can generate that using the Fly command line, run:

```sh
flyctl auth token
```

The command will generate an access token. You can then add this token to your GitHub actions secrets by visiting your GitHub repository's `settings` page `https://github.com/:owner/:repo/settings/secrets/actions` and then click `New repository secret`. Next, GitHub will prompt for a key and a value. The key should be `FLY_API_TOKEN`, and the value will be the token generated by the command line.

We also need to set the Fly app name as a secret, the key should be `FLY_APP_NAME`, and the value will be the app name specified in [fly.toml](./fly.toml)

Now we need to set up secrets in our Fly app.

We also need a secret to sign our session. We can do that by running the command:

```bash
flyctl secrets set KEY=$(openssl rand -hex 32)
flyctl secrets set SECRET=$(openssl rand -hex 32)
```

```bash
flyctl secrets set ADMIN_EMAIL=[YOUR@EMAIL.com]
flyctl secrets set ADMIN_PASSWORD=[YOUR-ADMIN-PASSWORD]
```

The last secret, is your `PUBLIC_URL`, you can get the initial domain from fly by typing:

```bash
flyctl info
```

To get the current app URL and IP address. The app URL will be `https://YOUR-APP-NAME.fly.dev`. 

```bash
flyctl secrets set PUBLIC_URL=https://[YOUR-APP-NAME].fly.dev
```

You can change this by following Fly's DNS docs and then just update the secret anytime

### Volumes 💾

We also need to create a volume in Fly to persist our app data (SQLite DB) so that Fly can persist the data stored across deployments and container restarts. Again, we can do that using the Fly command line.

```bash
flyctl volumes create data --region [REGION]] --size 1
```

> Note: REGION should be the region selected when launching the app. You can check the region chosen by running `flyctl regions list`.

It's important to note that Volumes are bound to an app in a region and cannot be shared between apps in the same region or across multiple regions.

You can learn more about Fly Volumes [here][volumes]

You should also update the region in your `fly.toml` file to whichever region you selected:

```toml
[env]
  FLY_PRIMARY_REGION = "[REGION]"
```

The other variables you can leave alone.

### Deploy 🥳

We are ready for our first deployment.

You have two ways to deploy:

- Via `npm run deploy`: deploy the current folder
- Via Github actions.

GitHub actions workflows are configured to run on push to the `main` branch. 

So let's push the local branch `main` to remote, triggering the workflows.

Once all the checks are passed, and the deployment is complete