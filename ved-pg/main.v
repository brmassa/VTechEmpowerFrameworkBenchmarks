module main

import db.pg
import json
import rand
import time
import veb

struct World {
	id            int @[primary; sql: serial]
	random_number int @[sql: 'randomNumber']
}

pub struct Context {
	veb.Context
}

pub struct App {
pub:
	secret_key string
pub mut:
	db pg.DB
}

fn main() {
	mut app := &App{
		secret_key: 'secret'
	}

	app.db = pg.connect(pg.Config{
		host:     'localhost'
		port:     5432
		user:     'postgres'
		password: 'mysecretpassword'
		dbname:   'web_framework_benchmarks'
	}) or { panic(err) }
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

    <h2>Setup</h2>
    <ul>
    <li><a href="/setup_db">Database setup</a></li>
    </ul>

    <h2>Benchmark Tests</h2>
    <ul>
      <li><a href="/json">JSON serialization</a></li>
      <li><a href="/db">Single query</a></li>
      <li><a href="/queries">Multiple queries</a></li>
      <li><a href="/queries">Cached queries</a></li>
      <li><a href="/fortunes">Fortunes</a></li>
      <li><a href="/updates">Data updates</a></li>
      <li><a href="/plaintext">Plaintext</a></li>
    </ul>
    ')
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
	mut id := rand.int_in_range(1, 10001) or { panic(err) }

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
	ctx.set_header(.server, 'V Veb server')
	ctx.set_header(.date, time.now().utc_string())
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

	for i in 0 .. 10000 {
		random_number := rand.int_in_range(1, 10001) or {
			return ctx.server_error('Random number generation failed')
		}
		app.db.exec('INSERT INTO World (randomNumber) VALUES (${random_number})') or {
			return ctx.server_error('Failed to insert row ${i + 1}')
		}
	}

	set_header(mut ctx, 'text/plain')
	return ctx.text('DB reset and filled with 10000 rows')
}
