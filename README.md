# V lang example web server

Server "competition" *Web Framework Benchmarks*: https://www.techempower.com/benchmarks

It designed to demonstrate how to use <a href="https://modules.vlang.io/veb.html">Veb</a>'s built-in features to create a web application.

> NOTE: Cache test still to be properly implemented

## Scenarios

We created some scenarios. One on each folder. All scenarios use **Veb** server, the <a href="https://vlang.io">V</a> lang built-in web framework.

### Veb with Postgres (veb-pg/)

```
v run veb-pg/
```

### Veb with Postgres and ORM (veb-pg-orm/) (TBD)

```
v run veb-pg-orm/
```

### Veb with MySQL/MariaDB (veb-my/) (TBD)

```
v run veb-my/
```

### Veb with MySQL/MariaDB and ORM (veb-my-orm/) (TBD)

```
v run veb-my-orm/
```

## Local Setup

in order to test the servers locally, you will need a database server and a database client. using container, you can use:

### Postgres:

```
docker run --name my-postgres \
  -e POSTGRES_USER=benchmarkdbuser \
  -e POSTGRES_PASSWORD=benchmarkdbpass \
  -e POSTGRES_DB=hello_world \
  -p 5432:5432 \
  -d postgres:latest
```

### MySQL/MariaDB:

```
docker run --name benckmark-mysql \
  -e MYSQL_ROOT_PASSWORD=benchmarkdbpass \
  -e MYSQL_USER=benchmarkdbuser \
  -e MYSQL_PASSWORD=benchmarkdbpass \
  -e MYSQL_DATABASE=hello_world \
  -p 3306:3306 \
  -d mysql:latest
```

```
docker run --name benckmark-maria \
  -e MARIADB_ROOT_PASSWORD=benchmarkdbpass \
  -e MARIADB_USER=benchmarkdbuser \
  -e MARIADB_PASSWORD=benchmarkdbpass \
  -e MARIADB_DATABASE=hello_world \
  -p 3306:3306 \
  -d mariadb:latest
```

---

Created by Bruno Massa
