CREATE USER 'people'@'%' IDENTIFIED BY 'mariadb';

CREATE DATABASE accred;
GRANT ALL PRIVILEGES ON accred.* TO 'people'@'%';

CREATE DATABASE cadi;
GRANT ALL PRIVILEGES ON cadi.* TO 'people'@'%';

CREATE DATABASE cv;
GRANT ALL PRIVILEGES ON cv.* TO 'people'@'%';

CREATE DATABASE dinfo;
GRANT ALL PRIVILEGES ON dinfo.* TO 'people'@'%';
