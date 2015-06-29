QpidEmitter = require '../'

describe "QPID Event Emitter", ->
	it "should send and receive data", (done) ->
		sender = new QpidEmitter name: 'sender'
		receiver = new QpidEmitter name: 'receiver'
		receiver.on 'test1', (data) -> done()
		sender.emit 'test1', 'hello world'

	it 'should send and receive multiple data events', (done) ->
		sender = new QpidEmitter name: 'sender'
		receiver = new QpidEmitter name: 'receiver'
		
		numReceived = 0
		receiver.on 'test2', (data) -> 
			numReceived += 1
			if numReceived == 3
				done()

		sender.emit 'test2', 'hello world'
		sender.emit 'test2', 'hello world'
		sender.emit 'test2', 'hello world'

	it 'should receive messages back and forth', (done) ->
		sender = new QpidEmitter name: 'sender'
		receiver = new QpidEmitter name: 'receiver'
		receiver.on 'test3', (data) ->
			sender.on 'test4', (data4) ->
				done()
			receiver.emit 'test4', 'second hello world'
		sender.emit 'test3', 'hello world'

	it 'should receive messages in order', (done) ->
		sender = new QpidEmitter name: 'sender'
		receiver = new QpidEmitter name: 'receiver'
		
		dataReceived = []
		receiver.on 'test5', (data) -> 
			dataReceived.push data
			if dataReceived.length == 3
				if dataReceived[0] == 'first' and dataReceived[1] == 'second' and dataReceived[2] == 'third'
					done()
				else
					done('Data received in the wrong order')

		sender.emit 'test5', 'first'
		sender.emit 'test5', 'second'
		sender.emit 'test5', 'third'

	it 'should namespace messages appropriately', (done) ->
		sender = new QpidEmitter name: 'sender', channel: 'awesome/namespace'
		onChannel = new QpidEmitter name: 'onChannel', channel: 'awesome/namespace'
		offChannel = new QpidEmitter name: 'offChannel', channel: 'other/namespace'
		noChannel = new QpidEmitter name: 'noChannel'

		eventName = 'test6'

		onChannel.on eventName, (data) -> done()
		offChannel.on eventName, (data) -> done "Off channel receiver got data"
		noChannel.on eventName, (data) -> done "No channel receiver got data"
		sender.emit eventName, 'lol'