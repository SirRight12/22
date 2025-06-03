extends Object
class_name Packet
var event = 'message'
var message = ''

func to_dict():
	return {
		'event': event,
		'message': message,
	}
func stringify():
	return JSON.stringify(self.to_dict())
