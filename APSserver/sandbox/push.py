from apns import APNs, Payload, PayloadAlert

apns = APNs(use_sandbox=True, cert_file='com.playnomics.PlaynomicsSample.pem', key_file='com.playnomics.PlaynomicsSample.pem')

# Send a notification
# This is the token we receive from app delegate, without spaces
# token_hex = '<4a799720 91a77ade 402537c9 9d72c56f 2ab05f80 a986a05c 455119c5 3043fa2f>'
token_hex = '<55d55b60 71b53a37 12142d7a bf6cab49 beba06fb 6a3dcc41 f14c4ee1 036b3790>'
# remove any spaces, should we have some
token_hex = token_hex.replace(" ","")
# remove any open/close carrots , which are typical of apple device tokens
token_hex = token_hex.replace("<","")
token_hex = token_hex.replace(">","")

#payload = Payload(alert="Hello World!", sound="default", badge=1)

alert = PayloadAlert("Why are you ignoring me?", action_loc_key="example_lock_key")
payload = Payload(alert=alert, sound="dingdong.caf", custom={'push_id':"555","push_message":"I am a custom push notification."})

apns.gateway_server.send_notification(token_hex, payload)