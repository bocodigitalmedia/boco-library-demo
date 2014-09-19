# Deploying the first time

```
cd /srv/www/
git clone git@github.com:bocodigitalmedia/boco-library-demo.git
cd boco-library-demo
npm install
sudo cp -f ./upstart.conf /etc/init/boco-library-demo.conf
sudo initctl reload-configuration
sudo service start boco-library-demo
```

# Updating the deploy

```
cd /srv/www/boco-library-demo
git pull
npm install
sudo cp -f ./upstart.conf /etc/init/boco-library-demo.conf
sudo initctl reload boco-library-demo
sudo service boco-library-demo restart
```
