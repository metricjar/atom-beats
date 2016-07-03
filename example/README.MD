### To run this example:
```bash
Note: make sure you have Logstash and Filebeat installed and added to PATH env variable.
git clone https://github.com/ironSource/atom-beats.git atom-beats
cd atom-beats/example
chmod +x startup.sh
STREAM=YOUR_STREAM_NAME AUTH=YOUR_PRE_SHARED_AUTH_KEY ./startup.sh
```