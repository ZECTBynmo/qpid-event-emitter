proton = require('qpid-proton-messenger')
{EventEmitter} = require 'events'

DEBUG = false
log = -> if DEBUG then console.log arguments...


class Receiver extends EventEmitter

  constructor: (@options={}) ->
    @name = @options.name || 'receiver'
    @address = @options.address || 'amqp://~0.0.0.0'
    @message = new proton.Message
    
    log @name, @address

    @messenger = new proton.Messenger

    @messenger.setIncomingWindow 1024
    @messenger.on 'error', (error) =>
      log "ERROR", @name, error
      return
    @messenger.on 'work', @pumpData
    @messenger.recv()
    @messenger.start()

    @subscription = @messenger.subscribe @address
    log @name, "SUBSCRIPTION", @subscription

  pumpData: =>
    log @name, "BEFORE"
    while @messenger.incoming()
      log @name, "INCOMING"
      transmission = @messenger.get @message
      log @name, 'Address: ' + @message.getAddress()
      log @name, 'Subject: ' + @message.getSubject()
      log @name, 'Content: ' + @message.data.format()
      log @name, 'Body: ' + @message.body
      @emit 'data',
        subject: @message.getSubject()
        data: @message.body
      @messenger.accept transmission


class Sender extends EventEmitter

  constructor: (@options={}) ->
    @name = @options.name || 'sender'
    @tracker = null
    @address = @options.address || 'amqp://0.0.0.0'
    @message = new proton.Message
    
    @messenger = new proton.Messenger
    @messenger.on 'error', (error) -> log error
    @messenger.on 'work', @pumpData
    @messenger.setOutgoingWindow 1024
    @messenger.start()
    
    @message.setAddress @address

  send: (subject, msgtext) =>
    @message.setSubject subject
    @message.body = msgtext
    log @name, "PUT", @message
    @tracker = @messenger.put @message

  pumpData: =>
    status = @messenger.status @tracker
    if status != proton.Status.PENDING
      if running
        @messenger.stop()
        running = false
    if @messenger.isStopped()
      @message.free()
      @messenger.free()


class QpidEventEmitter extends EventEmitter

  receiver: new Receiver()

  constructor: (@options={}) ->
    @name = @options.name || 'emitter'
    @sender = new Sender name: @name
    #@receiver = new Receiver name: @options.name

    @receiver.on 'data', (data) =>
      log @name, "GOT MESSAGE", data
      @emit data.subject, data.data, false

  emit: (event, data, broadcast=true) =>
    if broadcast
      @sender.send event, data
    else
      super arguments...


module.exports = QpidEventEmitter
