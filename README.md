# Jupyter Terraform

Jupyter Terraform allows you to deploy a JupyterLab Instance on AWS.

Use Cases: 
* Leveraging [compute](https://aws.amazon.com/ec2/instance-types/) larger then your local machine within the comfort of Juptyer Notebooks
* If you have large datasets already stored in AWS like S3, Glue etc then running compute tasks on the EC2 instance within the same trregion reduces latency resulting in faster processing / developer feedback cycle.

## Usage

### Creating Infrastructure

```terraform
module "jupyter" {
  source = "github.com/kiran94/terraform-jupyter"

  aws_region         = "eu-west-2"
  availability_zone  = "eu-west-2b"
  instance_type      = "t2.micro"
  ebs_volume_size_gb = 8
  service            = "jupyter"
}

output "conn" {
    value = module.jupyter.conn
}
```

Then run:

```bash
terraform init

terraform plan

terraform apply

# Once you are done using the instance remember to call:
# terraform destroy
```

### Connecting to the Instance

```bash
terraform output --raw conn
```

This will output a `ssh` command to run.

> [!IMPORTANT]  
> When the EC2 is first created, even though you can log in, the dependencies may still be installing. You can monitor progress by runnning `tail -f ~/terraform.log` when it says "DONE" then you should be good. If you had the same ssh session open I recommend you call `source ~/.bashrc` when it says "DONE" or just re-login.

### Launching Jupyter

```bash
jupyter lab
```

When you run this you will see an output that looks like this:

```bash
[C 2024-07-13 06:35:14.035 ServerApp]

    To access the server, open this file in a browser:
        file:///home/ec2-user/.local/share/jupyter/runtime/jpserver-3578-open.html
    Or copy and paste one of these URLs:
        http://ec2-YOUR_EC2_IP.eu-west-2.compute.amazonaws.com:8888/lab?token=YOUR_TOKEN
```

Copy and paste the `http` URL in your browser 🚀

<details>

<summary>Running in Tmux (Click Me)</summary>

`tmux` comes pre-installed so if you want the jupyter instance to be up irrespective of your `ssh` connection then you can run: 

```bash
tmux

jupyter lab
```

Press `Ctrl+b d` to detach from the `tmux` session. The jupyter process will still be running. You can safely disconnect from the box. When you want to stop the process then just run `tmux a` to get back into the session and `Ctrl+c` to cancel the process.

</details>

### Using a Different Version of Python

The EC2 ships with `pyenv` so you can easily switch to any python you need.

```bash
# See the list of python versions available
pyenv install --list 

# Install Python 3.9
pyenv install 3.9

# Switch to that version
pyenv local 3.9

# Confirm it's switched
python --version

# Create and Source virtual environment
python -m venv .venv
source .venv/bin/activate

# Install Dependencies
python -m pip install urllib3==1.26.6
python -m pip install jupyterlab

# Launch
python -m jupyter lab
```
