# V lang example web server

Server "competition" *Web Framework Benchmarks*: https://www.techempower.com/benchmarks

It designed to demonstrate how to use Ved's built-in features to create a web application.

## Scenarios

We created some scenarios. One on each folder. All scenarios use Ved server, the <a href="https://vlang.io">V</a> lang built-in web framework.

### Ved with Postgres (ved-pg/)

```
v run ved-pg/
```

### Ved with Postgres and ORM (ved-pg-orm/) (TBD)

```
v run ved-pg-orm/
```

### Ved with MySQL/MariaDB (ved-my/) (TBD)

```
v run ved-my/
```

### Ved with MySQL/MariaDB and ORM (ved-my-orm/) (TBD)

```
v run ved-my-orm/
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
