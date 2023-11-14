docker exec -it node1 mysql -uroot -pmypass \
  -e "CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypass';" \
  -e "CREATE USER 'myuser'@'%' IDENTIFIED BY 'mypass';" \
  -e "GRANT ALL ON *.* TO 'myuser'@'localhost';" \
  -e "GRANT ALL ON *.* TO 'myuser'@'%';" \
  -e "FLUSH PRIVILEGES;"

docker exec -it node1 mysql -uroot -pmypass \
  -e "CREATE DATABASE test;"

docker exec -it node1 mysql -uroot -pmypass \
  -e "SET @@GLOBAL.group_replication_bootstrap_group=1;" \
  -e "create user 'repl'@'%';" \
  -e "GRANT REPLICATION SLAVE ON *.* TO repl@'%';" \
  -e "flush privileges;" \
  -e "change master to master_user='repl' for channel 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;" \
  -e "SET @@GLOBAL.group_replication_bootstrap_group=0;" \
  -e "SELECT * FROM performance_schema.replication_group_members;"

for N in 2 3
do docker exec -it node$N mysql -uroot -pmypass \
  -e "change master to master_user='repl' for channel 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;"
done
