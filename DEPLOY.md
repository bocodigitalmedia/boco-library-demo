# Deploying

Set the following variables for deployment per-run:

```bash
DEPLOY_PATH="/srv/www/boco-library-demo"
GIT_REPO="git@github.com:bocodigitalmedia/boco-library-demo.git"
```

## Initial deployment

Simply clone the repo as follows, then follow the instructions for "updating a deployment".

```bash
git clone $GIT_REPO $DEPLOY_PATH
```

## Updating a deployment

Execute the `bin/deploy` script:

```bash
cd $DEPLOY_PATH
./bin/deploy
```
