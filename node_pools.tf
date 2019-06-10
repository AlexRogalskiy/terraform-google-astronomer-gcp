# Node pool
resource "google_container_node_pool" "node_pools" {
  count = 2

  name = "${var.deployment_id}-node-pool-${count.index}"

  location = var.region
  cluster  = google_container_cluster.primary.name

  # since we are 'regional' i.e. in 3 zones,
  # "1" here means "1 in each zone"
  initial_node_count = "1"

  autoscaling {
    min_node_count = "0"
    max_node_count = ceil(var.max_node_count / 3)
  }

  management {
    # https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-upgrades
    auto_upgrade = true

    # https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-repair
    auto_repair = true
  }

  node_config {
    machine_type = var.machine_type

    labels = {
      # One of the pools should have the label indicating that it's
      # multi-tenant, and the other should not.
      multi_tenant = count.index == 0 ? "true" : "false"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

