provider "google" {
  access_token = var.access_token
  project     = var.project
  region      = var.region
}

resource "google_container_cluster" "awx_cluster" {
  name     = var.cluster_name
  location = var.region
  initial_node_count = 1

  node_config {
    machine_type = "n1-standard-1"    #"n1-standard-8" #"n1-standard-1"
    disk_type    = "pd-ssd"
    disk_size_gb = "20"
    image_type = "UBUNTU_CONTAINERD"
    tags = ["http-server", "https-server"]
  }

  deletion_protection = false
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "gke_${var.project}_${var.region}_${var.cluster_name}"
}

resource "null_resource" "helm_install" {

  depends_on = [google_container_cluster.awx_cluster]

  provisioner "local-exec" {
    command = <<-EOT
      gcloud container clusters get-credentials ${var.cluster_name} \
        --region=${var.region} --project=${var.project}

      helm install my-awx-operator awx-operator/awx-operator -n awx --create-namespace -f awx-operator/config.yaml
      helm repo add pulp-operator https://github.com/pulp/pulp-k8s-resources/raw/main/helm-charts/ --force-update
      kubectl apply -f awx-operator/ingress.yaml
    EOT
  }
}

resource "null_resource" "delay" {

  depends_on = [null_resource.helm_install]

  provisioner "local-exec" {
    command = "sleep 450"  # Sleep for 7 minutes 30 seconds (450 seconds)
  }
}

data "external" "login_details_pull" {
  depends_on = [null_resource.delay]
  program = ["awx-operator/get_login_details.sh"]
}

# Display AWX url, username and password
output "awx_login_details_display" {
  value = "############################################## \nLogin to AWX with below details \nURL: http://${data.external.login_details_pull.result["ip"]} \nUsername: admin \nPassword: ${data.external.login_details_pull.result["password"]} \n##############################################"
}
