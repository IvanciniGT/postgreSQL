#!/bin/bash
yum install postgresql-server


postgresql-setup --initdb
systemctl enable postgresql.service
systemctl start postgresql.service
