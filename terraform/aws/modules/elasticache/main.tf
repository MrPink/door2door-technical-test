variable "cluster_name" {}

# create a elasticache instane for Redis
resource "aws_elasticache_cluster" "ticks" {
  cluster_id = "${var.cluster_name}"
  engine = "redis"
  node_type = "cache.t2.micro"
  port = 11211
  num_cache_nodes = 1
}

