import os
import subprocess

def lambda_handler(event, context):
    repo = event["detail"]["repository-name"]
    image_tag = event["detail"]["image-tag"]

    repo_path_map = {
        "multi-frontend": "mychart/frontend/values.yaml",
        "multi-backend-users": "mychart/users/values.yaml",
        "multi-backend-boards": "mychart/boards/values.yaml"
    }

    if repo not in repo_path_map:
        print(f"Unknown repository: {repo}")
        return {"status": "ignored"}

    values_path = repo_path_map[repo]

    # 작업 디렉토리
    os.chdir("/tmp")
    subprocess.run(["git", "clone", os.environ["TERRAFORM_GIT"], "tf-dir"], check=True)
    os.chdir("tf-dir")

    # values.yaml 파일에서 tag 값 치환
    subprocess.run(["sed", "-i", f"s/tag:.*/tag: {image_tag}/", values_path], check=True)

    # Terraform apply
    subprocess.run(["terraform", "init"], check=True)
    subprocess.run(["terraform", "apply", "-auto-approve"], check=True)

    return {
        "statusCode": 200,
        "body": f"Deployed {repo} with tag {image_tag}"
    }