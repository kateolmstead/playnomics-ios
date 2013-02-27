from apns import APNs, Payload, PayloadAlert

apns = APNs(use_sandbox=False, cert_file='PushProofCert.pem', key_file='PushProofKey.pem')

# Send a notification
# This is the token we receive from app delegate, without spaces
# token_hex = '<4a799720 91a77ade 402537c9 9d72c56f 2ab05f80 a986a05c 455119c5 3043fa2f>'
token_hex = '<c2190e93 08502e96 e50ade71 e8d02110 435f031d 72c10fef 25686bfd 8faac278>'
# remove any spaces, should we have some
token_hex = token_hex.replace(" ","")
# remove any open/close carrots , which are typical of apple device tokens
token_hex = token_hex.replace("<","")
token_hex = token_hex.replace(">","")

#payload = Payload(alert="Hello World!", sound="default", badge=1)

alert = PayloadAlert("Why are you ignoring me?", action_loc_key="example_lock_key")
payload = Payload(alert=alert, sound="dingdong.caf", custom={'push_id':"555","push_message":"I am a custom push notification."})

apns.gateway_server.send_notification(token_hex, payload)