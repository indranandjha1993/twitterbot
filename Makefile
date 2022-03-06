INSTANCE:="twitterbot"
ZONE:="us-central1-f"
USER:="indra"

twitterbot:
	GOOS=linux go build -o twitterbot

clean:
	rm -f twitterbot

instance:
	gcloud compute instances describe --zone $(ZONE) $(INSTANCE) &> /dev/null || \
	gcloud compute instances create $(INSTANCE) \
		--zone $(ZONE) --machine-type "f1-micro" \
		--image "debian-8-jessie-v20170523" --image-project "debian-cloud";

deploy: instance twitterbot
	gcloud compute scp --zone $(ZONE) twitterbot twitterbot.service $(USER)@$(INSTANCE):~
	gcloud compute ssh --zone $(ZONE) $(USER)@$(INSTANCE) --command \
		"sudo mv ~/twitterbot.service /etc/systemd/system/"
	gcloud compute ssh --zone $(ZONE) $(USER)@$(INSTANCE) --command \
		"sudo systemctl enable twitterbot && sudo systemctl start twitterbot"