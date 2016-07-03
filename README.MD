# Using ironSource.atom with Elastic Filebeat, Logstash & Docker Compose
[![License][license-image]][license-url]

Atom-filebeat is the way to connect filebeat with ironSource.atom, stand alone or with a Docker container.

- [Signup](https://atom.ironsrc.com/#/signup)
- [Documentation](https://github.com/ironSource/atom-beats)
- [Example][example-url]

### Send an event to ironSource.Atom using Filebeat & Logstash

```yaml
############################# Filebeat ######################################
filebeat:
  # List of prospectors to fetch data.
  prospectors:
    # Each - is a prospector. Below are the prospector specific configurations
    # for more info: https://github.com/elastic/filebeat/blob/master/etc/filebeat.yml
    -
      paths:
        # path to log file on your host
        - /var/log/*.log
      input_type: log
     
############################# Output ##########################################

# Configure what outputs to use when sending the data collected by the beat.
# Multiple outputs may be used.
output:
  ### Logstash as output
  logstash:
    # Logstah on localhost
    hosts: ["localhost:5044"]
```

__2. Create a file named logstash.conf with following configuration:__
```html
# An input plugin enables a specific source of events to be read by Logstash.
input {
    beats {
        port => 5044
        ssl => false
    }
}
# filter plugin
filter {  
    fingerprint {
        key => "${AUTH}" #pre-shared auth key from your Atom stream
        method => "SHA256" 
     }
  }

# output plugin
output {
    stdout{}
    http {
        url => "http://track.atom-data.io/bulk"
        headers => {
            "x-ironsource-atom-sdk-type" => "logstash+beats"
            "x-ironsource-atom-sdk-version" => "${SDK_VERSION:1.0.0}"
        }
        http_method => "post"
        format => "json"
        mapping => {
            "table" => "${STREAM}"
            "data" => "%{message}"
            "auth" => "%{fingerprint}"
            "bulk" => "true"
        }
        workers => 5
        ssl_certificate_validation => false
    }
}
```

__3. Run logstash__
```bash
STREAM=<the name of your stream> AUTH=<your pre shared auth key> logstash --allow-env -f logstash.conf
```
__4. Run filebeat__
```bash
cd <directory with filebeat>
sudo ./filebeat -e -c <absolute path to directory with filebeat.yaml>
```

### Send events to ironSource.Atom using Filebeat, Logstash, docker container & docker-compose
__1. Create filebeat.yml with the following content:__
```yaml
############################# Filebeat ######################################
filebeat:
  # List of prospectors to fetch data.
  prospectors:
    # Each - is a prospector. Below are the prospector specific configurations
    -
      paths:
        - /var/log/*.log
        #- c:\programdata\elasticsearch\logs\*
      input_type: log
     
############################# Output ##########################################

# Configure what outputs to use when sending the data collected by the beat.
# Multiple outputs may be used.
output:
  ### Logstash as output
  logstash:
    # The Logstash hosts
    hosts: ["logstash:5044"]
```
__2. Create docker-compose.yml with the following content:__
```yaml
version: '2'
services:
  logstash:
    image: logstash:2.3.1
    container_name: logstash
    command: bash -c "logstash --allow-env -f /etc/logstash/conf.d/logstash.conf"
    environment:
      STREAM: ${STREAM} # Your Atom Stream
      AUTH: ${AUTH} # Your pre-shared key to Atom Stream
      SDK_VERSION: 1.0.0
    volumes:
    # Specify the logstash.conf file path on your host
    - <Absolute path to your logstash.conf file>:/etc/logstash/conf.d/logstash.conf
    # For more options: https://docs.docker.com/compose/compose-file/#volumes-volume-driver
  filebeat:
    image: prima/filebeat:1.2.3
    depends_on:
    - logstash
    container_name: filebeat
    volumes:
    #Specify the logstash.conf file path on your host
    - <absolute path to your filebeat.yml file>:/filebeat.yml

    #Specify the path of the log files that you want filebeat to use
    - <absolute path to your log file(s)>:/var/log/log-from-host 
```

__3. Run docker-compose:__
```bash
STREAM=<the name of your stream> AUTH=<your pre shared auth key> docker-compose up (-d for detached)

OR

export STREAM=<the name of your stream>
export AUTH=<your pre shared auth key> 
docker-compose up -d
```
### Example

You can use our [example][example-url] for sending data to Atom.

### License
[MIT](https://github.com/ironSource/atom-beats/blob/master/LICENSE)

[license-image]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-url]: LICENSE
[example-url]: https://github.com/ironSource/atom-beats/tree/master/example