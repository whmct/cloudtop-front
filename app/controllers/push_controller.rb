require 'pushmeup'
require 'Houston'

include Mongo
include BSON

class PushController < ApplicationController
	skip_before_action :verify_authenticity_token

	@@pushDataTemplate = "{
	    \"aps\" : {
	        \"alert\" : \"New message.\"
	    },
	    \"data\" : {
	    	\"from\" : \"\",
	    	\"payloadId\" : \"\"
	    }
	}"

	def create
		# input
		#{
		#	"from": "Meng Hu",
		#	"to": "Xi Yang",
		#	"payloadId": "data10"
		#}

		#output
		#{
		#    "aps" : {
		#        "alert" : "New message."
		#    },
		#    "data" : {
		#    	"from" : "Meng Hu",
		#    	"payload" : "data10"
		#    }
		#}		
		
		pushMessageSource = JSON.parse(request.body.read)

		from = pushMessageSource["from"]
		to = pushMessageSource["to"]
		payloadId = pushMessageSource["payloadId"]
		
		@db = MongoClient.new('50.17.233.96', 27017).db('test')

		userData = @db['user'].find_one("userId" => to)
		
		deviceToken = userData["deviceToken"]

		pushData = JSON.parse(@@pushDataTemplate)
		pushData['data']['from'] = from
		pushData['data']['payloadId'] = payloadId

		send_push_to_device deviceToken, pushData

		render json: {message: "successfully pushed!"}
	end

	def  send_push_to_device deviceToken, message
		#APNS.send_notification(deviceToken, message)
		apn = Houston::Client.development
		apn.certificate = File.read("./tmp/cert-no-ps.pem")

		# An example of the token sent back when a device registers for notifications
		#token = "<e7a5769b f84d9f03 6ee4e25d 79c88a44 3e8e1ccf c3c92c7c 11d43335 71833874>"

		# Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
		notification = Houston::Notification.new(device: deviceToken)
		notification.alert = message
		# Notifications can also change the badge count, have a custom sound, indicate available Newsstand content, or pass along arbitrary data.
		#notification.badge = 57
		#notification.sound = "sosumi.aiff"
		#notification.content_available = true
		#notification.custom_data = {foo: "bar"}

		# And... sent! That's all it takes.
		apn.push(notification)		
	end

	def init_APNS
		APNS.host = 'gateway.sandbox.push.apple.com' 
		# gateway.sandbox.push.apple.com is default

		APNS.port = 2195 

		APNS.pem  = './tmp/cert-no-ps.pem'

		APNS.pass = ''
	end

end
