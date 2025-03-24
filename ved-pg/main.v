module main

import arrays
import db.pg
import json
import rand
import time
import veb

struct World {
	id int @[primary; sql: serial]
mut:
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
	return $veb.html()
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
	world := get_world(app, id)

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
	queries := get_query(ctx)

	mut worlds := []World{}
	for _ in 0 .. queries {
		id := rand.int_in_range(1, 10001) or { panic(err) }
		world := get_world(app, id)
		worlds << world
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(worlds))
}

@[inline]
fn get_world(app &App, id int) World {
	world_map := app.db.exec_one('SELECT id, randomNumber FROM World WHERE id = ${id}') or {
		return World{}
	}

	id_ := world_map.vals[0]
	random_number_ := world_map.vals[1]

	world := World{
		id:            id_ or { '' }.int()
		random_number: random_number_ or { '' }.int()
	}

	return world
}

@[inline]
fn get_query(ctx Context) int {
	mut queries := ctx.query['queries'].int()
	return if queries < 1 {
		1
	} else if queries > 500 {
		500
	} else {
		queries
	}
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

pub fn (app &App) updates(mut ctx Context) veb.Result {
	queries := get_query(ctx)

	mut worlds := []World{}
	for _ in 0 .. queries {
		id := rand.int_in_range(1, 10001) or { panic(err) }
		world := get_world(app, id)
		worlds << world
	}

	for mut world in worlds {
		world.random_number = rand.int_in_range(1, 10001) or { panic(err) }
		app.db.exec_param2('UPDATE World SET randomNumber = $1 WHERE id = $2', world.random_number.str(),
			world.id.str()) or { return ctx.server_error('Database update failed') }
	}

	set_header(mut ctx, 'application/json')
	return ctx.json(json.encode(worlds))
}
