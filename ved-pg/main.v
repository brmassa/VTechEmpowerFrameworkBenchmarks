module main

import arrays
import db.pg
import json
import rand
import time
import veb

struct World {
	id            int @[primary; sql: serial]
	random_number int @[sql: 'randomNumber']
}

struct Fortune {
	id      int @[primary; sql: serial]
	message string
}

pub struct Context {
	veb.Context
}

@[heap]
pub struct App {
pub mut:
	db pg.DB
}

fn main() {
	mut app := &App{}

	app.db = pg.connect(pg.Config{
		host:     'localhost'
		port:     5432
		user:     'benchmarkdbuser'
		password: 'benchmarkdbpass'
		dbname:   'hello_world'
	})!
	// or { return ctx.server_error('Database connection failed') }
	defer {
		app.db.close()
	}

	veb.run[App, Context](mut app, 8080)
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.html('<h1><i>V</i> web server</h1>
	  <p>Welcome to <a href="https://vlang.io">V</a> lang example web server for <a href="https://www.techempower.com/benchmarks">Web Framework Benchmarks</a></p>

    <h2>Settings</h2>
    <ul>
      <li>v: 0.4.10</li>
      <li>Postgres (version is a user choice)</li>
      <li>Used V libraries and modules:
        <ul>
          <li><a href="https://modules.vlang.io/veb.html">ved</a>: web server and front-end</li>
          <li><a href="https://modules.vlang.io/db.pg.html">db.pg</a>: Postgres connector</li>
        </ul>
      </li>
    </ul>

    <h2>Local Setup</h2>
    <ul>
    <li><a href="/setup_db">Database setup</a></li>
    </ul>

    <h2>Benchmark Tests</h2>
    <ul>
      <li><a href="/json">JSON serialization</a></li>
      <li><a href="/db">Single query</a></li>
      <li><a href="/queries">Multiple queries</a>
      <ul>
        <li><a href="/queries?queries=1">Multiple queries 1</a></li>
        <li><a href="/queries?queries=5">Multiple queries 5</a></li>
        <li><a href="/queries?queries=10">Multiple queries 10</a></li>
        <li><a href="/queries?queries=15">Multiple queries 15</a></li>
        <li><a href="/queries?queries=20">Multiple queries 20</a></li>
        <li></li>
        <li><a href="/queries?queries=0">Multiple queries 0</a></li>
        <li><a href="/queries?queries=10">Multiple queries 10</a></li>
        <li><a href="/queries?queries=50">Multiple queries 50</a></li>
        <li><a href="/queries?queries=100">Multiple queries 100</a></li>
        <li><a href="/queries?queries=500">Multiple queries 500</a></li>
        <li><a href="/queries?queries=1000">Multiple queries 1000</a></li>
      </ul>
      </li>
      <li><a href="/queries">Cached queries</a></li>
      <li><a href="/fortunes">Fortunes</a></li>
      <li><a href="/updates">Data updates</a></li>
      <li><a href="/plaintext">Plaintext</a></li>
    </ul>
    ')
}

// Reset DB World table and fill with 10000 rows with random numbers from 1 to 10000
pub fn (app &App) setup_db(mut ctx Context) veb.Result {
	app.db.exec('DROP TABLE IF EXISTS World') or {
		return ctx.server_error('Failed to drop existing World table')
	}
	app.db.exec('CREATE TABLE World (
		id SERIAL PRIMARY KEY,
		randomNumber INT NOT NULL
	)') or {
		return ctx.server_error('Failed to create World table')
	}

	mut random_numbers := []int{}
	for _ in 0 .. 10000 {
		random_numbers << rand.int_in_range(1, 10001) or {
			return ctx.server_error('Random number generation failed')
		}
	}
	numbers := arrays.join_to_string(random_numbers, '),(', fn (it int) string {
		return it.str()
	})
	app.db.exec('INSERT INTO World (randomNumber) VALUES (${numbers})') or {
		return ctx.server_error('Failed to insert World values')
	}

	app.db.exec('DROP TABLE IF EXISTS Fortune') or {
		return ctx.server_error('Failed to drop existing Fortune table')
	}
	app.db.exec('CREATE TABLE Fortune (
		id SERIAL PRIMARY KEY,
		message VARCHAR NOT NULL
	)') or {
		return ctx.server_error('Failed to create Fortune table')
	}

	mut messages := []string{}
	messages << 'fortune: No such file or directory'
	messages << 'A computer scientist is someone who fixes things that arent broken.' // TODO: escape the arent
	messages << 'After enough decimal places, nobody gives a damn.'
	messages << 'A bad random number generator: 1, 1, 1, 1, 1, 4.33e+67, 1, 1, 1'
	messages << 'A computer program does what you tell it to do, not what you want it to do.'
	messages << 'Emacs is a nice operating system, but I prefer UNIX. — Tom Christaensen'
	messages << 'Any program that runs right is obsolete.'
	messages << 'A list is only as strong as its weakest link. — Donald Knuth'
	messages << 'Feature: A bug with seniority.'
	messages << 'Computers make very fast, very accurate mistakes.'
	messages << '<script>alert("This should not be displayed in a browser alert box.");</script>'
	messages << 'フレームワークのベンチマーク'
	message := arrays.join_to_string(messages, "'),('", fn (it string) string {
		return it
	})
	app.db.exec('INSERT INTO Fortune (message) VALUES (\'${message}\')') or {
		return ctx.server_error('Failed to insert Fortune messages')
	}

	set_header(mut ctx, 'text/plain')
	return ctx.text('DB reset and filled with 10000 rows')
}

