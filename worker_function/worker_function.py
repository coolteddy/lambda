import boto3
import paramiko
def worker_handler(event, context):

    s3_client = boto3.client('s3')
    #Download private key file from secure S3 bucket
    s3_client.download_file('thetotherbucket','homework.pem', '/tmp/homework.pem')

    k = paramiko.RSAKey.from_private_key_file("/tmp/homework.pem")
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    host=event['IP']
    print("Connecting to: " + str(host))
    c.connect( hostname = host, username = "ec2-user", pkey = k )
    print("Connected to: " + str(host))
    commands = [
        "aws s3 cp s3://thetotherbucket/install_mono.sh /home/ec2-user/install_mono.sh",
        "chmod 700 /home/ec2-user/install_mono.sh",
        "/home/ec2-user/install_mono.sh"
        ]
    print("After commands")
    for command in commands:
        print("Executing" + str(command))
        stdin , stdout, stderr = c.exec_command(command)
        print(stdout.read())
        print(stderr.read())

    return
    {
        'message' : "Script execution completed. See Cloudwatch logs for complete output"
    }
