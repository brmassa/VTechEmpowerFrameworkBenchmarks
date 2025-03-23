module main

import veb
import json

pub struct User {
pub mut:
    name string
    id   int
}

// Our context struct must embed `veb.Context`!
pub struct Context {
    veb.Context
pub mut:
    // In the context struct we store data that could be different
    // for each request. Like a User struct or a session id
    user       User
    session_id string
}

pub struct App {
pub:
    // In the app struct we store data that should be accessible by all endpoints.
    // For example, a database or configuration values.
    secret_key string
}

pub fn (app &App) index(mut ctx Context) veb.Result {
    return ctx.html('<h1>Welcome to V lang example web server for <i>Web Framework Benchmarks</i></h1><p>Current configuration: v 0.4.10, ved server, postgres</p><ul><li><a href="/json">/json</a></li><li><a href="/plaintext">/plaintext</a></li></ul>')
}

pub fn (app &App) json(mut ctx Context) veb.Result {
    data := json.encode({"message": "Hello, World!"})
    return ctx.json(data)
}

pub fn (app &App) plaintext(mut ctx Context) veb.Result {
    return ctx.text('Hello, World!')
}

fn main() {
    mut app := &App{
        secret_key: 'secret'
    }
    // Pass the App and context type and start the web server on port 8080
    veb.run[App, Context](mut app, 8080)
}
