#!/bin/sh

#rsync --chmod=Da+rwx,Fu+rw,g+rw,o+rw -av --exclude-from=exclude_upload --delete . peke2@192.168.1.48:/var/www/htdocs/peke2/project/cake/memo

rsync --chmod=Da+rwx,Fu+rw,g+rw,o+rw -avv -e 'ssh -i /home/peke2/.ssh/id_rsa_local_mysql' --exclude-from=exclude_upload --delete . peke2@192.168.56.102:/home/peke2/develop/ruby/test_http
