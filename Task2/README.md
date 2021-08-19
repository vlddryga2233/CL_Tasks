# **Task 2**

 Structure of project:

 - [main.tf](./main.tf)                
 - [variables.tf](./variables.tf)
 - [files](./files/)
 - [modules](.modules/)
   - [bucket](./modules/bucket/main.tf)
   - [external_http_lb](./modules/external_http_lb/main.tf)
   - [backend_instance_group](./modules/instance_group/main.tf)
   - [internal_http_lb](./modules/internal_http_lb/main.tf)


**1.** **Export logs to BiqQuery**

- To export logs from Nginx VM, we need to install the agent and set up the configuration to send logs to the BigQuery dataset. But we need to automate the installation and configuration because we are using autoscaling. So we just use a script to install on each virtual machine.
```
sudo curl -L https://toolbelt.treasuredata.com/sh/install-debian-buster-td-agent4.sh  | sh
sudo usermod -aG adm td-agent
sudo /usr/sbin/td-agent-gem install fluent-plugin-bigquery
sudo gsutil cp gs://backend-storage-44/td-agent.conf /etc/td-agent/td-agent.conf
sudo systemctl restart td-agent
```

**2.** **Changing backend OS**

- We can't change OS without terminated VM because our MIG based on instance template. If we need to change so we destroy infrastrature with `terraform destroy` After that we need to change source code
```
module "tomcat_group" {

  # We need replace ubuntu image on centos
  source_image         = "ubuntu-2004-lts"  =>  source_image = "centos-8"
  # We need replace startup script to install soft
  startup_script = file("files\\tomcat.sh") =>  startup_script = file("files\\tomcat-c.sh")
}
```

 - When we execute `terraform apply` so we will get new instances with a new OS

**3.** **Health check on 20x status code**

 - For this we just need to apply the http health check
```
resource "google_compute_region_health_check" "default" {
  provider = google-beta

  region = var.region
  name   = "website-hc"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}
```



# **Task 3**

**1. Create a function that will be output message and trigger by pub/sub**

 First we need create Pub/Sub topic that will be push messages.
 After that we create a function (choose Pub/Sub trigger and pyhton3.8 runtime)

```
import base64

def hello_pubsub(event, context):

    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(pubsub_message)

```

We can publish message in Pub/Sub to execute function


**2. scheduling**


In this task we can use `Cloud scheduler`. It is a service similar to cron.
We just choose our topic and setup `0 * * * *` to trigger function every hour

```
Function     <=       Pub/Sub       <=        Scheduler
          triggered              run every hour
```

**3. Nginx logs 404 errors**

For this task we need to create a pub/sub and sink for logs that will be monitor for logs and trigger every time when we get 404 status errors.


```
resource.type="gce_instance"
log_name="projects/sage-outrider-322609/logs/nginx-access"
textPayload =~ "404"
```

The source code of our function

```
import base64

def hello_pubsub(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(pubsub_message)

```


The output of functions

```
{
  "textPayload": "89.185.11.88 - - [17/Aug/2021:13:58:21 +0000] \"GET /4543 HTTP/1.1\" 404 199
  \"-\"  \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)
  Chrome/92.0.4515.131 Safari/537.36\"",
  "insertId": "zrdfw32nvftmjmvdj",
  "resource": {
    "type": "gce_instance",
    "labels": {
      "project_id": "sage-outrider-322609",
      "instance_id": "6826628702327406644",
      "zone": "us-west4-b"
    }
  },
  "timestamp": "2021-08-17T13:58:21.996954598Z",
  "logName": "projects/sage-outrider-322609/logs/nginx-access",
  "receiveTimestamp": "2021-08-17T13:58:27.134460431Z"
}
```
