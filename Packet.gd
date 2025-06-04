extends Object
class_name Packet
var event = 'message'
var message = ''

func to_dict():
	return {
		'event': event,
		'message': message,
	}
##Convert packet to a string to be sent to the server
func stringify():
	return JSON.stringify(self.to_dict())
static func from_string(string:String):
	var obj = JSON.parse_string(string)
	var packet = Packet.new()
	packet.event = obj['event']
	packet.message = obj['message']
	return packet
