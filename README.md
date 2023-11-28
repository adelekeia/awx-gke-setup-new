# AWX Setup On GKE

This terraform code will create a GKE cluster, deploy the latest version of AWX, expose the service through a load balancer and share the connection details and user credentials.

To run it:

* Set the project name 
    ```
    export TF_VAR_project=PROJECT_NAME
    ```

* Set the GKE cluster region 
    ```
    export TF_VAR_region=us-central1
    ```

* Set the GKE cluster zone
    ```
    export TF_VAR_zone=us-central1-a
    ```

* Provide Access Token 
    ```
    export TF_VAR_access_token=$(gcloud auth print-access-token)
    ```

* Switch to cluster directory and initialize terraform    
    ```
    cd cluster && terraform init
    ```

* Run terraform and apply changes
    ```
    terraform apply -auto-approve
    ```

After the cluster is create and AWX installed, terraform should output the connection details and user credentials. The URL might not be available right away so you might have to wait a few minutes for the login page to come up for the first time.