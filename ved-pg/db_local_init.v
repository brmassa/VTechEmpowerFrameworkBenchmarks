module main

import arrays
import json
import veb
import rand

// Reset DB World table and fill with 10000 rows with random numbers from 1 to 10000
pub fn (app &App) db_init(mut ctx Context) veb.Result {
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
