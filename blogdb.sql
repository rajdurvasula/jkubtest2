create database blog_db;
create user 'appuser’@‘%’ identified by 'ek470oJ05dj057465137lh00';
grant all privileges on blog_db.* to 'appuser'@'%' identified by 'ek470oJ05dj057465137lh00';
flush privileges;