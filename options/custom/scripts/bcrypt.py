#! /usr/bin/env python

# Generate bcrypt hash

import bcrypt

print(bcrypt.hashpw(input("Password: ").encode(), bcrypt.gensalt()).decode())
