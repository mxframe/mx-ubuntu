#!/bin/bash

sudo rm -rf /var/www/html
cd /var/www/html

git clone http://gitlab.tkw-partner.de/spectrum8/magenta-eins-valentine-backend.git
git clone http://gitlab.tkw-partner.de/spectrum8/magenta-eins-valentine-frontend.git
git clonehttp://gitlab.tkw-partner.de/German/vf_connect_lp.git

cd /var/www/html/magenta-eins-valentine-backend
cp /usr/local/packages/mx-ubuntu/tmp/backend.env /var/www/html/magenta-eins-valentine-backend/.env
composer install
php artisan key:generate

cd /var/www/html/magenta-eins-valentine-frontend
cp /usr/local/packages/mx-ubuntu/tmp/frontend.env /var/www/html/magenta-eins-valentine-frontend/.env
npm install
npm run generate