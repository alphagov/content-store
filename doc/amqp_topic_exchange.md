## Publishing messages on an AMQP topic exchange

After every update to a content item, a message will be published to RabbitMQ.
It will be published to the `published_documents` topic exchange with the routing_key
`format.update_type`.  Additional components will likely be added to this over
time, but they will be added to the end of the key so as to not break any
existing bindings.

The message body will be the content item serialised as JSON in the
[output_format](output_examples/generic.json) with the addition of the `update_type` field.