pub fn (app &App) json(mut ctx Context) veb.Result {
	data := json.encode({
		'message': 'Hello, World!'
	})
	set_header(mut ctx, 'application/json')
	return ctx.json(data)
}

pub fn (app &App) plaintext(mut ctx Context) veb.Result {
	set_header(mut ctx, 'text/plain')
	return ctx.text('Hello, World!')
}

pub fn (app &App) db(mut ctx Context) veb.Result {
	id := rand.int_in_range(1, 10001) or { panic(err) }

	world_map := app.db.exec_one('SELECT id, randomNumber FROM World WHERE id = ${id}') or {
		return ctx.server_error('Database query failed for id = "${id}"')
	}

	id_ := world_map.vals[0]
	random_number_ := world_map.vals[1]

	world := World{
		id:            id_ or { '' }.int()
		random_number: random_number_ or { '' }.int()
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(world))
}

@[inline]
fn set_header(mut ctx Context, content_type string) {
	ctx.set_header(.content_type, content_type)
	ctx.set_header(.server, 'V Veb')
	ctx.set_header(.date, time.now().utc_string())
}

pub fn (app &App) queries(mut ctx Context) veb.Result {
	mut queries := ctx.query['queries'].int()
	queries = if queries < 1 {
		1
	} else if queries > 500 {
		500
	} else {
		queries
	}

	mut worlds := []World{}
	for _ in 0 .. queries {
		id := rand.int_in_range(1, 10001) or { panic(err) }

		world_map := app.db.exec_one('SELECT id, randomNumber FROM World WHERE id = ${id}') or {
			return ctx.server_error('Database query failed for id = "${id}"')
		}

		id_ := world_map.vals[0]
		random_number_ := world_map.vals[1]

		world := World{
			id:            id_ or { '' }.int()
			random_number: random_number_ or { '' }.int()
		}
		worlds << world
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(worlds))
}

pub fn (app &App) fortunes(mut ctx Context) veb.Result {
	fortunes_map := app.db.exec('SELECT id, message FROM fortune') or {
		return ctx.server_error('Database query failed')
	}

	mut fortunes := []Fortune{}
	for fortune in fortunes_map {
		id_ := fortune.vals[0]
		message_ := fortune.vals[1]

		fortunes << Fortune{
			id:      id_ or { '' }.int()
			message: message_ or { '' }
		}
	}

	fortunes << Fortune{
		id:      0
		message: 'Additional fortune added at request time.'
	}

	fortunes.sort_with_compare(fn (a &Fortune, b &Fortune) int {
		return a.message.compare(b.message)
	})

	set_header(mut ctx, 'text/html; charset=UTF-8')
	return $veb.html()
}
