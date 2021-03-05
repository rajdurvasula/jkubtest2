drop database if exists blog_db;
create database blog_db;
create user 'appuser'@'localhost' identified by 'ek470oJ05dj057465137lh00';
create user 'appuser'@'%' identified by 'ek470oJ05dj057465137lh00';
grant all privileges on blog_db.* to 'appuser'@'%';
grant all privileges on blog_db.* to 'appuser'@'localhost';
flush privileges;
