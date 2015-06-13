# Qpid EventEmitter

EventEmitter abstraction on top of AMQP10, interfacing with the Qpid C++ broker via the [offical Apache node.js module](https://git-wip-us.apache.org/repos/asf?p=qpid-proton.git;a=tree;f=examples/javascript/messenger;hb=HEAD) (their C++ binding compiled to JS with Emscripten).

## Installation 

```
npm install qpid-event-emitter
```

## Usage

```
QpidEmitter = require 'qpid-event-emitter'

opts =
	address: 'amqp://~0.0.0.0'
	channel: 'the/event/namespace'

emitter1 = new QpidEmitter opts
emitter2 = new QpidEmitter opts

emitter1.on 'second', (data) ->
	console.log data # logs 'world'

emitter2.on 'first', (data) ->
	console.log data # logs 'hello'

emitter1.emit 'first', 'hello'
emitter2.emit 'second', 'world'
```

## Tests
```
npm test
```