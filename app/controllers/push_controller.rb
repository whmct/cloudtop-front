class PushController < ApplicationController
	def create
		obj = JASON.parse(request.body.read)
		message = obj[:data]

		send_push_to_miltiple_device message
	end

	def send_push_to_multiple_device message
		@db = MongoClient.new('50.17.233.96', 27017)
		devices = @db[:devices]

		apns = get_APNS

		devices.find().to_a.each do |device|
			send_push_to_device apns, device[:token], message
		end

	end

	def  send_push_to_device APNS_client, deviceToken, message
		APNS_client.send_notification(deviceToken, message)
	end

	def get_APNS
		APNS.host = 'gateway.sandbox.push.apple.com' 
		# gateway.sandbox.push.apple.com is default

		APNS.port = 2195 

		APNS.pem  = '/path/to/pem/file'

		APNS.pass = ''
	end

end
