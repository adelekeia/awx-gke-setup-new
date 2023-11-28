provider "google" {
  access_token = var.access_token
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_container_cluster" "awx_cluster" {
  name     = var.cluster_name
  location = var.region  # Replace with your desired region
 
  min_master_version = "1.26.5-gke.2700"  # Replace with the desired Kubernetes version
  initial_node_count = 1

  node_config {
    machine_type = "n1-standard-1"
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


# Provisioner to run local commands
resource "null_resource" "helm_install" {

  depends_on = [google_container_cluster.awx_cluster]

  provisioner "local-exec" {
    command = <<-EOT
      gcloud container clusters get-credentials ${var.cluster_name} \
        --region=${var.region} --project=${var.project}

      helm install my-awx-operator awx-operator/awx-operator -n awx --create-namespace -f ../awx-operator/config.yaml
    EOT
  }
}

resource "null_resource" "delay" {

  depends_on = [null_resource.helm_install]

  provisioner "local-exec" {
    command = "sleep 150"  # Sleep for 2 minutes 30 seconds (150 seconds)
  }
}

resource "null_resource" "ingress_trf_bootstrap" {

  depends_on = [null_resource.delay]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}
      cd ../ingress
      pwd
      terraform init
      terraform apply -auto-approve
    EOT
  }
}