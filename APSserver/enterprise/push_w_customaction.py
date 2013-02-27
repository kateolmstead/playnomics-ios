from apns import APNs, Payload, PayloadAlert

apns = APNs(use_sandbox=True, cert_file='PushProofCert.pem', key_file='PushProofKey.pem')

# Send a notification
# This is the token we receive from app delegate, without spaces
token_hex = '<f2529242 a6bbecf2 6c1f0893 62bdeb96 99d503c5 1faa7cde fecdd5b1 51c1cdf7>'
# remove any spaces, should we have some
token_hex = token_hex.replace(" ","")
# remove any open/close carrots , which are typical of apple device tokens
token_hex = token_hex.replace("<","")
token_hex = token_hex.replace(">","")

#payload = Payload(alert="Hello World!", sound="default", badge=1)

alert = PayloadAlert("This message will have a custom action!", action_loc_key="example_lock_key")
payload = Payload(alert=alert, sound="default", custom={'push_id':123,"push_action":"url:http://www.google.com","push_message":"hola"})

apns.gateway_server.send_notification(token_hex, payload)