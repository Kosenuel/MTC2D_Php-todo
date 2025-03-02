CREATE DATABASE todos;
CREATE USER 'todouser'@'%' IDENTIFIED BY 'devopsacts';
GRANT ALL PRIVILEGES ON todos.* TO 'todouser'@'%';
FLUSH PRIVILEGES;
