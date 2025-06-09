This ansible role is dedicated to configuring MongoDB. Variables and their defaults are as follows. 

```
mongo_user: mongo # User in the mongo database to connect as

mongo_password: mongo # Password of the above user

mongo_host: 127.0.0.1

mongo_port: 27017

mongo_passwords_shuffle: false # Shuffle all passwords on mongo and save a csv

mongo_localhost: 127.0.0.1
```

This role is UNTESTED because I could not find a working vagrant box for mongodb.